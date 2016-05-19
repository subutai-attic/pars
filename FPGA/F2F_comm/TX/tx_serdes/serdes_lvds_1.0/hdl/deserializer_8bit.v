`timescale 1ns / 1ps

    module deserializer_8b (
        input wire clk,
        input wire reset_n,
        input wire [1:0] serd_cmd,        
        input wire [23:0] din1,
        input wire [15:0] din2,        
        output wire [23:0] dout1,
        output wire [15:0] dout2,        
        output reg [4:0] bitslip
    );
    
    reg [39:0] rxdata;
    always @( posedge clk )
    begin
       if (reset_n == 1'b0) rxdata <= 0;
	   else 
	  // Used for shift data only on 8 bit 
	   rxdata[23:0] <=    {din1[23] ,din1[20] ,din1[17], din1[14], din1[11], din1[8] ,din1[5]  ,din1[2],
                           din1[22] ,din1[19] ,din1[16], din1[13], din1[10], din1[7] ,din1[4]  ,din1[1],                                                                                       	            
                           din1[21] ,din1[18] ,din1[15], din1[12], din1[9],  din1[6] ,din1[3]  ,din1[0]};  

	   rxdata[39:24] <=   {din2[15] ,din2[13] ,din2[11], din2[9], din2[7], din2[5] ,din2[3]  ,din2[1],                                                                                       	            
                           din2[14] ,din2[12] ,din2[10], din2[8], din2[6], din2[4] ,din2[2]  ,din2[0]};                       
    end
    
    
    assign dout1 = (!enable[0]) ? rxdata[23:0] : 0;
    assign dout2 = (!enable[1]) ? rxdata[39:24] : 0; 
    
    reg [4:0] flag;
    reg [4:0] ready; 
    reg [1:0] enable;
    reg [4:0] bstate1;
    reg [4:0] bstate2;    
   // Two state bitslip operation to sync 2 separated io_wizards
    always @( posedge clk )
    begin       
            if ( reset_n == 1'b0 ) begin
                enable  <= 2'b11;                          
                flag    <= 0;
                bitslip <= 0;
                ready <= 0;
                bstate1  <= 5'h0;   
                bstate2  <= 5'h0;                   
            end
            else begin 
            if ( enable[1] && serd_cmd[1] ) begin
                if ( rxdata[39:32] != 8'h7E ) 
                    flag[4] <= 1'b1;
                else if ( bstate2[3] ) 
                begin
                    ready[4] <= 1'b1;
                end   
                
                if ( rxdata[31:24] != 8'h7E ) 
                    flag[3] <= 1'b1;
                else if ( bstate2[3] ) 
                begin
                    ready[3] <= 1'b1;
                end
                                
                if ( ready[4:3] == 2'b11 )
                begin
                    if ( rxdata[39:24] == 16'h7E7E ) enable[1] <= 1'b0;
                    else ready[4:3] <= 2'b00;
                end                                                
                                      
                if ( flag != 0 ) begin
                case ( bstate2 ) 
                    4'h0: begin
                        bstate2 <= 5'h1;
                        bitslip[4:3] <= {flag[4],flag[3]};
                    end
                    4'h1: begin
                        bstate2 <= 5'h2;
                        bitslip <= 0;
                    end
                    4'h2: begin
                        bstate2 <= 5'h3;
                    end
                    4'h3: begin
                        bstate2 <= 5'h4;
                    end   
                    4'h4: begin
                        bstate2 <= 5'h8;
                    end 
                    4'h8: begin
                        bstate2 <= 5'h0;
                        flag <= 0;
                    end                   
                endcase                                                         
                end                    
            end // end of enable[1]   

            if ( enable[0] && serd_cmd[0] ) begin
                if ( rxdata[23:16] != 8'h7E ) 
                    flag[2] <= 1'b1;
                else if ( bstate1[3] ) 
                begin
                    ready[2] <= 1'b1;
                end
                            
                if ( rxdata[15:8] != 8'h7E ) 
                    flag[1] <= 1'b1;
                else if ( bstate1[3] ) 
                begin
                    ready[1] <= 1'b1;
                end   
                
                if ( rxdata[7:0] != 8'h7E ) 
                    flag[0] <= 1'b1;
                else if ( bstate1[3] ) 
                begin
                    ready[0] <= 1'b1;
                end
                                
                if ( ready[2:0] == 3'b111 )
                begin
                    if ( rxdata[23:0] == 24'h7E7E7E ) enable[0] <= 1'b0;
                    else ready[2:0] <= 2'b00;                
                end                                                
                                      
                if ( flag != 0 ) begin
                case ( bstate1 ) 
                    4'h0: begin
                        bstate1 <= 5'h1;
                        bitslip[2:0] <= {flag[2],flag[1],flag[0]};
                    end
                    4'h1: begin
                        bstate1 <= 5'h2;
                        bitslip <= 0;
                    end
                    4'h2: begin
                        bstate1 <= 5'h3;
                    end
                    4'h3: begin
                        bstate1 <= 5'h4;
                    end   
                    4'h4: begin
                        bstate1 <= 5'h8;
                    end 
                    4'h8: begin
                        bstate1 <= 5'h0;
                        flag <= 0;
                    end                   
                endcase                                                         
                end                    
            end // end of enable[0]  
         end                           
    end // end of always block                                          

    endmodule