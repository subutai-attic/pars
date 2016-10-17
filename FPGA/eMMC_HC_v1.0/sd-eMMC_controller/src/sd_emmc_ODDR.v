`timescale 1ns / 1ps

module ODDR_p(
  input reset,
  input clock,
//  input [31:0] fifo_data_in,
  input [7:0] d1_wire,
  input [7:0] d2_wire,
  output [7:0] oq
  );

 
  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst0 (
  .Q(oq[0]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[0]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[0]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );
  
  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst1 (
  .Q(oq[1]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[1]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[1]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );

  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst2 (
  .Q(oq[2]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[2]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[2]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );

  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst3 (
  .Q(oq[3]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[3]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[3]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );

  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst4 (
  .Q(oq[4]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[4]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[4]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );

  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst5 (
  .Q(oq[5]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[5]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[5]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );

  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst6 (
  .Q(oq[6]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[6]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[6]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );

  ODDR  #(.DDR_CLK_EDGE("OPPOSITE_EDGE"),  // "SAME_EDGE" or "OPPOSITE_EDGE"
  .INIT(1'b1),                             // Initial value of    Q:1'b0 or 1'b1
  .SRTYPE("SYNC")                          // Set/Reset type: "SYNC" or "ASYNC"
  ) ODDR_inst7 (
  .Q(oq[7]),                                  // 1-bit DDR output
  .C(clock),                              // 1-bit clock input
  .CE(1'b1),                               // 1-bit clock enable input
  .D1(d1_wire[7]),                            // 1-bit data  input (positive edge)
  .D2(d2_wire[7]),                            // 1-bit data  input (negative edge)
  .R(reset),                                 // 1-bit reset
  .S(1'b0)                                    // 1-bit set
  );

//  reg byte_alignment_reg;
  
//  always @(posedge clock) begin
//    if (reset == 0) begin
//      byte_alignment_reg <= 0;
//      d1_reg <= 8'hff;
//      d2_reg <= 8'hff;
//    end
//    else begin
    
//      byte_alignment_reg <= ~byte_alignment_reg;

//      d2_reg <= {fifo_data_in[31-(byte_alignment_reg << 4)],
//                 fifo_data_in[30-(byte_alignment_reg << 4)],
//                 fifo_data_in[29-(byte_alignment_reg << 4)],
//                 fifo_data_in[28-(byte_alignment_reg << 4)],
//                 fifo_data_in[27-(byte_alignment_reg << 4)],
//                 fifo_data_in[26-(byte_alignment_reg << 4)],
//                 fifo_data_in[25-(byte_alignment_reg << 4)],
//                 fifo_data_in[24-(byte_alignment_reg << 4)]
//                };
//      d1_reg <= {fifo_data_in[23-(byte_alignment_reg << 4)],
//                 fifo_data_in[22-(byte_alignment_reg << 4)],
//                 fifo_data_in[21-(byte_alignment_reg << 4)],
//                 fifo_data_in[20-(byte_alignment_reg << 4)],
//                 fifo_data_in[19-(byte_alignment_reg << 4)],
//                 fifo_data_in[18-(byte_alignment_reg << 4)],
//                 fifo_data_in[17-(byte_alignment_reg << 4)],
//                 fifo_data_in[16-(byte_alignment_reg << 4)]
//                };
//    end
//  end
  
endmodule
