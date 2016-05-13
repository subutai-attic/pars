
`timescale 1 ns / 1 ps

	module serdes_lvds_v1_0 
	(
	   input wire clk, 
	   input wire reset_n,
	   
	  // TX 
	   input wire [39:0] txdin, 
	   input wire [1:0] serd_cmd,
	   output wire [23:0] txdout1,
	   output wire [15:0] txdout2,
	   
	  // RX 
       input  wire [23:0] rxdin1,
       input  wire [15:0] rxdin2,       
	   output wire [23:0] rxdout1,
	   output wire [15:0] rxdout2,	   
	   output wire [2:0] bitslip1,
	   output wire [1:0] bitslip2,	 
	   
	  // Tristate
	   output wire tristate1,
       output wire tristate2	     
	);
	
	assign tristate1 = serd_cmd[0];
	assign tristate2 = serd_cmd[1];
	
	wire [4:0] bitslip;
	assign bitslip1 = bitslip[2:0];
	assign bitslip2	= bitslip[4:3]; 

    serializer ser_inst0(
        .clk(clk),
        .reset_n(reset_n),
        .din(txdin),
        .serd_cmd(serd_cmd),
        .dout1(txdout1),
        .dout2(txdout2)      
    );       

    deserializer_8b deser_inst0(
        .clk(clk),
        .reset_n(reset_n),
        .serd_cmd(serd_cmd),
        .din1(rxdin1),
        .din2(rxdin2),
        .dout1(rxdout1),
        .dout2(rxdout2),        
        .bitslip(bitslip)
    );          
 

	endmodule
