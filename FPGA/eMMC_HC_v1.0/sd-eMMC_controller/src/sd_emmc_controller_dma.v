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
            input wire clock,
            input wire reset,
            input wire [31:0] init_dma_sys_addr,
            input wire [2:0] buf_boundary,
            input wire [`BLKCNT_W -1:0] block_count
        );
reg [19:0] transf_count;
reg [2:0] if_buf_boundary_changed;

    always @ (posedge clock)
    begin
      if(reset == 1'b0) begin
        transf_count <= 0;
        if_buf_boundary_changed <= 0;
      end
      else begin
        if (if_buf_boundary_changed != buf_boundary) begin
          case (buf_boundary)
          3'b000: begin
                transf_count <= `A11;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b001: begin
                transf_count <= `A12;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b010: begin
                transf_count <= `A13;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b011: begin
                transf_count <= `A14;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b100: begin
                transf_count <= `A15;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b101: begin
                transf_count <= `A16;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b110: begin
                transf_count <= `A17;
                if_buf_boundary_changed <= buf_boundary;
              end
          3'b111: begin
                transf_count <= `A18;
                if_buf_boundary_changed <= buf_boundary;
              end
          endcase
        end
      end
    end

endmodule
