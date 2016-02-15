`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2015 11:41:32 AM
// Design Name: 
// Module Name: clock_divider
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


module sd_clock_divider(
    input wire AXI_CLOCK,
    output wire sd_clk,
    input wire [7:0] DIVISOR,
    input AXI_RST,
    output reg Internal_clk_stable
    );

reg [7:0] clk_div;
reg SD_CLK_O;
assign sd_clk = SD_CLK_O;


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


endmodule
