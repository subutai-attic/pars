`timescale 1ns / 1ps

    module deserializer_8b (
        input wire clk,
        input wire reset_n,
        input wire [39:0] rxdin,
        output wire [39:0] rxdout,
        output reg [4:0] bitslip
    );
    
//    reg [4:0] bitslip;

    reg [39:0] rxdata;
    always @(posedge clk)
    begin
       if (reset_n == 1'b0) rxdata <= 0;
	   else 
	   rxdata <=   {rxdin[39] ,rxdin[34] ,rxdin[29], rxdin[24], rxdin[19], rxdin[14] ,rxdin[9]  ,rxdin[4],
                    rxdin[38] ,rxdin[33] ,rxdin[28], rxdin[23], rxdin[18], rxdin[13] ,rxdin[8]  ,rxdin[3],
                    rxdin[37] ,rxdin[32] ,rxdin[27], rxdin[22], rxdin[17], rxdin[12] ,rxdin[7]  ,rxdin[2],
                    rxdin[36] ,rxdin[31] ,rxdin[26], rxdin[21], rxdin[16], rxdin[11] ,rxdin[6]  ,rxdin[1],                                                                                       	            
                    rxdin[35] ,rxdin[30] ,rxdin[25], rxdin[20], rxdin[15], rxdin[10] ,rxdin[5]  ,rxdin[0]};    
    end
    
    assign rxdout = rxdata;
    
    reg [4:0] flag;
    reg [4:0] ready; 
    reg enable;
    reg lock;
    reg [4:0] bstate;

    always @( posedge clk )
    begin       
            if ( reset_n == 1'b0 ) begin
                enable  <= 1'b1;                          
                flag    <= 0;
                bitslip <= 0;
                ready <= 0;
                bstate  <= 5'h0;   
                lock <= 1;     
            end
            else if ( enable ) begin
                if ( rxdata[39:32] != 8'h7E ) 
                    flag[4] <= 1'b1;
                else if ( bstate[3]) 
                begin
                    ready[4] <= 1'b1;
                end                                  
                if ( rxdata[31:24] != 8'h7E ) 
                    flag[3] <= 1'b1;
                else if ( bstate[3]) 
                begin
                    ready[3] <= 1'b1;
                end
                if ( rxdata[23:16] != 8'h7E ) 
                    flag[2] <= 1'b1;
                else if ( bstate[3]) 
                begin
                    ready[2] <= 1'b1;
                end
                if ( rxdata[15:8] != 8'h7E ) 
                    flag[1] <= 1'b1;
                else if ( bstate[3] ) 
                begin
                    ready[1] <= 1'b1;
                end
                if ( rxdata[7:0] != 8'h7E ) 
                    flag[0] <= 1'b1;
                else if ( bstate[3] ) 
                begin
                    ready[0] <= 1'b1; 
                end
                
                lock <= 0;
                if ( ready[4:0] == 5'b11111 )
                begin
                    enable <= 0;
                end                                                
                                      
                if ( flag != 0 ) begin
                case ( bstate ) 
                    4'h0: begin
                        bstate <= 5'h1;
                        bitslip <= {flag[4],flag[3],flag[2],flag[1],flag[0]};
                    end
                    4'h1: begin
                        bstate <= 5'h2;
                        bitslip <= 0;
                    end
                    4'h2: begin
                        bstate <= 5'h3;
                    end
                    4'h3: begin
                        bstate <= 5'h4;
                    end   
                    4'h4: begin
                        bstate <= 5'h8;
                    end 
                    4'h8: begin
                        bstate <= 5'h0;
                        flag <= 0;
                    end                   
                endcase                                                         
                end                    
            end                
    end                      
    
//    decoder dec_00(
//        .datain(frame[shift + 9 -: 10]),
//        .dataout(dout2[7:0])
//    );
//    decoder dec_01(
//        .datain(ein[19:10]),
//        .dataout(dout[15:8])
//    ); 
//    decoder dec_02(
//        .datain(ein[29:20]),
//        .dataout(dout[23:16])
//    ); 
//    decoder dec_03(
//        .datain(ein[39:30]),
//        .dataout(dout[31:24])
//    ); 
//    decoder dec_04(
//        .datain(ein[49:40]),
//        .dataout(dout[39:32])
//    );                     

    endmodule
