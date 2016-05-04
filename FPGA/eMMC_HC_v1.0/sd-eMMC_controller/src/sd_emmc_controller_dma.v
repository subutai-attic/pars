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
            input  wire [`BLKCNT_W -1:0] block_count,
            input  wire sys_addr_changed,
            input wire dma_ena_trans_mode,
            input wire dir_dat_trans_mode,
            input wire blk_count_ena,
//            input wire [11:0] blk_size,
            output reg [1:0] dma_interrupts,
            input wire dat_int_rst,
            input wire cmd_int_rst_pulse,

            // Data serial
            input wire xfer_compl,
            input  wire is_we_en,
            output reg start_write,
            input wire trans_block_compl,
            input wire ser_next_blk,
            input wire [1:0] write_timeout,
            
            // FIFO Filler
            output reg fifo_dat_rd_ready,
            output reg fifo_dat_wr_ready,
            output reg fifo_rst,

            // M_AXI
            input  wire next_data_word,
            output reg data_write_valid,
            output reg [31:0] write_addr,
            output reg addr_write_valid,
            input wire addr_write_ready,
            output reg w_last,
            output reg [31:0] axi_araddr,
            output reg axi_arvalid,
            input wire axi_arready,
            input wire axi_rvalid,
            output wire axi_rready,
            input wire axi_rlast
        );

reg [15:0] block_count_bound;
reg [15:0] total_trans_blk;
reg [2:0] if_buf_boundary_changed;
(* mark_debug = "true" *) reg [3:0] state;
(* mark_debug = "true" *) reg [7:0] data_cycle;
reg [15:0] blk_done_cnt_within_boundary;
reg [11:0] we_counter;
reg init_we_ff;
reg init_we_ff2;
reg init_rready;
reg init_rready2;
reg init_rvalid;
reg addr_accepted;
reg we_counter_reset;
wire we_pulse;

parameter IDLE                = 4'b0000;
parameter WRITE_TO_FIFO       = 4'b0001;
parameter READ_WAIT           = 4'b0010;
parameter READ_ACT            = 4'b0011;
parameter NEW_SYS_ADDR        = 4'b0100;
parameter READ_BLK_CNT_CHECK  = 4'b0101;
parameter TRANSFER_COMPLETE   = 4'b0110;
parameter WRITE_ACT           = 4'b0111;
parameter WRITE_CNT_BLK_CHECK = 4'b1000; 

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
        fifo_dat_rd_ready <= 0;
        fifo_dat_wr_ready <= 0;
        addr_accepted <= 0;
        w_last <= 0;
        dma_interrupts <= 0;
        axi_arvalid <= 0;
        fifo_rst <= 0;
      end
      else begin
        case (state)
          IDLE: begin
                   total_trans_blk <= 0;
                   blk_done_cnt_within_boundary <= 0;
                   write_addr <= 0;
                   data_cycle <= 0;
                   fifo_dat_rd_ready <= 0;
                   fifo_dat_wr_ready <= 0;                    
                  if (dir_dat_trans_mode & dma_ena_trans_mode & !xfer_compl) begin
                    write_addr <= init_dma_sys_addr;
                    state <= READ_WAIT;
                    we_counter_reset <= 1;
                    fifo_rst <= 1;
                  end
                  else if (!dir_dat_trans_mode & dma_ena_trans_mode & !xfer_compl & cmd_int_rst_pulse) begin
                    state <= WRITE_TO_FIFO;
                    fifo_rst <= 1;
                    axi_araddr <= init_dma_sys_addr;
                  end
                  else begin
                    state <= IDLE;
                  end
                end
          READ_WAIT: begin
                  fifo_rst <= 0;
                  fifo_dat_rd_ready <= 1'b0;
                  if (we_counter > data_cycle) begin
                    state <= READ_ACT;
                  end
                  else if (data_cycle == 8'h80) begin
                    blk_done_cnt_within_boundary <= blk_done_cnt_within_boundary + 1;
                    total_trans_blk <= total_trans_blk + 1;
                    data_cycle <= 0;
                    we_counter_reset <= 0;
                    state <= READ_BLK_CNT_CHECK;
                  end
                  else begin
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
                            fifo_dat_rd_ready <= 1'b1;
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
                          if (sys_addr_changed & dir_dat_trans_mode) begin
                            state <= READ_WAIT;
                            blk_done_cnt_within_boundary <= 0;
                            write_addr <= init_dma_sys_addr;
                          end
                          else if (sys_addr_changed & !dir_dat_trans_mode) begin
                            state <= WRITE_TO_FIFO;
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
                                  end
                                end
                                else if (blk_done_cnt_within_boundary == block_count_bound) begin
                                  state <= NEW_SYS_ADDR;
                                end
                                else begin
                                  state <= READ_WAIT;
                                end
                              end
          TRANSFER_COMPLETE: begin
                              if (xfer_compl) begin
                                state <= IDLE;
                                dma_interrupts[0] <= 1'b1;
                              end
                              else begin
                                state <= TRANSFER_COMPLETE;
                              end
                            end
          WRITE_TO_FIFO: begin
                          fifo_rst <= 0;
                          case (addr_accepted)
                            1'b0: begin
                              if (data_cycle == 8'h7F) begin
                                blk_done_cnt_within_boundary <= blk_done_cnt_within_boundary + 1;
                                total_trans_blk <= total_trans_blk + 1;
                                data_cycle <= 0;
                                state <= WRITE_CNT_BLK_CHECK;
                                start_write <= 1;
                              end
                              else begin
                                if (axi_arvalid & axi_arready) begin
                                  axi_arvalid <= 1'b0;
                                  addr_accepted <= 1'b1;
                                  axi_araddr <= axi_araddr + 64;
                                end
                                else begin
                                  axi_arvalid <= 1'b1;
                                end
                              end
                            end
                            1'b1: begin  //The burst read active
                              if (axi_rvalid && ~fifo_dat_wr_ready) begin
                                fifo_dat_wr_ready <= 1'b1;
                                if(axi_rready) begin
                                    data_cycle <= data_cycle + 1;
                                end
                              end
                              else if (fifo_dat_wr_ready) begin
                                fifo_dat_wr_ready <= 1'b0;
                                if (axi_rlast)
                                 addr_accepted <= 1'b0;  //The burst read stopped
                              end
                            end
                          endcase
                        end
          WRITE_CNT_BLK_CHECK: begin
                                 if (ser_next_blk) begin
                                    start_write <= 0;
                                 end
                                 if ((total_trans_blk < block_count) && trans_block_compl) begin
                                   if (blk_done_cnt_within_boundary == block_count_bound) begin
                                     dma_interrupts[1] <= 1'b1;
                                     state <= NEW_SYS_ADDR;
                                     start_write <= 0;
                                   end
                                   else begin
                                     state <=  WRITE_TO_FIFO;
                                     start_write <= 0;
                                   end
                                 end
                                 else if ((total_trans_blk == block_count)  && xfer_compl) begin
                                   state <= IDLE;
                                   start_write <= 0;
                                   dma_interrupts[0] <= 1'b1;
                                 end
                               end
                               
        endcase
        // abort the state when timeout on data serializer
        if (write_timeout == 2'b11) begin
          state <= IDLE;
          start_write <= 0;
        end
        if (dat_int_rst)
          dma_interrupts <= 0;
      end
    end
    
    assign axi_rready = (!init_rready2) && init_rready;

    always @ (posedge clock)
      begin: AXI_RREADY_PULSE_GENERATOR
        if (reset == 1'b0) begin
          init_rready <= 1'b0;
          init_rready2 <= 1'b0;
        end
        else begin
          init_rready <= fifo_dat_wr_ready;
          init_rready2 <= init_rready;
        end
      end

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
