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

            // FIFO Filler
(* mark_debug = "true" *)            input  wire dma_ena_trans_mode,
(* mark_debug = "true" *)            input  wire dir_dat_trans_mode,
(* mark_debug = "true" *)            input  wire is_fifo_emty_rd,
(* mark_debug = "true" *)            output reg data_read_ready,

            // M_AXI
(* mark_debug = "true" *)            input  wire next_data_word,
(* mark_debug = "true" *)            output reg data_write_valid,
(* mark_debug = "true" *)            output reg [31:0] write_addr,
(* mark_debug = "true" *)            output reg addr_write_valid,
(* mark_debug = "true" *)            input wire addr_write_ready
        );

reg [16:0] block_count_bound;
reg [16:0] total_trans_blk;
reg [2:0] if_buf_boundary_changed;
(* mark_debug = "true" *) reg [2:0] state;
(* mark_debug = "true" *) reg [7:0] data_cycle;
reg [16:0] trans_blk_inside_boundary;

parameter IDLE          = 3'b000;
parameter WRITE         = 3'b001;
parameter READ          = 3'b010;
parameter READ_ACT      = 3'b011;
parameter NEW_SYS_ADDR  = 3'b100;

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
        total_trans_blk <= 0;
        data_read_ready <= 0;
        addr_write_valid <= 0;
        data_write_valid <= 0;
        trans_blk_inside_boundary <= 0;
      end
      else begin
        if (dma_ena_trans_mode == 1'b1) begin
          case (state)
            IDLE: begin
                    if (dir_dat_trans_mode && ~is_fifo_emty_rd) begin
                      state <= READ;
                      write_addr <= init_dma_sys_addr;
                      data_read_ready <= 1'b1;
                    end
                    else if (~dir_dat_trans_mode && ~is_fifo_emty_rd)
                      state <= WRITE;
                    else
                      state <= IDLE;
                      total_trans_blk <= 16'h0000;
                      data_read_ready <= 1'b0;
                      addr_write_valid <= 1'b0;
                      data_write_valid <= 1'b0;
                      trans_blk_inside_boundary <= 16'h0000;
                  end
            READ: begin
                    if (block_count == total_trans_blk) begin
                      state <= IDLE;
                      // need to add transfer complete interrupt generation
                    end
                    else if (block_count_bound == trans_blk_inside_boundary) begin
                        state <= NEW_SYS_ADDR;
                        // need to add dma interrupt generation
                        data_read_ready <= 1'b0;
                        addr_write_valid <= 1'b0;
                        data_write_valid <= 1'b0;
                    end
                    else begin
                      state <= READ_ACT;
                      data_cycle <= 0;
                    end 
                  end
            READ_ACT: begin
                        if (data_cycle == 8'h80) begin
                          state <= READ;
                          trans_blk_inside_boundary <= trans_blk_inside_boundary + 1;
                          total_trans_blk <= total_trans_blk + 1;
                        end
                        else if (~is_fifo_emty_rd & next_data_word) begin
                          write_addr <= write_addr + 3'h4;
                          data_read_ready <= 1'b0;
                          addr_write_valid <= 1'b0;
                          data_write_valid <= 1'b0;
                          data_cycle <= data_cycle + 1;
                        end
                        else begin
                          addr_write_valid <= 1'b1;
                          data_write_valid <= 1'b1;
                          data_read_ready <= 1'b1;
                        end 
                      end
            NEW_SYS_ADDR: begin
                            if (sys_addr_changed) begin
                              state <= READ;
                              trans_blk_inside_boundary <= 16'h0000;
                              write_addr <= init_dma_sys_addr;
                              data_read_ready <= 1'b1;
                            end
                            else
                              state <= NEW_SYS_ADDR; 
                          end
            WRITE:begin
                  end
          endcase
        end
        else
          state <= IDLE;
      end
    end
    
    
endmodule
