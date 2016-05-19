
`timescale 1 ns / 1 ps

    module stream_controller_v1_0 #
    (
       parameter LVDS_PIN_NUMBER = 4,
       parameter DATA_WIDTH = 32
    )
    (       
       input wire clk,
       input wire reset_n,
       input wire [23:0] din1,
       input wire [15:0] din2,              
//       input empty,
//       input [31:0] din,
//       output rd_en,
       output wire txclk,
       output wire txclk_div,
       output wire reset,
       output wire [23:0] dout1,
       output wire [15:0] dout2,
       output reg [1:0] serd_cmd,
       output wire [31:0] dout,
       output wire [31:0] debug

    );
    assign debug[5:0] = state;
    
    reg [31:0] rcv_buf;
    reg [5:0] state      = 5'b000001;
    parameter INIT       = 5'b000001;
    parameter HANDSHAKE1 = 5'b000010;
    parameter HANDSHAKE2 = 5'b000100; 
    parameter RECEIVE    = 5'b001000;             

   // Three level handshake. 1) Receive 7E7E on 16bit io_wizard, and send 7E7E7E on 24bit io_wizard
   // 2) Receive 7E7E7E on 24 bit serializer and send 7E7E on 16bit io_wizard.
   // 3) Receive start bit of the frame(for example 7E) on 24bit io_wizard and start to collect data. 
    always @( posedge clk )
    begin: STM
       case(state)
           INIT: begin
               if ( reset_n ) state <= HANDSHAKE1;               
           end
           HANDSHAKE1: begin
                if ( din2 == 16'h7E7E ) state <= HANDSHAKE2;
           end
           HANDSHAKE2: begin //change this condition 
               if ( din1[9:0] == 10'h7E ) state <= RECEIVE;               
           end   
           RECEIVE: begin
                
           end                    
       endcase
    end

    always @( posedge clk )
    begin: EX
       case(state)
           INIT: begin
                serd_cmd <= 0;
                
                rcv_buf <= 0;
           end
           HANDSHAKE1: begin
                if ( din1 == 24'h7E7E7E )
                    serd_cmd <= 2'b01;
                else 
                    serd_cmd <= 2'b11;
           end
           HANDSHAKE2: begin
                if ( din2 == 16'h7E7E )
                    serd_cmd <= 2'b10;
                else 
                    serd_cmd <= 2'b11;
               // Start of the data frame     
                if ( serd_cmd[0] && din1[9:0] == 10'h7E )
                begin
                    rcv_buf[7:0]   <= (din1[9:0] != 10'h7E) ? decode[7: 0] : 8'h7E;
                    rcv_buf[15:8]  <= (din1[19:10] != 10'h7E) ? decode[15:8] : 8'h7E;
                    rcv_buf[23:16] <= ({din2[5:0],din1[23:20]} != 10'h7E) ? decode[23:16] : 8'h7E;
                    rcv_buf[31:24] <= (din2[15:6] != 10'h7E) ? decode[31:24] : 8'h7E;
                end                                                            
           end 
           RECEIVE: begin
               rcv_buf[7:0]   <= (din1[9:0] != 10'h7E) ? decode[7: 0] : 8'h7E;
               rcv_buf[15:8]  <= (din1[19:10] != 10'h7E) ? decode[15:8] : 8'h7E;
               rcv_buf[23:16] <= ({din2[5:0],din1[23:20]} != 10'h7E) ? decode[23:16] : 8'h7E;
               rcv_buf[31:24] <= (din2[15:6] != 10'h7E) ? decode[31:24] : 8'h7E;                    
           end                       
        endcase
    end
    
    wire [31:0] decode;
      assign dout1[23:0] = rcv_buf[23:0];
      assign dout2[7:0] = rcv_buf[31:24];
      assign dout[31:0] = rcv_buf[31:0];
       
    decoder dec_00(
        .datain(din1[9:0]),
        .dataout(decode[7:0])
    );    
    decoder dec_01(
        .datain(din1[19:10]),
        .dataout(decode[15:8])
    ); 
    decoder dec_02(
        .datain({din2[5:0],din1[23:20]}),
        .dataout(decode[23:16])
    ); 
    decoder dec_03(
        .datain(din2[15:6]),
        .dataout(decode[31:24])
    );                

//    wire CLKFBOUT;
//    assign reset = ~reset_n;
//    PLLE2_ADV #(
//          .BANDWIDTH        ("OPTIMIZED"),          
//          .CLKFBOUT_MULT        (8),   //8            
//          .CLKFBOUT_PHASE        (0.0),                 
//          .CLKIN1_PERIOD        (10.000), //10         
//          .CLKIN2_PERIOD        (10.000),     //10     
//          .CLKOUT0_DIVIDE        (8),         //4
//          .CLKOUT0_DUTY_CYCLE    (0.5),                 
//          .CLKOUT0_PHASE        (0.0),                 
//          .CLKOUT1_DIVIDE        (32),   //20        
//          .CLKOUT1_DUTY_CYCLE    (0.5),                 
//          .CLKOUT1_PHASE        (0.0),                 
//          .CLKOUT2_DIVIDE        (0.0),           
//          .CLKOUT2_DUTY_CYCLE    (0.5),                 
//          .CLKOUT2_PHASE        (0.0),                 
//          .CLKOUT3_DIVIDE        (),                   
//          .CLKOUT3_DUTY_CYCLE    (0.5),                 
//          .CLKOUT3_PHASE        (0.0),                 
//          .CLKOUT4_DIVIDE        (),                   
//          .CLKOUT4_DUTY_CYCLE    (0.5),                 
//          .CLKOUT4_PHASE        (0.0),                  
//          .CLKOUT5_DIVIDE        (),                   
//          .CLKOUT5_DUTY_CYCLE    (0.5),                 
//          .CLKOUT5_PHASE        (0.0),                  
//          .COMPENSATION        ("ZHOLD"),             
//          .DIVCLK_DIVIDE        (1),                    
//          .REF_JITTER1        (0.100))                   

//    tx_mmcme2_adv_inst (
//          .CLKFBOUT            (CLKFBOUT),                  
//          .CLKOUT0            (txclk),              
//          .CLKOUT1            (txclk_div),              
//          .CLKOUT2            (),                 
//          .CLKOUT3            (),                      
//          .CLKOUT4            (),                      
//          .CLKOUT5            (),                      
//          .DO            (),                            
//          .DRDY            (),                          
//          .PWRDWN            (1'b0),  
//          .LOCKED            (),                
//          .CLKFBIN            (CLKFBOUT),            
//          .CLKIN1            (clk),                 
//          .CLKIN2            (1'b0),                     
//          .CLKINSEL            (1'b1),                     
//          .DADDR            (7'h00),                    
//          .DCLK            (1'b0),                       
//          .DEN            (1'b0),                        
//          .DI            (16'h0000),                
//          .DWE            (1'b0),                        
//          .RST            (reset)) ;   
//	       WAIT: begin
//	           if (!empty) begin
//	               state <= FRAME;
//               end	               
//	       end
//	       FRAME: begin
//	          // TO DO: simplify this, but check for delays
//	           if (buf_ptr == LVDS_PIN_NUMBER && !ch_on)
//	               state <= SEND;
//               else if (buf_ptr == LVDS_PIN_NUMBER && send_on)
//                   state <= SEND;
//               else if (empty && !ch_on)
//                   state <= SEND;                   
//               else if (empty && send_on)
//                   state <= SEND;                    	                                                                                          	               
	           
//	       end
//	       SEND: begin
//	           if (frame_end) 
//	               state <= WAIT2;
//               else  	               
//	               state <= REST;	               
//	       end
//	       REST: begin
//	           state <= FRAME;
//	       end
//	       WAIT2: begin
//	           if (wait2ch == 9) state <= INIT;
//	       end
//	   endcase
//	end 
	
       	       
//	       WAIT: begin
//	           if (!empty) begin
//	               dat_buf[buf_ptr * 8 + 7 -: 8] <= 8'h7E;
//	               buf_ptr <= buf_ptr + 1;
//	               //rd_en <= 1'b1; 
//	           end
//	       end 
//	       FRAME: begin 
//	           if (!empty && buf_ptr < LVDS_PIN_NUMBER - 4)
//	           begin
//	               dat_buf[buf_ptr * 8 + 7  -: 8] <= din[7 : 0];
//	               dat_buf[buf_ptr * 8 + 15 -: 8] <= din[15: 8];
//	               dat_buf[buf_ptr * 8 + 23 -: 8] <= din[23:16];
//	               dat_buf[buf_ptr * 8 + 31 -: 8] <= din[31:24];
//	               buf_ptr <= buf_ptr + 4;
//	               //rd_en <= 1'b1;
//	           end
	           
//	           else if (!empty && buf_ptr == LVDS_PIN_NUMBER - 4) 
//	           begin
//	               dat_buf[buf_ptr * 8 + 7  -: 8] <= din[7 : 0];
//	               dat_buf[buf_ptr * 8 + 15 -: 8] <= din[15: 8];
//	               dat_buf[buf_ptr * 8 + 23 -: 8] <= din[23:16];
//	               dat_buf[buf_ptr * 8 + 31 -: 8] <= din[31:24];
//	               buf_ptr <= buf_ptr + 4;
//	           end
	           
//	           else if (!empty && buf_ptr == LVDS_PIN_NUMBER - 3) 
//	           begin
//	               dat_buf[buf_ptr * 8 + 7  -: 8] <= din[7 : 0];
//	               dat_buf[buf_ptr * 8 + 15 -: 8] <= din[15: 8];
//	               dat_buf[buf_ptr * 8 + 23 -: 8] <= din[23:16];
//	               buf_ptr <= buf_ptr + 3;
//	               dat_rest[7:0] <= din[31:24];
//	               rest_ptr[0] <= 1'b1;
//	               //rd_en <= 1'b0;
//	           end	           
	           
//	           else if (!empty && buf_ptr == LVDS_PIN_NUMBER - 2) 
//	           begin
//	               dat_buf[buf_ptr * 8 + 7  -: 8] <= din[7 : 0];
//	               dat_buf[buf_ptr * 8 + 15 -: 8] <= din[15: 8];
//	               buf_ptr <= buf_ptr + 2;
//	               dat_rest[7 :0] <= din[23:16];
//	               dat_rest[15:8] <= din[31:24];
//	               rest_ptr[1] <= 1'b1;
//	               //rd_en <= 1'b0;
//	           end	           
	           
//	           else if (!empty && buf_ptr == LVDS_PIN_NUMBER - 1) 
//	           begin
//	               dat_buf[buf_ptr * 8 + 7  -: 8] <= din[7 : 0];
	               
//	               dat_rest[7 : 0] <= din[15: 8];
//	               dat_rest[15: 8] <= din[23:16];
//	               dat_rest[23:16] <= din[31:24];
//	               buf_ptr <= buf_ptr + 1;
//	               rest_ptr[2] <= 1'b1;
//	               //rd_en <= 1'b0;
//	           end
	           
//	           else if (empty && buf_ptr != LVDS_PIN_NUMBER) begin
//                   dat_buf[buf_ptr * 8 + 7  -: 8] <= 8'h7E;
//                   frame_end <= 1'b1;	               
//	           end
	           
//	       end // of FRAME
//	       SEND: begin
//	           buf_ptr <= 0;
//	           dat_buf <= 0;
//	           frame_end <= 0;
//	           ch_on <= 1'b1;
//	           //checker <= 2'h2;
//	       end
//	       WAIT2: begin
//	           wait2ch <= wait2ch + 1;
//	       end
//	       REST: begin
//	           case(rest_ptr)
//	               3'b100: begin
//	                   rest_ptr <= 0;
//                       dat_buf[buf_ptr * 8 + 7  -: 8] <= dat_rest[7 : 0];
//                       dat_buf[buf_ptr * 8 + 15 -: 8] <= dat_rest[15: 8];
//                       dat_buf[buf_ptr * 8 + 23 -: 8] <= dat_rest[23:16];
//                       buf_ptr <= 3;
//	               end
//	               3'b010: begin
//	                   rest_ptr <= 0;
//                       dat_buf[buf_ptr * 8 + 7  -: 8] <= dat_rest[7 : 0];
//                       dat_buf[buf_ptr * 8 + 15 -: 8] <= dat_rest[15: 8];
//                       buf_ptr <= 2;
//	               end
//	               3'b001: begin
//	                   rest_ptr <= 0;
//                       dat_buf[buf_ptr * 8 + 7  -: 8] <= dat_rest[7 : 0];
//                       buf_ptr <= 1;	               
//	               end	               	               
//	           endcase
//	       end // of REST
	       
//	   endcase
//	end
//	always @(posedge clk)
//	begin
//	   if (state[0]) begin
//	        checker <= 0;
//	        send_on <= 0;
//       end	       
//	   else if (state[3]) checker <= 2'h2;
//	   else if (ch_on && checker == 9) begin
//	       checker <= 0;
//	       send_on <= 1'b1;
//       end
//       else if (ch_on) begin
//	       checker <= checker + 1;
//	       send_on <= 1'b0;
//       end	                  	       
                	   
//	end
	
//	assign rd_en = state[2] && !empty; // TO DO: try to use 1 var
//	assign start = state[3]; // SEND
	
	
	endmodule
	
//    // common ports	    
//        input clk,
//        input reset, //not used yet
        
//    // ports for working with FIFO
//        // command to FIFO used for resend functionality
//        output reg [3:0] fifo_command_o,
//        output fifo_rden_o,	    
//	    output reg fifo_wren_o,    	    
//		output reg [DATA_WIDTH-1 : 0] fifo_data_o,
//		input [DATA_WIDTH-1 : 0] fifo_data_i,
//		// used for initiate, who responds for 
//		// fifo full/empty		
//		input fifo_full_axi_i,
//		input fifo_empty_axi_i,
//		input fifo_full_ctrl_i,
//		input fifo_empty_ctrl_i, 
		
//    // Ports for serdes communication 
//		output reg [LVDS_PIN_NUMBER * 8 - 1 : 0] data_reg,
//		output [LVDS_PIN_NUMBER - 1 : 0] start_o,
//		// Used to control last transaction of IOBUFDS
//		output end_flag_o,
//		// Indicate where start/end(0x7E) contains to send it without encode
//        output reg [LVDS_PIN_NUMBER - 1 : 0] st_flag_o,
//        // Indicate start/end frame when data receive
//        input [LVDS_PIN_NUMBER - 1 : 0] st_flag_i,      
//		input [LVDS_PIN_NUMBER * 8 - 1 : 0] data_i,
//		input [LVDS_PIN_NUMBER - 1 : 0] lvds_busy
		 
//	);
//	// We collect data, until number of lvds pins can send it together (8 bit on one lvds pin)
//	// or until fifo will be empty
	
//	// Controller for end of receiving data from another SERDES
//	reg receive_end;
//	// Register to receive CRC data
//	reg [7:0] crc_reg;
//    // Data, which was received from FIFO but didn't hit to the frame part
//    reg [23:0] data_rest;
//    // Pointer to jump for 8 bit data_fifo_o parts. Used for collecting 32 bits words
//    reg [2:0] data_fifo_ptr;
//    // Flag indicates, what part of Data didn't hit to the frame part
//    reg [2:0] rest_num;
//    // TO DO: change data_poiner size with clogb function
//    // Pointer to lvds pins data
//    reg [5:0] data_pointer;
//    // Indicate add of frame start(0x7E)
//    reg start_flg;
//    // Indicate add of frame end(0x7E)
//    reg end_flg;
//    // Indicate, that end of frame ready to sent
//    reg finish_flg;
//    // TODO: try to use data_reg without data_inp
//    reg [LVDS_PIN_NUMBER * 8 - 1 : 0] data_inp;
//    // Checker to control next data receive
//    reg [3:0] receive_checker;
//    // parameter to control when new data received
//    localparam NEW_DATA = 9;
//    // st_flag to contain st_flag_i when data receives from serdes
//    reg [LVDS_PIN_NUMBER - 1 : 0] st_flag;
//    // crc for sending data
//    reg [7:0] crc_7;
//    // indicate that crc was added to the frame
//    reg crc_flag;
    
//    // Specials for HANDSHAKE state
//    // Indicate, that Request-Response have done and each part ready to work
//    // Indicate end of handshake
//    (* mark_debug="true" *) reg init_ready=0;
//    // Indicate that all lvds pins charged by 0x7E
//    reg load_hdshk;
//    // used to rerun send of 0x7E on all pins if time of response is over
//    reg start_disable;
//    // cheker for time response. if 5'b11111 then resend 0x7E
//    reg [4:0] hdshk_checker = 0;
//    reg [6:0] test_checker;
                       
       	
//	(* mark_debug="true" *)reg [9:0] state          = 10'b0000000001;
//	localparam INIT          = 10'b0000000001;
//	localparam WAIT          = 10'b0000000010;
//	localparam SEND          = 10'b0000000100;
//	localparam RECEIVE       = 10'b0000001000;
//	localparam HANDSHAKE     = 10'b0000010000;
//	localparam WAIT_RESPONSE = 10'b0000100000;
//	localparam SEND_RESPONSE = 10'b0001000000;
    	
	
//	always @(posedge clk)
//	begin: STM
//	   case(state)
//	       // waiting until all send buffer will be filled or FIFO empty taken(Transmitter)
//	       // waiting intil begin of the frame will be taken(Receiver)
//	       WAIT: begin
//	            // Transmitter part
//	            if (!lvds_busy[0] && data_pointer == LVDS_PIN_NUMBER)
//	               state <= SEND; 
//                else if (!lvds_busy[0] && finish_flg)
//                   state <= SEND;
//                // Receiver part
//                else if (st_flag_i[0] == 1)
//                   state <= RECEIVE;                   	                                                                       	       	           
//	       end
//	       // send data + start flags to SERDES
//	       // next transition is WAIT if frame not ended
//	       // or WAIT_RESPONSE if frame ended
//	       SEND: begin
//	           if (finish_flg)
//	               state <= WAIT_RESPONSE; 
//	           else       
//	               state <= WAIT;
//	       end
//           end
//	   endcase	   
//	end	

//	always @(posedge clk)
//	begin: EX
//	   case(state)
//	       WAIT: begin
//	       // ------------------------------------------------------------------------------------
//	            // add 0x7E - start frame to output register
//	            if (!start_flg && !fifo_empty_ctrl_i && data_pointer != LVDS_PIN_NUMBER) begin
//	               data_reg[data_pointer * 8 + 7 -: 8] <= 8'h7E;
//	               data_pointer <= data_pointer + 1;
//	               st_flag_o[0] <= 1'b1;
//	               start_flg <= 1'b1;
//	            end
//	       // ------------------------------------------------------------------------------------
//	            // push the rest bytes of 4bytes word to output buffer if rest == 3 bytes
//	            else if (rest_num[2] && data_pointer != LVDS_PIN_NUMBER) begin
//	                data_reg[data_pointer * 8 + 7 -: 8] <= data_rest[7:0];
//	                if (LVDS_PIN_NUMBER - data_pointer > 2) begin
//                        data_reg[data_pointer * 8 + 15 -: 8] <= data_rest[15:8];
//                        data_reg[data_pointer * 8 + 23 -: 8] <= data_rest[23:16];
//                        data_rest <= 0;
//                        rest_num  <= 0;
//                    end               
//                    else if (LVDS_PIN_NUMBER - data_pointer > 1) begin
//                        data_reg[data_pointer * 8 + 15 -: 8] <= data_rest[15:8]; 
//                        data_rest[7:0] <= data_rest[23:16];
//                        data_rest[23:8] <= 0;                   
//                        rest_num <= 3'b001;
//                    end 
//                    else begin
//                        data_rest[7:0]  <= data_rest[15:8];                    
//                        data_rest[15:8] <= data_rest[23:16];
//                        data_rest[23:16] <= 0;                   
//                        rest_num <= 3'b011;                    
//                    end                                                                    	          
                                        
//                    if (LVDS_PIN_NUMBER - data_pointer >= 3)    
//                        data_pointer <= data_pointer + 3;
//                    else
//                        data_pointer <= LVDS_PIN_NUMBER;                                                                                                                	                    
//	            end	            
//            // ------------------------------------------------------------------------------------
//	            // push the rest bytes of 4bytes word to output buffer if rest == 2 bytes                            
//	            else if (rest_num[1] && data_pointer != LVDS_PIN_NUMBER) begin
//                    data_reg[data_pointer * 8 + 7 -: 8] <= data_rest[7:0];        
//                    if (LVDS_PIN_NUMBER - data_pointer > 1) begin
//                        data_reg[data_pointer * 8 + 15 -: 8] <= data_rest[15:8]; 
//                        data_rest <= 0;                    
//                        rest_num <= 0;
//                    end 
//                    else begin
//                        data_rest[7:0]  <= data_rest[15:8]; 
//                        data_rest[15:8] <= 0;                   
//                        rest_num <= 3'b001;                    
//                    end                                                                                  
                                        
//                    if (LVDS_PIN_NUMBER - data_pointer >= 2)    
//                        data_pointer <= data_pointer + 2;
//                    else
//                        data_pointer <= LVDS_PIN_NUMBER;                                                                                                                                        
//                end
//            // ------------------------------------------------------------------------------------
//                // push the rest bytes of 4bytes word to output buffer if rest == 3 bytes
//	            else if (rest_num[0] && data_pointer != LVDS_PIN_NUMBER) begin
//                    data_reg[data_pointer * 8 + 7 -: 8] <= data_rest[7:0]; 
//                    data_rest <= 0;       
//                    rest_num <= 0;                                                                               
//                    data_pointer <= data_pointer + 1;
//                end                               	            
//            // ------------------------------------------------------------------------------------
//	            // contains Data until fifo not empty or all pins will be used for sending
//                else if (!fifo_empty_ctrl_i && fifo_rden_o && data_pointer != LVDS_PIN_NUMBER) begin
//                    // push always minimun 1 byte to buffer
//                    data_reg[data_pointer * 8 + 7 -: 8] <= fifo_data_i[7:0];
//                    // push 3 another bytes to buffer
//                    if (LVDS_PIN_NUMBER - data_pointer > 3) begin
//                        data_reg[data_pointer * 8 + 15 -: 8] <= fifo_data_i[15:8];
//                        data_reg[data_pointer * 8 + 23 -: 8] <= fifo_data_i[23:16];
//                        data_reg[data_pointer * 8 + 31 -: 8] <= fifo_data_i[31:24];
//                    end 
//                    // push 2 another bytes to buffer
//                    else if (LVDS_PIN_NUMBER - data_pointer > 2) begin
//                        data_reg[data_pointer * 8 + 15 -: 8] <= fifo_data_i[15:8];
//                        data_reg[data_pointer * 8 + 23 -: 8] <= fifo_data_i[23:16];
//                    end                       
//                    // push 1 another byte to buffer
//                    else if (LVDS_PIN_NUMBER - data_pointer > 1) 
//                        data_reg[data_pointer * 8 + 15 -: 8] <= fifo_data_i[15:8];
                    
//                    // push 3 rest bytes to reserv(next send)      
//                    if (LVDS_PIN_NUMBER - data_pointer < 2) begin
//                        data_rest[7:0] <=  fifo_data_i[15:8];  
//                        data_rest[15:8] <=  fifo_data_i[23:16];
//                        data_rest[23:16] <=  fifo_data_i[31:24];
//                        rest_num <= 3'b111;
//                    end
//                    // push 2 rest bytes to reserv(next send)                         
//                    else if (LVDS_PIN_NUMBER - data_pointer < 3) begin
//                        data_rest[7:0] <=  fifo_data_i[23:16];
//                        data_rest[15:8] <=  fifo_data_i[31:24];
//                        rest_num <= 3'b011;                         
//                    end
//                    // push 1 rest byte to reserv(next send)
//                    else if (LVDS_PIN_NUMBER - data_pointer < 4) begin
//                        data_rest[7:0] <=  fifo_data_i[31:24];
//                        rest_num <= 3'b001;                         
//                    end                                                                                                                       
//                    // count a pointer of used lvds pins                            
//                    if (LVDS_PIN_NUMBER - data_pointer >= 4)    
//                        data_pointer <= data_pointer + 4;
//                    else
//                        data_pointer <= LVDS_PIN_NUMBER;    

//                    crc_7 = nextCRC7_D32(fifo_data_i,crc_7);                                             
//                end
//            // ------------------------------------------------------------------------------------
//                // if the end of the frame, then push crc to the frame                
//                else if (end_flg && !crc_flag && data_pointer != LVDS_PIN_NUMBER) begin
//                    data_reg[data_pointer * 8 + 7 -: 8] <= crc_7;
//                    data_pointer <= data_pointer + 1;
//                    crc_flag <= 1'b1;
//                end
//            // ------------------------------------------------------------------------------------
//                // if the end of the frame, then push 0x7E(end) after crc                
//                else if (end_flg && crc_flag && !finish_flg && data_pointer != LVDS_PIN_NUMBER) begin   
//                    data_reg[data_pointer * 8 + 7 -: 8] <= 8'h7E;
//	                st_flag_o[data_pointer] <= 1'b1;
//                    finish_flg <= 1'b1;                    
//                end                    
//            // ------------------------------------------------------------------------------------
//                // end of the frame                
//                if (start_flg && fifo_empty_ctrl_i) end_flg <= 1'b1;
//            // ------------------------------------------------------------------------------------                
//                // receiver first data collection
//                if (st_flag_i[0] && !start_flg) begin //TODO create new state for write. No start_flg
//                    data_inp <= data_i;
//                    st_flag <= st_flag_i;
//                    st_flag[LVDS_PIN_NUMBER - 1 : 1] <= st_flag_i[LVDS_PIN_NUMBER - 1 : 1];
//                    st_flag[0] <= 0;
//                    data_pointer <= data_pointer + 1;                    
//                end         
//            // ------------------------------------------------------------------------------------                                                                                                                                                   	       
//	       end
//	       // send data to serdes. Works with assigns below 
//	       SEND: begin
//                data_pointer <= 0;
//                data_reg <= 0;
//                st_flag_o <= 0;
//                if (finish_flg) begin
//                    finish_flg <= 0;
//                    end_flg <= 0;
//                    start_flg <= 0;
//                end                                                                                            	          	                        
//	       end               	                                                                                            
//	endmodule

