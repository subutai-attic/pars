`timescale 1ns / 1ps

    module serializer_5bit (
        input clk,
        input reset,
        input [4:0] data_i,
        input start_i,
        output lvds_busy,
        output serial_o
    );
     
    reg lvds_busy;
    reg [3:0] checker;
    reg [4:0] frame;
    reg start;
    
    // STATE MASHINE   
    reg [1:0] state = 2'b01;    
    localparam INIT =        2'b01;
    localparam FRAME_SEND =   2'b10;
    
    always @ (posedge clk)
    begin: STATE_MASHINE
        case(state)
            
        INIT: begin
            state <= FRAME_SEND;                 
        end
                
        FRAME_SEND: begin
            if (checker == 5) state <= INIT;  
        end 
                  
        endcase
    end  
    
    assign serial_o = frame[4]; //back and comment assign down
    
    always @ (posedge clk)
    begin: EX
        case(state)
        
        INIT: begin
            checker <= 0;
            frame <= 0;  
            start <= 0; 
            lvds_busy <= 0;             
        end 
                   
        FRAME_SEND: begin
            if (start_i && checker == 0) begin                   
                frame <= data_i;
                start <= 1;
                lvds_busy <= 1;
            end                    
            else if (start)
                frame <= {frame, 1'b0}; 
                      
            if ((start_i && checker == 0) | start) 
                checker <= checker + 1;           
            if (checker == 5) lvds_busy <= 0;                                                                                                                      
            end
        endcase
    end       
     
    endmodule
    
