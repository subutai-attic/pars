// This is an implementation of a DDR I/O 
// Planed to use this unit for each eMMC data line. 

module sd_eMMC_DDR (
	input 	wire		Clk, 
	input 	wire 		Reset,
	input 	wire 		WriteData_posEdge,
	input 	wire 		WriteData_negEdge,
	input 	wire 		OutputEnable,
	output 	wire 		ReadData_posEdge,
	output 	wire 		ReadData_negEdge,
	inout 	wire 		DDRPORT
); 

///////////////////////////////////////////////
//
// DDR Input 
//
///////////////////////////////////////////////

IDDR #(
	.DDR_CLK_EDGE 	("OPPOSITE_EDGE")
) IDDR_Ins (
	.Q1 		( ReadData_posEdge ),
	.Q2 		( ReadData_negEdge ), 
	.C 		( Clk ), 
	.CE 		( 1 ), 
	.D 		( DDRPORT ),
	.R 		( 0 ),
	.S 		( 0 )
);

///////////////////////////////////////////////
//
// DDR Output 
//
///////////////////////////////////////////////

wire 		ddrOutput; 

// the main output will be over DDRPORT 

assign DDRPORT = ( OutputEnable ) ? ddrOutput : 1'bz; 

ODDR # (
	.DDR_CLK_EDGE 	("OPPOSITE_EDGE")
) ODDR_Ins (
	.Q 		( ddrOutput ),
	.C 		( Clk ),
	.CE 		( 1 ),
	.D1 		( WriteData_posEdge ),
	.D2 		( WriteData_negEdge ),
	.R 		( 0 ), 
	.S 		( 0 )
); 

endmodule
