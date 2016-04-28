
`timescale 1 ns / 1 ps

	module serdes_lvds_v1_0 
	(
	   input clk, 
	   input din, 
	   input serd_cmd,
	   
	   
	   output dout
	);
   // input ports	
    wire [1:0] serd_cmd;
    wire [31:0] din;
   //output ports
	wire [39:0] dout;
	
	
//    wire [4:0] lvds_control;
//    wire [4:0] serialout;
//    wire [4:0] serialin;

    serializer ser_inst0(
        .clk(clk),
        .din(din),
        .serd_cmd(serd_cmd),
//        .start(start),
//        .flag7E(flag7E),
        .dout(dout)
    );   

//    deserializer_8b deser_inst0(
//        .clk(clk),
//        .serial(),
//        .strb(0), //strob
//        .datout(),
//        .encode()
//    );     
   
    // Massive of iobufds elements 
//    lvds_v1_0 lvds_io(
//        .CLK_I(clk), //clk
//        .CLK_O(CLK_O),
//        .DAT_O(serialin),//serial to deserializer
//        .DAT_I(serialout),//serial from serializer
//        .DAT_T(0), //strb
//        .DIF_P(DIF_P),
//        .DIF_N(DIF_N),
//        .CLK_O_P(CLK_O_P), //CLK_O_P
//        .CLK_O_N(CLK_O_N), //CLK_O_N
//        .CLK_I_P(), //CLK_I_P
//        .CLK_I_N()
//    );

	endmodule
