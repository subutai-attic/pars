`timescale 1ns / 1ps

module fifo18Kb(
    input aclk,
    input sd_clk,
    input rst,
    input [31:0] axi_data_in,
    input [31:0] sd_data_in,
    output [31:0] sd_data_out,
    output [31:0] axi_data_out,
    input sd_rd_en,
    input axi_rd_en,
    input axi_wr_en,
    input sd_wr_en,
    output sd_full_o
    );

  wire [3:0] axi_dip;
  wire [3:0] sd_dip;
  wire parity_out0;
  wire parity_out1;
  wire parity_out2;
  wire parity_out3;
  wire parity_out4;
  wire parity_out5;
  wire parity_out6;
  wire parity_out7;

//  wire sd_clk;

assign parity_out0 = axi_data_in[0] ^ axi_data_in[1] ^ axi_data_in[2] ^ axi_data_in[3] ^ axi_data_in[4] ^ axi_data_in[5] ^ axi_data_in[6] ^ axi_data_in[7];
assign parity_out1 = axi_data_in[8] ^ axi_data_in[9] ^ axi_data_in[10] ^ axi_data_in[11] ^ axi_data_in[12] ^ axi_data_in[13] ^ axi_data_in[14] ^ axi_data_in[15];
assign parity_out2 = axi_data_in[16] ^ axi_data_in[17] ^ axi_data_in[18] ^ axi_data_in[19] ^ axi_data_in[20] ^ axi_data_in[21] ^ axi_data_in[22] ^ axi_data_in[23];
assign parity_out3 = axi_data_in[24] ^ axi_data_in[25] ^ axi_data_in[26] ^ axi_data_in[27] ^ axi_data_in[28] ^ axi_data_in[29] ^ axi_data_in[30] ^ axi_data_in[31];

assign parity_out4 = sd_data_in[0] ^ sd_data_in[1] ^ sd_data_in[2] ^ sd_data_in[3] ^ sd_data_in[4] ^ sd_data_in[5] ^ sd_data_in[6] ^ sd_data_in[7];
assign parity_out5 = sd_data_in[8] ^ sd_data_in[9] ^ sd_data_in[10] ^ sd_data_in[11] ^ sd_data_in[12] ^ sd_data_in[13] ^ sd_data_in[14] ^ sd_data_in[15];
assign parity_out6 = sd_data_in[16] ^ sd_data_in[17] ^ sd_data_in[18] ^ sd_data_in[19] ^ sd_data_in[20] ^ sd_data_in[21] ^ sd_data_in[22] ^ sd_data_in[23];
assign parity_out7 = sd_data_in[24] ^ sd_data_in[25] ^ sd_data_in[26] ^ sd_data_in[27] ^ sd_data_in[28] ^ sd_data_in[29] ^ sd_data_in[30] ^ sd_data_in[31];


assign axi_dip = {parity_out0,parity_out1,parity_out2,parity_out3};
assign sd_dip = {parity_out4,parity_out5,parity_out6,parity_out7};
  
  
  FIFO18E1 #(
  .ALMOST_EMPTY_OFFSET(13'h000A),    // Sets the almost empty threshold
  .ALMOST_FULL_OFFSET(13'h0080),     // Sets almost full threshold
  .DATA_WIDTH(36),                   // Sets data width to 4-36
  .DO_REG(1),                       // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
  .EN_SYN("FALSE"),                 // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
  .FIFO_MODE("FIFO18_36"),               // Sets mode to FIFO18 or FIFO18_36
  .FIRST_WORD_FALL_THROUGH("TRUE"), // Sets the FIFO FWFT to FALSE, TRUE
  .INIT(36'h000000000),               // Initial values on output port
  .SIM_DEVICE("7SERIES"),             // Must be set to "7SERIES" for simulation behavior
  .SRVAL(36'h000000000)               // Set/Reset value for output port
  )
  FIFO18E1_inst0 (
  // Read Data: 32-bit (each) output: Read output data
  .DO(sd_data_out),                               // 32-bit output: Data output
  .DOP(),                              // 4-bit output: Parity data output
  // Status: 1-bit (each) output: Flags and other FIFO status outputs
  .ALMOSTEMPTY(),              // 1-bit output: Almost empty flag
  .ALMOSTFULL(),                // 1-bit output: Almost full flag
  .EMPTY(),                          // 1-bit output: Empty flag
  .FULL(),                            // 1-bit output: Full flag
  .RDCOUNT(),                      // 12-bit output: Read count
  .RDERR(),                          // 1-bit output: Read error
  .WRCOUNT(),                      // 12-bit output: Write count
  .WRERR(),                          // 1-bit output: Write error
  // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
  .RDCLK(sd_clk),                         // 1-bit input: Read clock
  .RDEN(sd_rd_en),                            // 1-bit input: Read enable
  .REGCE(1),                              // 1-bit input: Clock enable
  .RST(rst),                             // 1-bit input: Asynchronous Reset
  .RSTREG(rst),                          // 1-bit input: Output register set/reset
  // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
  .WRCLK(aclk),                            // 1-bit input: Write clock
  .WREN(axi_wr_en),                            // 1-bit input: Write enable
  // Write Data: 32-bit (each) input: Write input data
  .DI(axi_data_in),                               // 32-bit input: Data input
  .DIP(axi_dip)                               // 4-bit input: Parity input
  );
  
  
  
  FIFO18E1 #(
  .ALMOST_EMPTY_OFFSET(13'h000A),    // Sets the almost empty threshold
  .ALMOST_FULL_OFFSET(13'h0080),     // Sets almost full threshold
  .DATA_WIDTH(36),                   // Sets data width to 4-36
  .DO_REG(1),                       // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
  .EN_SYN("FALSE"),                 // Specifies FIFO as dual-clock (FALSE) or Synchronous (TRUE)
  .FIFO_MODE("FIFO18_36"),               // Sets mode to FIFO18 or FIFO18_36
  .FIRST_WORD_FALL_THROUGH("TRUE"), // Sets the FIFO FWFT to FALSE, TRUE
  .INIT(36'h000000000),               // Initial values on output port
  .SIM_DEVICE("7SERIES"),             // Must be set to "7SERIES" for simulation behavior
  .SRVAL(36'h000000000)               // Set/Reset value for output port
  )
  FIFO18E1_inst1 (
  // Read Data: 32-bit (each) output: Read output data
  .DO(axi_data_out),                               // 32-bit output: Data output
  .DOP(),                              // 4-bit output: Parity data output
  // Status: 1-bit (each) output: Flags and other FIFO status outputs
  .ALMOSTEMPTY(),              // 1-bit output: Almost empty flag
  .ALMOSTFULL(),                // 1-bit output: Almost full flag
  .EMPTY(),                          // 1-bit output: Empty flag
  .FULL(sd_full_o),                            // 1-bit output: Full flag
  .RDCOUNT(),                      // 12-bit output: Read count
  .RDERR(),                          // 1-bit output: Read error
  .WRCOUNT(),                      // 12-bit output: Write count
  .WRERR(),                          // 1-bit output: Write error
  // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
  .RDCLK(aclk),                         // 1-bit input: Read clock
  .RDEN(axi_rd_en),                            // 1-bit input: Read enable
  .REGCE(1),                              // 1-bit input: Clock enable
  .RST(rst),                             // 1-bit input: Asynchronous Reset
  .RSTREG(rst),                          // 1-bit input: Output register set/reset
  // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
  .WRCLK(sd_clk),                           // 1-bit input: Write clock
  .WREN(sd_wr_en),                            // 1-bit input: Write enable
  // Write Data: 32-bit (each) input: Write input data
  .DI(sd_data_in),                               // 32-bit input: Data input
  .DIP(sd_dip)                               // 4-bit input: Parity input
  );


  // End of FIFO18E1_inst instantiation
    
endmodule
