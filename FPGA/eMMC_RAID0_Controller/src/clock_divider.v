`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Optimal Dynamics LLC
// Engineer: Azamat Beksadaev, Baktiiar Kukanov 
// 
// Create Date: 10/02/2015 11:41:32 AM
// Design Name: 
// Module Name: clock_divider
// Project Name: RAID 0 Controller
// Target Devices: Xilinx ZYNQ 7000
// Tool Versions: Vivado 2016.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_clock_divider.v                                           ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Control of sd card clock rate                                ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

module clock_divider(
    input wire AXI_CLOCK,
    output wire sd_clk,
    input wire [7:0] DIVISOR,
    input AXI_RST,
    output reg Internal_clk_stable,
    output wire sd_clk90
    );

reg [7:0] clk_div;
reg SD_CLK_O;
reg [7:0] div;
reg SD_CLK_90;
assign sd_clk = SD_CLK_O;
assign sd_clk90 = SD_CLK_90;


always @ (posedge AXI_CLOCK or posedge AXI_RST)
begin
 if (~AXI_RST) begin
    clk_div <=8'b0000_0000;
    SD_CLK_O  <= 0;
    Internal_clk_stable <= 1'b0;
 end
 else if (clk_div == DIVISOR)begin
    clk_div  <= 0;
    SD_CLK_O <=  ~SD_CLK_O;
    Internal_clk_stable <= 1'b1;
 end 
 else begin
    clk_div  <= clk_div + 1;
    SD_CLK_O <=  SD_CLK_O;
    Internal_clk_stable <= 1'b1;
 end
end


always @ (negedge AXI_CLOCK or posedge AXI_RST)
begin
 if (~AXI_RST) begin
    div <=8'b0000_0000;
    SD_CLK_90  <= 0;
 end
 else if (div == DIVISOR)begin
    div  <= 0;
    SD_CLK_90 <=  ~SD_CLK_90;
 end 
 else begin
    div  <= div + 1;
    SD_CLK_90 <=  SD_CLK_90;
 end
end

endmodule
