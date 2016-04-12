`timescale 1ns / 1ps 
`include "sd_defines.h"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2016 01:37:27 AM
// Design Name: 
// Module Name: sd_emmc_controller_dma
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module  sd_emmc_controller_dma (
            input  wire clock,
            input  wire reset,

            // S_AXI
            input  wire [31:0] init_dma_sys_addr,
            input  wire [2:0] buf_boundary,
            (* mark_debug = "true" *) input  wire [`BLKCNT_W -1:0] block_count,
            input  wire sys_addr_changed,
            input wire dma_ena_trans_mode,
            input wire dir_dat_trans_mode,
            input wire blk_count_ena,
//            input wire [11:0] blk_size,
            output reg [1:0] dma_interrupts,
            input wire dat_int_rst,

            // Data serial
            input wire xfer_compl,
            input  wire is_we_en,
            
            // FIFO Filler
            output reg data_read_ready,

            // M_AXI
            input  wire next_data_word,
            output reg data_write_valid,
            output reg [31:0] write_addr,
            output reg addr_write_valid,
            input wire addr_write_ready,
            output reg w_last,
            output wire [31:0] axi_araddr,
            output wire axi_arvalid,
            input wire axi_arready,
            input wire [31:0] axi_rdata,
            input wire axi_rvalid,
            output wire axi_rready,
            input wire axi_rlast
        );

reg [15:0] block_count_bound;
(* mark_debug = "true" *) reg [15:0] total_trans_blk;
reg [2:0] if_buf_boundary_changed;
(* mark_debug = "true" *) reg [2:0] state;
(* mark_debug = "true" *) reg [7:0] data_cycle;
reg [15:0] blk_done_cnt_within_boundary;
reg [11:0] we_counter;
reg init_we_ff;
reg init_we_ff2;
reg addr_accepted;
reg we_counter_reset;
wire we_pulse;

parameter IDLE               = 3'b0000;
parameter WRITE_WAIT         = 3'b0001;
parameter READ_WAIT          = 3'b0010;
parameter READ_ACT           = 3'b0011;
parameter NEW_SYS_ADDR       = 3'b0100;
parameter READ_BLK_CNT_CHECK = 3'b0101;
parameter TRANSFER_COMPLETE  = 3'b0110;
parameter WRITE_ACT          = 3'b0111;

    always @ (posedge clock)
    begin: BUFFER_BOUNDARY //see chapter 2.2.2 "SD Host Controller Simplified Specification V 3.00"
      if (reset == 1'b0) begin
        block_count_bound <= 0;
        if_buf_boundary_changed <= 0;
      end
      else begin
        if (if_buf_boundary_changed != buf_boundary) begin
          case (buf_boundary)
          3'b000: begin
                block_count_bound <= `A11;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b001: begin
                block_count_bound <= `A12;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b010: begin
                block_count_bound <= `A13;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b011: begin
                block_count_bound <= `A14;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b100: begin
                block_count_bound <= `A15;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b101: begin
                block_count_bound <= `A16;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b110: begin
                block_count_bound <= `A17;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b111: begin
                block_count_bound <= `A18;
                if_buf_boundary_changed <= buf_boundary;
              end
          endcase
        end
      end
    end

    always @(posedge clock)
    begin: STATE_TRANSITION
      if (reset == 1'b0) begin
        state <= IDLE;
        total_trans_blk <= 0;
        addr_write_valid <= 0;
        data_write_valid <= 0;
        blk_done_cnt_within_boundary <= 0;
        data_cycle <= 0;
        write_addr <= 0;
        data_read_ready <= 0;
        addr_accepted <= 0;
        w_last <= 0;
        dma_interrupts <= 0;
      end
      else begin
        case (state)
          IDLE: begin
                  if (dir_dat_trans_mode & dma_ena_trans_mode & !xfer_compl) begin
                    write_addr <= init_dma_sys_addr;
                    state <= READ_WAIT;
                    we_counter_reset <= 1;
                  end
                  else if (~dir_dat_trans_mode & dma_ena_trans_mode & xfer_compl) begin
                    state <= WRITE_WAIT;
                  end
                  else begin
                    state <= IDLE;
                    total_trans_blk <= 0;
                    blk_done_cnt_within_boundary <= 0;
                    write_addr <= 0;
                    data_cycle <= 0;
                    data_read_ready <= 0;
                  end
                end
          READ_WAIT: begin
                  if (we_counter > data_cycle) begin
                    state <= READ_ACT;
                  end
                  else if (data_cycle == 8'h80) begin
                    blk_done_cnt_within_boundary <= blk_done_cnt_within_boundary + 1;
                    total_trans_blk <= total_trans_blk + 1;
                    data_cycle <= 0;
                    we_counter_reset <= 0;
                    data_read_ready <= 1'b0;
                    state <= READ_BLK_CNT_CHECK;
                  end
                  else begin
                    data_read_ready <= 1'b0;
                    w_last <= 1'b0;
                    state <= READ_WAIT;
                  end 
                end
          READ_ACT: begin
                      case (addr_accepted)
                        1'b0: begin 
                          if (addr_write_valid && addr_write_ready) begin
                            addr_write_valid <= 1'b0;
                            addr_accepted <= 1'b1;
                            data_write_valid <= 1'b1;
                            w_last <= 1'b1;
                          end
                          else begin
                            addr_write_valid <= 1'b1;
                          end
                        end
                        1'b1: begin
                          if (next_data_word) begin
                            data_write_valid <= 1'b0;
                            addr_accepted <= 1'b0;
                            data_cycle <= data_cycle + 1;
                            write_addr <= write_addr + 4;
                            data_read_ready <= 1'b1;
                            w_last <= 1'b0;
                            state <= READ_WAIT;
                          end
                          else begin
                            data_write_valid <= data_write_valid;
                          end
                        end
                      endcase 
                    end
          NEW_SYS_ADDR: begin
                          if (sys_addr_changed) begin
                            state <= READ_WAIT;
                            blk_done_cnt_within_boundary <= 0;
                            write_addr <= init_dma_sys_addr;
                          end
                          else begin
                            state <= NEW_SYS_ADDR;
                          end 
                        end
          READ_BLK_CNT_CHECK: begin
                                we_counter_reset <= 1'b1;
                                if (blk_count_ena) begin
                                  if (total_trans_blk < block_count) begin
                                    if (blk_done_cnt_within_boundary == block_count_bound) begin
                                      dma_interrupts[1] <= 1'b1;
                                      state <= NEW_SYS_ADDR;
                                    end
                                    else begin
                                      state <= READ_WAIT;
                                    end
                                  end
                                  else begin
                                    state <= TRANSFER_COMPLETE;
                                    dma_interrupts[0] <= 1'b1;
                                  end
                                end
                                else if (blk_done_cnt_within_boundary == block_count_bound) begin
                                  state <= NEW_SYS_ADDR;
                                end
                                else begin
                                  state <= READ_WAIT;
                                end
                              end
          TRANSFER_COMPLETE:begin
                              if (xfer_compl) begin
                                state <= IDLE;
                              end
                              else begin
                                state <= TRANSFER_COMPLETE;
                              end
                            end
          WRITE_WAIT:begin
                       
                     end
        endcase
        if (dat_int_rst)
          dma_interrupts <= 0;
      end
    end
    
//assign data_read_ready = (!init_dat_read_ready2) && init_dat_read_ready;

//    always @ (posedge clock)
//        begin: DATA_READ_READY_PULSE_GENERATOR
//          if (reset == 1'b0) begin
//            init_dat_read_ready <= 1'b0;
//            init_dat_read_ready2 <= 1'b0;
//          end
//          else begin
//            init_dat_read_ready <= fifo_read; 
//            init_dat_read_ready2 <= init_dat_read_ready; 
//          end
//        end

    always @ (posedge clock)
      begin: NUMBER_OF_FIFO_WRITING_COUNTER
        if ((reset == 1'b0) || (we_counter_reset == 1'b0)) begin
          we_counter <= 0;
        end
        else begin
          if (we_pulse)
              we_counter <= we_counter + 12'h001;
        end
      end

//	assign we_pulse	= (!init_we_ff2) && init_we_ff;
	assign we_pulse	= init_we_ff2 && (!init_we_ff);
	
    always @ (posedge clock)
      begin: WE_PULS_GENERATOR
        if (reset == 1'b0) begin
          init_we_ff <= 1'b0;
          init_we_ff2 <= 1'b0;
        end
        else begin
          init_we_ff <= is_we_en;
          init_we_ff2 <= init_we_ff;
        end
      end


endmodule
