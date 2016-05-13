
`timescale 1 ns / 1 ps

	module fifo_serdes #
	(
	   parameter FIFO_DEPTH = 10,
	   parameter DATA_WIDTH = 32
	)
	(
	   input wire clk,
	   input wire reset_n, 
	   
	   output dout,
	   output wire [31:0] debug,
	   
	   output reg full,
	   output reg empty,
	   
	   output tready,
	   input wire tvalid,
	   
	   input wire [DATA_WIDTH - 1 : 0] din,

	   input wire rd_en,
	   input wire wr_en,
	   
	  // used for continue read data with SERDES or resend data again
	   input wire [3:0] command
	);

	assign debug[0] = wr_ptr_prev[0];
	assign debug[1] = wr_ptr_prev[1];
	assign debug[2] = wr_ptr_prev[2];
	assign debug[3] = wr_ptr_prev[3];
			
	assign debug[4] = wr_ptr[0];
	assign debug[5] = wr_ptr[1];
	assign debug[6] = wr_ptr[2];
	assign debug[7] = wr_ptr[3];
	
	assign debug[8] = wr_ptr_next[0];
	assign debug[9] = wr_ptr_next[1];
	assign debug[10] = wr_ptr_next[2];
	assign debug[11] = wr_ptr_next[3];
		
	assign debug[12] = full;
	assign debug[13] = empty;
	assign debug[14] = wr_en;
	assign debug[15] = rd_en;
	
	assign debug[16] = rd_ptr[0];
	assign debug[17] = rd_ptr[1];
	assign debug[18] = rd_ptr[2];
	assign debug[19] = rd_ptr[3];
	
	assign debug[20] = rd_ptr_next[0];
	assign debug[21] = rd_ptr_next[1];
	assign debug[22] = rd_ptr_next[2];
	assign debug[23] = rd_ptr_next[3];
	
	
   // function called clogb2 that returns an integer which has the 
   // value of the ceiling of the log base 2.
    function integer clogb2 (input integer bit_depth);
      begin
        for(clogb2=0; bit_depth>0; clogb2=clogb2+1)
          bit_depth = bit_depth >> 1;
      end
    endfunction
    localparam ADDR_WIDTH = clogb2(FIFO_DEPTH);
    
    reg [DATA_WIDTH - 1 : 0] dout;
    
	reg [ADDR_WIDTH-1 : 0] rd_ptr_first; 
	reg [ADDR_WIDTH-1 : 0] rd_ptr;
	reg [ADDR_WIDTH-1 : 0] rd_ptr_next;
	reg [ADDR_WIDTH-1 : 0] wr_ptr_prev;
    reg [ADDR_WIDTH-1 : 0] wr_ptr;
    reg [ADDR_WIDTH-1 : 0] wr_ptr_next;
    
    reg [DATA_WIDTH * FIFO_DEPTH - 1 : 0] data;

    reg rd_bit = 0;
    reg wr_bit = 0;
    reg prev_wr_bit = 0;
    
    //1) Need to check again fifo work on testbench
    // Some error in empty flag generation
   	
	always @(posedge clk)
	begin
	   if ( reset_n == 0 ) begin
	       dout <= 0;
	       data <= 0;
           rd_ptr_first <= 0;
           rd_ptr <= 0;
           rd_ptr_next <= 1;     
           wr_ptr_prev <= 0;
           wr_ptr <= 0;
           wr_ptr_next <= 1;  
           full <= 0;
           empty <= 1;
           rd_bit <= 0; 
           wr_bit <= 0;
           prev_wr_bit <= 0;
       end
       else begin
          // Read operation work
          // rd_bit needs to compare it with wr_bit and check on FIFO full/empty flag
           if ( rd_en && !empty ) 
           begin
               rd_ptr <= ( rd_ptr + 1 ) % FIFO_DEPTH;
               rd_ptr_next <= ( rd_ptr_next + 1 ) % FIFO_DEPTH;
               dout <= data[DATA_WIDTH * rd_ptr_next + 31 - : 32];                           
           end
           else begin
               dout <= data[DATA_WIDTH * rd_ptr + 31 - : 32]; 
           end
           if (rd_en && rd_ptr_next == 0)
           begin
               rd_bit <= ~rd_bit; 
           end
            
          // Write operation work              
           if ( wr_en && !full )  
           begin
	           data[DATA_WIDTH * wr_ptr + 31 - : 32] <= din;                              
               wr_ptr_next <= ( wr_ptr_next + 1 ) % FIFO_DEPTH;
               wr_ptr <= ( wr_ptr + 1 ) % FIFO_DEPTH;                   
           end
           if ( wr_en && wr_ptr_next == 0 )
           begin
               wr_bit <= ~wr_bit;
           end 
                       
          // Empty flag generation
           if ( rd_ptr == wr_ptr && rd_bit == wr_bit && !wr_en ) begin
               empty <= 1'b1;
           end
           else if ( rd_ptr_next == wr_ptr && rd_en && !wr_en ) begin
               empty <= 1'b1;
           end                        
           else begin 
               empty <= 1'b0;
           end  
          // Full flag generation 
	       if ( wr_ptr == wr_ptr_prev && wr_bit != prev_wr_bit ) begin
               full <= 1'b1;
           end
           else if ( wr_ptr_next == wr_ptr_prev && wr_en ) begin
               full <= 1'b1;
           end
           else begin
               full <= 1'b0;
           end                                                   
       end
       
      // If crc checked and right, continue read
      // new data from FIRO to SERDES
//       if (command == 1) begin
//           rd_ptr_first <= rd_ptr; 
//           wr_ptr_prev <= wr_ptr;       
//           full <= 0;
//       end
      // If crc checked and wrong, will resend the data
//       else if (command == 2) begin
//           rd_ptr <= rd_ptr_first; 
//       end    
	end
   // Stream protocol used for testing
	assign tready = !full && tvalid;	

	endmodule
