`timescale 1ns / 1ps

module IDDR_p(
    input reset,
    input clock,
    input  wire [7:0] in_ddr,
    output wire [7:0] iddr_Q1,
    output wire [7:0] iddr_Q2
    );
          
  IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst0 (
  .Q1(iddr_Q1[0]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[0]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[0]),
  .R(reset),
  .S(1'b0)
  );
  
    IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst1 (
  .Q1(iddr_Q1[1]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[1]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[1]),
  .R(reset),
  .S(1'b0)
  );

  IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst2 (
  .Q1(iddr_Q1[2]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[2]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[2]),
  .R(reset),
  .S(1'b0)
  );

  IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst3 (
  .Q1(iddr_Q1[3]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[3]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[3]),
  .R(reset),
  .S(1'b0)
  );

  IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst4 (
  .Q1(iddr_Q1[4]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[4]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[4]),
  .R(reset),
  .S(1'b0)
  );

  IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst5 (
  .Q1(iddr_Q1[5]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[5]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[5]),
  .R(reset),
  .S(1'b0)
  );

  IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst6 (
  .Q1(iddr_Q1[6]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[6]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[6]),
  .R(reset),
  .S(1'b0)
  );

  IDDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE")   // "OPPOSITE_EDGE", "SAME_EDGE"
                                    //  or "SAME_EDGE_PIPELINED"
//  .INIT_Q1(1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
//  .INIT_Q2(1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
//  .SRTYPE("SYNC")                   // Set/Reset type: "SYNC" or "ASYNC"
  ) IDDR_inst7 (
  .Q1(iddr_Q1[7]),                          // 1-bit output for positive edge of clock
  .Q2(iddr_Q2[7]),                          // 1-bit output for negative edge of clock
  .C(clock),
  .CE(1'b1),                          // 1-bit clock enable input
  .D(in_ddr[7]),
  .R(reset),
  .S(1'b0)
  );

endmodule
