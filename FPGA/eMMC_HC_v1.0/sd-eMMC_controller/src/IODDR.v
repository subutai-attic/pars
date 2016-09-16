`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/16/2016 05:43:21 PM
// Design Name: 
// Module Name: IODDR
// Project Name: eMMC Host controller
// Target Devices: Parallella board
// Tool Versions: 
// Description: This is an implementation of a DDR I/O
// This unit will be used for each eMMC data line.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IODDR(
    input      wire	    Clk, 
    input      wire         Reset,
    input      wire         WriteData_posEdge,
    input      wire         WriteData_negEdge,
    input      wire         out_en,
    output     wire         ReadData_posEdge,
    output     wire         ReadData_negEdge,
    inout      wire         DDRPORT
); 

wire         ddrOutput; 

// the main output will be over DDRPORT 

assign DDRPORT = ( out_en ) ? ddrOutput : 1'bz; 

///////////////////////////////////////////////
//
// DDR Output 
//
///////////////////////////////////////////////

ODDR #(
  .DDR_CLK_EDGE ( "OPPOSITE_EDGE" ),    // "OPPOSITE_EDGE" or "SAME_EDGE"     );
  .INIT         ( 1'b0 ),               // Initial value of Q: 1'b0 or 1'b1endmodule
  .SRTYPE       ( "SYNC" )              // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst (
  .Q        ( ddrOutput ),              // 1-bit DDR output
  .C        ( Clk ),                    // 1-bit clock input
  .CE       ( 1 ),                      // 1-bit clock enable input
  .D1       ( WriteData_posEdge ),      // 1-bit data input (positive edge)
  .D2       ( WriteData_negEdge ),      // 1-bit data input (negative edge)
  .R        ( Reset ),                  // 1-bit reset
  .S        ( 0 )                       // 1-bit set
);

///////////////////////////////////////////////
//
// DDR Input 
//
///////////////////////////////////////////////

IDDR #(
.DDR_CLK_EDGE     ("OPPOSITE_EDGE")
) IDDR_Ins (
.Q1         ( ReadData_posEdge ),       // 1-bit output for positive edge of clock
.Q2         ( ReadData_negEdge ),       // 1-bit output for negative edge of clock
.C          ( Clk ),                    // 1-bit clock input
.CE         ( 1 ),                      // 1-bit clock enable input
.D          ( DDRPORT ),                // 1-bit DDR data input
.R          ( Reset ),                  // 1-bit reset
.S          ( 0 )                       // 1-bit set
);

endmodule
