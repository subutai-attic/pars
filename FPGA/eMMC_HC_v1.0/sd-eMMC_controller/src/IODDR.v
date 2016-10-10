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
    input      wire	        Clk, 
    input      wire	        Clk90,     
    input      wire         Reset,
    input      wire         WriteData_posEdge,
    input      wire         WriteData_negEdge,
    input      wire         out_en,
    output     wire         ReadData_posEdge,
    output     wire         ReadData_negEdge,
    inout      wire         DDRPORT
); 

wire         ddrOutput; 
(* mark_debug = "true" *) wire         ddrInput;

// the main output will be over DDRPORT 

//assign DDRPORT = ( out_en ) ? ddrOutput : 1'bz; 
//assign ddrInput = ( out_en ) ? 1'bz : DDRPORT;

//   // IOBUF: Single-ended Bi-directional Buffer
//   //        All devices
//   // Xilinx HDL Language Template, version 2016.2
   
   IOBUF #(
      .DRIVE(12),               // Specify the output drive strength
      .IBUF_LOW_PWR("TRUE"),    // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("DEFAULT"),   // Specify the I/O standard
      .SLEW("SLOW")             // Specify the output slew rate
   ) IOBUF_inst (
      .O(ddrInput),             // Buffer output
      .IO(DDRPORT),             // Buffer inout port (connect directly to top-level port)
      .I(ddrOutput),            // Buffer input
      .T(~out_en)               // 3-state enable input, high=input, low=output
   );

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

//always @(posedge Clk)
//ReadData_posEdge <= ddrInput;

//always @(negedge Clk)
//ReadData_negEdge <= ddrInput;
/////////////////////////////////////////////////
////
//// DDR Input 
////
/////////////////////////////////////////////////

IDDR #(
.DDR_CLK_EDGE     ("OPPOSITE_EDGE")
) IDDR_Ins (
.Q1         ( ReadData_posEdge ),       // 1-bit output for positive edge of clock
.Q2         ( ReadData_negEdge ),       // 1-bit output for negative edge of clock
.C          ( Clk90 ),                    // 1-bit clock input
.CE         ( 1 ),                      // 1-bit clock enable input
.D          ( ddrInput ),               // 1-bit DDR data input
.R          ( Reset ),                  // 1-bit reset
.S          ( 0 )                       // 1-bit set
);

endmodule
