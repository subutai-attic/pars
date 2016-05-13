`timescale 1ns / 1ps

   // For 5 pins
    module serializer (
        input clk,
        input reset_n,
        input wire [31:0] din,   
        input wire [1:0] serd_cmd,
//        input [4:0] flag7E,
        output wire [23:0] dout1,
        output wire [15:0] dout2
    );

   // internal wires and registers    
    wire [39:0] encode;
    reg [39:0] data;
    always @(posedge clk)
    begin       
        if (reset_n == 1'b0) data <= 0;
        else data[39:0] <= {5{8'h7E}};
    end
    //change serd_cmd to tristate
    assign dout1[23:0] = (!serd_cmd[0]) ? {data[23], data[15], data[7],
                                          data[22], data[14], data[6],
                                          data[21], data[13], data[5],
                                          data[20], data[12], data[4],
                                          data[19], data[11], data[3],
                                          data[18], data[10], data[2],
                                          data[17], data[9] , data[1],
                                          data[16], data[8] , data[0]} : 0;
//    assign dout2[15:0] = (serd_cmd[1]) ? 16'h7E7E : 0;
    assign dout2[15:0] = (!serd_cmd[1]) ?  {data[39], data[31],
                                           data[38], data[30],
                                           data[37], data[29],
                                           data[36], data[28],
                                           data[35], data[27],
                                           data[34], data[26],
                                           data[33], data[25],
                                           data[32], data[24]} : 0;                              

    endmodule