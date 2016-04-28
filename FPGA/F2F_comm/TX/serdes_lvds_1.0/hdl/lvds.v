`timescale 1ns / 1ps

	module lvds_v1_0 
	(
	    input CLK_I,
	    output CLK_O,
		output wire [4:0] DAT_O,
		input wire [4:0] DAT_I,
		input wire DAT_T,
		inout [4:0] DIF_P,
		inout [4:0] DIF_N,
		output CLK_O_P,
        output CLK_O_N,
        input CLK_I_P,
        input CLK_I_N
	);	
	    
IOBUFDS #(
    .IOSTANDARD("BLVDS_25") // Specify the I/O standard
) IOBUFDS_inst_0 (
    .O(DAT_O[0]),
    .IO(DIF_P[0]),
    .IOB(DIF_N[0]), 
    .I(DAT_I[0]),
    .T(DAT_T)
// 3-state enable input, high=input, low=output
);

IOBUFDS #(
    .IOSTANDARD("BLVDS_25")
) IOBUFDS_inst_1 (
    .O(DAT_O[1]),
    .IO(DIF_P[1]),
    .IOB(DIF_N[1]), 
    .I(DAT_I[1]),
    .T(DAT_T)
);

IOBUFDS #(
    .IOSTANDARD("BLVDS_25")
) IOBUFDS_inst_2 (
    .O(DAT_O[2]),
    .IO(DIF_P[2]),
    .IOB(DIF_N[2]), 
    .I(DAT_I[2]),
    .T(DAT_T)
);

IOBUFDS #(
    .IOSTANDARD("BLVDS_25")
) IOBUFDS_inst_3 (
    .O(DAT_O[3]),
    .IO(DIF_P[3]),
    .IOB(DIF_N[3]), 
    .I(DAT_I[3]),
    .T(DAT_T)
);

IOBUFDS #(
    .IOSTANDARD("BLVDS_25")
) IOBUFDS_inst_4 (
    .O(DAT_O[4]),
    .IO(DIF_P[4]),
    .IOB(DIF_N[4]), 
    .I(DAT_I[4]),
    .T(DAT_T)
);

OBUFDS #(
    .IOSTANDARD("LVDS_25")
) IBUFDS_inst_0 (
    .O(CLK_O_P),
    .OB(CLK_O_N), 
    .I(CLK_I)
);

//IBUFDS #(
//    .IOSTANDARD("LVDS_25")
//) IBUFDS_inst_0 (
//    .O(CLK_O),
//    .I(CLK_I_P),
//    .IB(CLK_I_N)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_5 (
//    .O(DAT_O[5]),
//    .IO(DIF_P[5]),
//    .IOB(DIF_N[5]), 
//    .I(DAT_I[5]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_6 (
//    .O(DAT_O[6]),
//    .IO(DIF_P[6]),
//    .IOB(DIF_N[6]), 
//    .I(DAT_I[6]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_7 (
//    .O(DAT_O[7]),
//    .IO(DIF_P[7]),
//    .IOB(DIF_N[7]), 
//    .I(DAT_I[7]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_8 (
//    .O(DAT_O[8]),
//    .IO(DIF_P[8]),
//    .IOB(DIF_N[8]), 
//    .I(DAT_I[8]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_9 (
//    .O(DAT_O[9]),
//    .IO(DIF_P[9]),
//    .IOB(DIF_N[9]), 
//    .I(DAT_I[9]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_10 (
//    .O(DAT_O[10]),
//    .IO(DIF_P[10]),
//    .IOB(DIF_N[10]), 
//    .I(DAT_I[10]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_11 (
//    .O(DAT_O[11]),
//    .IO(DIF_P[11]),
//    .IOB(DIF_N[11]), 
//    .I(DAT_I[11]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_12 (
//    .O(DAT_O[12]),
//    .IO(DIF_P[12]),
//    .IOB(DIF_N[12]), 
//    .I(DAT_I[12]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_13 (
//    .O(DAT_O[13]),
//    .IO(DIF_P[13]),
//    .IOB(DIF_N[13]), 
//    .I(DAT_I[13]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_14 (
//    .O(DAT_O[14]),
//    .IO(DIF_P[14]),
//    .IOB(DIF_N[14]), 
//    .I(DAT_I[14]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_15 (
//    .O(DAT_O[15]),
//    .IO(DIF_P[15]),
//    .IOB(DIF_N[15]), 
//    .I(DAT_I[15]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_16 (
//    .O(DAT_O[16]),
//    .IO(DIF_P[16]),
//    .IOB(DIF_N[16]), 
//    .I(DAT_I[16]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_17 (
//    .O(),
//    .IO(DIF_P[17]),
//    .IOB(DIF_N[17]), 
//    .I(DAT_I[17]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_18 (
//    .O(DAT_O[18]),
//    .IO(DIF_P[18]),
//    .IOB(DIF_N[18]), 
//    .I(DAT_I[18]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_19 (
//    .O(DAT_O[19]),
//    .IO(DIF_P[19]),
//    .IOB(DIF_N[19]), 
//    .I(DAT_I[19]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_20 (
//    .O(DAT_O[20]),
//    .IO(DIF_P[20]),
//    .IOB(DIF_N[20]), 
//    .I(DAT_I[20]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_21 (
//    .O(DAT_O[21]),
//    .IO(DIF_P[21]),
//    .IOB(DIF_N[21]), 
//    .I(DAT_I[21]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_22 (
//    .O(DAT_O[22]),
//    .IO(DIF_P[22]),
//    .IOB(DIF_N[22]), 
//    .I(DAT_I[22]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_23 (
//    .O(DAT_O[23]),
//    .IO(DIF_P[23]),
//    .IOB(DIF_N[23]), 
//    .I(DAT_I[23]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_24 (
//    .O(DAT_O[24]),
//    .IO(DIF_P[24]),
//    .IOB(DIF_N[24]), 
//    .I(DAT_I[24]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_25 (
//    .O(DAT_O[25]),
//    .IO(DIF_P[25]),
//    .IOB(DIF_N[25]), 
//    .I(DAT_I[25]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_26 (
//    .O(DAT_O[26]),
//    .IO(DIF_P[26]),
//    .IOB(DIF_N[26]), 
//    .I(DAT_I[26]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_27 (
//    .O(DAT_O[27]),
//    .IO(DIF_P[27]),
//    .IOB(DIF_N[27]), 
//    .I(DAT_I[27]),
//    .T(DAT_T)
//);

//IOBUFDS #(
//    .IOSTANDARD("BLVDS_25")
//) IOBUFDS_inst_28 (
//    .O(DAT_O[28]),
//    .IO(DIF_P[28]),
//    .IOB(DIF_N[28]), 
//    .I(DAT_I[28]),
//    .T(DAT_T)
//);



endmodule
