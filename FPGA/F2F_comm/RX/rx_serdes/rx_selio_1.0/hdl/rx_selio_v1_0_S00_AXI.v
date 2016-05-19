
`timescale 1 ns / 1 ps

	module rx_selio_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 4
	)
	(
		// Users to add ports here
        output reg [4:0] bitslip,
        output wire reset,
        input wire clk_div,
        input wire [31:0] din1,
        input wire [31:0] din2,        
        output wire clk_out,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 1;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 4
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          2'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          2'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
	                    end
	        endcase
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        2'h0   : reg_data_out <= slv_reg0;
	        2'h1   : reg_data_out <= rxdata1[31:0];
	        2'h2   : reg_data_out <= rxdata2[31:0];
	        2'h3   : reg_data_out <= 0;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	// Add user logic here
	reg [31:0] flags = 0;
	reg [31:0] rxdata1;
	reg [31:0] rxdata2;
	reg [39:0] rdata;
	reg [4:0]  flag;
	reg        enable;
	reg [4:0]  bstate;
	reg        lock; 
	
	reg tmp_chk = 0;
	wire [39:0] din2;
//	assign din2 = {0,8 ,16,24,
//	               1,9 ,17,25,
//	               2,10,18,26,
//	               3,11,19,27,
//	               4,12,20,28,
//	               5,13,21,29,
//	               6,14,22,30,
//	               7,15,23,31};
	
	assign reset = ~S_AXI_ARESETN;
	
	

  always @( posedge clk_div )
    begin
      if ( S_AXI_ARESETN == 1'b0 | slv_reg0 )
      begin
          
          rdata   <= 0;
      end 
      else begin
//          if ( !enable ) begin
//               rdata <= din;

//	            rdata <=    {din[31],din[27] ,din[23],din[19],
//                             din[15],din[11] ,din[7] ,din[3],
//                             din[30],din[26] ,din[22],din[18],
//                             din[14],din[10] ,din[6] ,din[2],
//                             din[29],din[25] ,din[21],din[17],
//                             din[13],din[9]  ,din[5] ,din[1],
//                             din[28],din[24] ,din[20],din[16],
//                             din[12],din[8]  ,din[4] ,din[0]};    

//	            rdata <=    {din[39] ,din[34] ,din[29], din[24], din[19], din[14] ,din[9]  ,din[4],
//                             din[38] ,din[33] ,din[28], din[23], din[18], din[13] ,din[8]  ,din[3],
//                             din[37] ,din[32] ,din[27], din[22], din[17], din[12] ,din[7]  ,din[2],
//                             din[36] ,din[31] ,din[26], din[21], din[16], din[11] ,din[6]  ,din[1],                                                                                       	            
//                             din[35] ,din[30] ,din[25], din[20], din[15], din[10] ,din[5]  ,din[0]};                                       
//          end
      end   
    end    
    
    always @( negedge clk_div )
    begin       
            if ( S_AXI_ARESETN == 1'b0 | slv_reg0) begin
                enable  <= 1'b1;                          
                flag    <= 0;
                bitslip <= 0;
                bstate  <= 5'h0;   
                rxdata1  <= 0;
                rxdata2  <= 0;                
                lock <= 1;     
            end
            else if ( enable ) begin
                flags[0] <= enable;
                flags[1] <= flag[0];
                flags[2] <= bitslip[0];
                flags[4] <= bstate[0];
                flags[5] <= bstate[1];
                flags[6] <= bstate[2];
                flags[7] <= bstate[3];
                flags[8] <= bstate[4];
                rxdata1 <= din1;
                rxdata2 <= din2;                

//	            rxdata <=   {din[39] ,din[34] ,din[29], din[24], din[19], din[14] ,din[9]  ,din[4],
//                             din[38] ,din[33] ,din[28], din[23], din[18], din[13] ,din[8]  ,din[3],
//                             din[37] ,din[32] ,din[27], din[22], din[17], din[12] ,din[7]  ,din[2],
//                             din[36] ,din[31] ,din[26], din[21], din[16], din[11] ,din[6]  ,din[1],                                                                                       	            
//                             din[35] ,din[30] ,din[25], din[20], din[15], din[10] ,din[5]  ,din[0]};           
                             

//                if ( rxdata[39:32] != 8'h7E ) 
//                    flag[4] <= 1'b1;
//                else if ( bstate[3] && rxdata[39:32] == 8'h7E) 
//                begin
//                    flag[4]   <= 0;
//                end                                  
//                if ( rxdata[31:24] != 8'h7E ) 
//                    flag[3] <= 1'b1;
//                else if ( bstate[3] && rxdata[31:24] == 8'h7E) 
//                begin
//                    flag[3]   <= 0;
//                end
//                if ( rxdata[23:16] != 8'h7E ) 
//                    flag[2] <= 1'b1;
//                else if ( bstate[3] && rxdata[23:16] == 8'h7E) 
//                begin
//                    flag[2]   <= 0;
//                end
//                if ( rxdata[15:8] != 8'h7E ) 
//                    flag[1] <= 1'b1;
//                else if ( bstate[3] && rxdata[15:8] == 8'h7E) 
//                begin
//                    flag[1]   <= 0;
//                end
//                if ( rxdata[7:0] != 8'h7E ) 
//                    flag[0] <= 1'b1;
//                else if ( bstate[3] && rxdata[7:0] == 8'h7E) 
//                begin
//                    flag[0]   <= 0; 
//                end
                
//                lock <= 0;
//                if (!lock && flag[4:0] == 0)
//                begin
//                    enable <= 0;
//                end                                                

                                      
//                if ( flag != 0 ) begin
//                case ( bstate ) 
//                    4'h0: begin
//                        bstate <= 5'h1;
//                        bitslip <= {flag[4],flag[3],flag[2],flag[1],flag[0]};
//                    end
//                    4'h1: begin
//                        bstate <= 5'h2;
//                        bitslip <= 0;
//                    end
//                    4'h2: begin
//                        bstate <= 5'h3;
//                    end
//                    4'h3: begin
//                        bstate <= 5'h4;
//                    end   
//                    4'h4: begin
//                        bstate <= 5'h8;
//                    end 
//                    4'h8: begin
//                        bstate <= 5'h0;
//                    end                   
//                endcase                                                         
//                end                    
            end                
    end
    
    
    
    
	// bitslip operation	
//    always @( negedge clk_div)
//        begin
//            if ( S_AXI_ARESETN == 1'b0 | slv_reg2 )
//                begin
//                    enable  <= 1'b1;                          // start bit slip
//                    flag    <= 1'b0;
//                    bitslip <= 0;
//                    bstate  <= 4'h0;   
//                end
//            else if ( enable )
//                begin
//                    bitslip <= 0;
//                    if (din[23:0] != 24'hA0A0A0) 
//                         begin flag <= 1'b1 ; end 
//                    else begin flag <= 1'b0 ; enable <= 1'b0; end 
//                    if ( flag ) begin
//                        case ( bstate )
//                            4'h0: begin 
//                                    bstate <= 4'h1;
//                                    bitslip <= 7;
//                                  end
//                            4'h1: begin
//                                    bstate  <= 4'h2;
//                                  end  
//                            4'h2: begin
//                                    bstate  <= 4'h3;
//                                  end           
//                            4'h3: begin
//                                    bstate  <= 4'h4;
//                                  end  
//                            4'h4: begin 
//                                    bstate  <= 4'h5;
//                                  end
//                            default: begin
//                                    bstate  <= 4'h0;
////                                    flag    <= 0;
//                                    end
//                        endcase                                         
//                    end
//                end
//        end	
	
//  always @( negedge clk_div )
//    begin
//      if ( S_AXI_ARESETN == 1'b0 | slv_reg0 )
//        begin
//          rxdata  <= 0;
//          rdata   <= 0;
//        end 
//      else begin
//          rdata[7:0] <= din[7:0];
////        rdata[23:0] <= din[23:0];
          
////        rdata[19:10] <= din[19:10];
////        rdata[26:20] <= din[26:20];
//      end  
////      if (rdata[23:16] != 0) tmp_chk <= 1'b1;        
                            
////      else if ( !enable )begin    
////            rxdata[7:0] <= din[7:0];
////        end
////      if (rdata[31:24] == 0) begin
////            rdata[31:0] <= {rdata[23:0],rxdata[7:0]};
////            end  
//    end
    
//    always @( posedge clk_out )
//    begin
//      if ( S_AXI_ARESETN == 1'b0 | slv_reg0 )
//        begin
//          rdata2 <= 0;
//          rdata3 <= 0;
////          rdata[19:10]   <= 0;
//        end 
//      else begin
////        rdata[17:10]  <= din[7:0];  
////        rdata[19:18]  <= din[9:8];
////        rdata[29:19]  <= rdata[19:10];
////        rdata2[9:0]   <= rdata[19:10];
////        rdata2[19:10]   <= rdata2[9:0];
////        rdata3[9:0] <= rdata2[19:10];
////        rdata3[19:10] <= rdata3[9:0] ;
////        rdata2[29:20]   <= rdata2[19:10];
//      end  
//    end
        
	// bitslip operation
//	  reg en_flag;
//	  always @( clk_div )
//	  begin
//	      if ( S_AXI_ARESETN == 1'b0)
//	      begin
//	          flag <= 1'b0;
//	          enable <= 1'b1;
//	          en_flag <= 1'b0;
//	          bitslip <= 4'h0;
//	          bstate <= 4'h0;
//	      end
//	      else if ( enable )	         
//	      begin
//	          if ( din[7:0] == 8'hA0 )
//	          begin
//	              enable <= 0;
//	              bitslip <= 0;
//	          end
//	          else begin
//	              bitslip <= 4'hF;
//	          end
//	      end
//	  end

//    always @( negedge clk_div)
//        begin
//            if ( S_AXI_ARESETN == 1'b0 | slv_reg2 )
//                begin
//                    enable  <= 1'b1;                          // start bit slip
//                    flag    <= 1'b0;
//                    bitslip <= 0;
//                    bstate  <= 4'h0;   
//                end
//            else if ( enable )
//                begin
//                    bitslip <= 0;
//                    if (din[7:0] != 8'hA0) 
//                         begin flag <= 1'b1 ; end 
//                    else begin flag <= 1'b0 ; enable <= 1'b0; end 
//                    if ( flag ) begin
//                        case ( bstate )
//                            4'h0: begin 
//                                    bstate <= 4'h1;
////                                    bitslip <= 2'b00;                                    
//                                    bitslip <= 2'b11;
//                                  end
//                            4'h1: begin
//                                    bstate  <= 4'h2;
////                                    bitslip <= 2'b0;
//                                  end  
//                            4'h2: begin
//                                    bstate  <= 4'h3;
////                                    bitslip <= 2'b0;
//                                  end           
//                            4'h3: begin
//                                    bstate  <= 4'h4;
////                                    bitslip <= 2'b0;
//                                  end  
//                            4'h4: begin 
//                                    bstate  <= 4'h5;
////                                    bitslip <= 2'b0;
//                                  end
//                            default: begin
//                                    bstate  <= 4'h0;
////                                    flag    <= 1'b0;
//                                    end
//                        endcase                                         
//                    end
//                end
//        end

    wire CLKFBOUT;         
    PLLE2_ADV #(
          .BANDWIDTH        ("OPTIMIZED"),          
          .CLKFBOUT_MULT        (32),               
          .CLKFBOUT_PHASE        (0.0),                 
          .CLKIN1_PERIOD        (40.000),          
          .CLKIN2_PERIOD        (40.000),          
          .CLKOUT0_DIVIDE        (8),               
          .CLKOUT0_DUTY_CYCLE    (0.5),                 
          .CLKOUT0_PHASE        (0.0),                 
          .CLKOUT1_DIVIDE        (20),           
          .CLKOUT1_DUTY_CYCLE    (0.5),                 
          .CLKOUT1_PHASE        (0.0),                 
          .CLKOUT2_DIVIDE        (0.0),           
          .CLKOUT2_DUTY_CYCLE    (0.5),                 
          .CLKOUT2_PHASE        (0.0),                 
          .CLKOUT3_DIVIDE        (),                   
          .CLKOUT3_DUTY_CYCLE    (0.5),                 
          .CLKOUT3_PHASE        (0.0),                 
          .CLKOUT4_DIVIDE        (),                   
          .CLKOUT4_DUTY_CYCLE    (0.5),                 
          .CLKOUT4_PHASE        (0.0),                  
          .CLKOUT5_DIVIDE        (),                   
          .CLKOUT5_DUTY_CYCLE    (0.5),                 
          .CLKOUT5_PHASE        (0.0),                  
          .COMPENSATION        ("ZHOLD"),             
          .DIVCLK_DIVIDE        (1),                    
          .REF_JITTER1        (0.100))                   
    tx_mmcme2_adv_inst (
          .CLKFBOUT            (CLKFBOUT),                  
          .CLKOUT0            (clk_out),              
          .CLKOUT1            (),              
          .CLKOUT2            (),                 
          .CLKOUT3            (),                      
          .CLKOUT4            (),                      
          .CLKOUT5            (),                      
          .DO            (),                            
          .DRDY            (),                          
          .PWRDWN            (1'b0),  
          .LOCKED            (),                
          .CLKFBIN            (CLKFBOUT),            
          .CLKIN1            (clk_div),                 
          .CLKIN2            (1'b0),                     
          .CLKINSEL            (1'b1),                     
          .DADDR            (7'h00),                    
          .DCLK            (1'b0),                       
          .DEN            (1'b0),                        
          .DI            (16'h0000),                
          .DWE            (1'b0),                        
          .RST            (reset)) ;   
          

//    wire CLKFBOUT;         
//    PLLE2_ADV #(
//          .BANDWIDTH        ("OPTIMIZED"),          
//          .CLKFBOUT_MULT        (8),               
//          .CLKFBOUT_PHASE        (0.0),                 
//          .CLKIN1_PERIOD        (10.000),          
//          .CLKIN2_PERIOD        (10.000),          
//          .CLKOUT0_DIVIDE        (8),               
//          .CLKOUT0_DUTY_CYCLE    (0.5),                 
//          .CLKOUT0_PHASE        (0.0),                 
//          .CLKOUT1_DIVIDE        (32),           
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
//          .CLKOUT0            (clk_out),              
//          .CLKOUT1            (),              
//          .CLKOUT2            (),                 
//          .CLKOUT3            (),                      
//          .CLKOUT4            (),                      
//          .CLKOUT5            (),                      
//          .DO            (),                            
//          .DRDY            (),                          
//          .PWRDWN            (1'b0),  
//          .LOCKED            (),                
//          .CLKFBIN            (CLKFBOUT),            
//          .CLKIN1            (clk_div),                 
//          .CLKIN2            (1'b0),                     
//          .CLKINSEL            (1'b1),                     
//          .DADDR            (7'h00),                    
//          .DCLK            (1'b0),                       
//          .DEN            (1'b0),                        
//          .DI            (16'h0000),                
//          .DWE            (1'b0),                        
//          .RST            (reset)) ;                 

	endmodule
