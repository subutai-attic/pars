
`timescale 1 ns / 1 ps

	module serdes_lvds_v1_0 
	(
	   input clk, 
	   input reset_n,
       input  [39:0] rxdin,
	   output [39:0] rxdout,
	   output [4:0] bitslip
	   
	);  

    deserializer_8b deser_inst0(
        .clk(clk),
        .reset_n(reset_n),
        .rxdin(rxdin),
        .rxdout(rxdout),
        .bitslip(bitslip)
    );     
      

	endmodule
