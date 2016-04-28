`timescale 1ns / 1ps
   // For 5 pins
    module serializer (
        input clk,
        input [39:0] datin,   // 8 * pin_num - 1
        input start, 
        input [4:0] flag7E, // pin_num - 1
        
        output [4:0] serial // pin_num - 1
    );
    
    wire [49:0] encode; //  10 * pin_num - 1
    reg [54:0] frame;   //  11 * pin_num - 1
                
    
    
    initial begin
        frame <= 0;    
    end    
    
    always @(posedge clk)
    begin
        if(start) begin
            frame[9:0]   <= (flag7E) ? 10'h7E : encode[9:0];
            frame[20:11] <= (flag7E) ? 10'h7E : encode[19:10]; 
            frame[31:22] <= (flag7E) ? 10'h7E : encode[29:20]; 
            frame[42:33] <= (flag7E) ? 10'h7E : encode[39:30]; 
            frame[53:44] <= (flag7E) ? 10'h7E : encode[49:40];  
        end
        else begin 
            frame[9:0]   <= {frame[8:0],1'b0};
            frame[20:11] <= {frame[19:11],1'b0};
            frame[31:22] <= {frame[30:22],1'b0};
            frame[42:33] <= {frame[41:33],1'b0};
            frame[53:44] <= {frame[52:44],1'b0};  
        end 
            frame[10]  <= frame[9];
            frame[21]  <= frame[20];
            frame[32]  <= frame[31];
            frame[43]  <= frame[42];
            frame[54]  <= frame[53];           
    end
    
    assign serial = {frame[54],frame[43],frame[32],frame[21],frame[10]};
    

    encode enc_00 (
        .datain(datin[7:0]), 
        .dataout(encode[9:0])
    );
    encode enc_01 (
        .datain(datin[15:8]), 
        .dataout(encode[19:10])
    );
    encode enc_02 (
        .datain(datin[23:16]), 
        .dataout(encode[29:20])
    );
    encode enc_03 (
        .datain(datin[31:24]), 
        .dataout(encode[39:30])
    );
    encode enc_04 (
        .datain(datin[39:32]), 
        .dataout(encode[49:40])
    );    
    
    endmodule
    
     