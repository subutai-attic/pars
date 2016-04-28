`timescale 1ns / 1ps
   // For 5 pins
    module serializer (
        input clk,
        input din,   
        input serd_cmd,
//        input [4:0] flag7E, 
        
        output dout 
    );
    
   // input ports
    wire [31:0] din;
    wire [1:0] serd_cmd;
        
   // output ports    
    wire [39:0] dout;
    
   // internal wires and registers    
    wire [39:0] encode; 
    reg [39:0] data;
        
    initial begin
        data <= 0;    
    end    
    
    always @(posedge clk)
    begin
        if ( serd_cmd == 2'b01 ) begin
            data [39:0] <= {5{8'h7E}};
//            frame[9:0]   <= (flag7E) ? 10'h7E : encode[9:0];
//            frame[20:11] <= (flag7E) ? 10'h7E : encode[19:10]; 
//            frame[31:22] <= (flag7E) ? 10'h7E : encode[29:20]; 
//            frame[42:33] <= (flag7E) ? 10'h7E : encode[39:30]; 
//            frame[53:44] <= (flag7E) ? 10'h7E : encode[49:40];  
        end
//        else begin 
//            frame[9:0]   <= {frame[8:0],1'b0};
//            frame[20:11] <= {frame[19:11],1'b0};
//            frame[31:22] <= {frame[30:22],1'b0};
//            frame[42:33] <= {frame[41:33],1'b0};
//            frame[53:44] <= {frame[52:44],1'b0};  
//        end 
//            frame[10]  <= frame[9];
//            frame[21]  <= frame[20];
//            frame[32]  <= frame[31];
//            frame[43]  <= frame[42];
//            frame[54]  <= frame[53];           
    end
    
    assign dout  = {data[23] ,data[31] ,data[23], data[15], data[7],
                    data[22] ,data[30] ,data[22], data[14], data[6], 
                    data[21] ,data[29] ,data[21], data[13], data[5],
                    data[20] ,data[28] ,data[20], data[12], data[4],
                    data[19] ,data[27] ,data[19], data[11], data[3],
                    data[18] ,data[26] ,data[18], data[10], data[2],
                    data[17] ,data[25] ,data[17], data[9] , data[1],
                    data[16] ,data[24] ,data[16], data[8] , data[0]};    
    
//    assign serial = {frame[54],frame[43],frame[32],frame[21],frame[10]};
    
//    assign eout[9:0]  = (din[7:0] ==  8'h7E) ? 10'h7E : encode[9:0];
//    assign eout[39:10] = 30'h0;
//    assign eout[15:10] = 6'b000000;
//    assign eout[9:0]   = {2'b0,din[7:0]};
//    assign eout[19:10] = flag7E[1] ? 10'h7E : encode[19:10]; 
//    assign eout[29:20] = flag7E[2] ? 10'h7E : encode[29:20];
//    assign eout[39:30] = flag7E[3] ? 10'h7E : encode[39:30];
//    assign eout[49:40] = flag7E[4] ? 10'h7E : encode[49:40];

    encode enc_00 (
        .datain(din[7:0]), 
        .dataout(encode[9:0])
    );
    encode enc_01 (
        .datain(din[15:8]), 
        .dataout(encode[19:10])
    );
    encode enc_02 (
        .datain(din[23:16]), 
        .dataout(encode[29:20])
    );
    encode enc_03 (
        .datain(din[31:24]), 
        .dataout(encode[39:30])
    );   
    
    endmodule
    
     