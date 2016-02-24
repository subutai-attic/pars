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
            input  wire [31:0] init_dma_sys_addr,
            input  wire [2:0] buf_boundary,
            input  wire [`BLKCNT_W -1:0] block_count,
            input  wire dma_ena_trans_mode,
            input  wire dir_dat_trans_mode,
            input  wire is_fifo_emty_rd,
            output wire data_read_ready,
            input  wire next_data_word 
        );
reg [16:0] transf_cnt_thresh;
reg [16:0] transf_cnt;
reg [2:0] if_buf_boundary_changed;
reg [1:0] state;

parameter IDLE       = 2'b00;
parameter WRITE      = 2'b01;
parameter READ       = 2'b10;

    always @ (posedge clock)
    begin: BUFFER_BOUNDARY //see chapter 2.2.2 "SD Host Controller Simplified Specification V 3.00"
      if (reset == 1'b0) begin
        transf_cnt_thresh <= 0;
        if_buf_boundary_changed <= 0;
      end
      else begin
        if (if_buf_boundary_changed != buf_boundary) begin
          case (buf_boundary)
          3'b000: begin
                transf_cnt_thresh <= `A11;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b001: begin
                transf_cnt_thresh <= `A12;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b010: begin
                transf_cnt_thresh <= `A13;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b011: begin
                transf_cnt_thresh <= `A14;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b100: begin
                transf_cnt_thresh <= `A15;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b101: begin
                transf_cnt_thresh <= `A16;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b110: begin
                transf_cnt_thresh <= `A17;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b111: begin
                transf_cnt_thresh <= `A18;
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
      end
      else begin
        if (dma_ena_trans_mode == 1'b1) begin
          case (state)
            IDLE: begin
                    if (dir_dat_trans_mode == 1'b1)
                      state <= READ;
                    else
                      state <= WRITE;
                  end
            READ: begin
                    
                  end
            WRITE:begin
                  end
          endcase
        end
      end
    end
    
    
endmodule
