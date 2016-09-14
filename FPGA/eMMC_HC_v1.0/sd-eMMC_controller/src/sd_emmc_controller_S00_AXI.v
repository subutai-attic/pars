`timescale 1 ns / 1 ps
`include "sd_defines.h"
	module sd_emmc_controller_S00_AXI #
	(
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 32
	)
	(
        output wire [7:0] clock_divisor,
        input wire Internal_clk_stable,
        output wire [`CMD_REG_SIZE-1:0] command_o,
        output wire [31:0] argument_o,
        input wire  [31:0] response_0_i,
        input wire  [31:0] response_1_i,
        input wire  [31:0] response_2_i,
        input wire  [31:0] response_3_i,
        output wire [1:0] software_reset_o,
        input wire  [`INT_CMD_SIZE-1:0] cmd_int_st,
        input wire  [`INT_DATA_SIZE-1 :0] dat_int_st,
        output wire cmd_start,
        output wire cmd_int_rst,
        output reg dat_int_rst,
        output wire [`BLKSIZE_W-1:0] block_size_o,
        output wire [`BLKCNT_W-1:0] block_count_o,

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
		input wire  S_AXI_RREADY,
		output wire [28:0] int_stat_o,
		output wire [28:0] int_stat_en_o,
		output wire [28:0] int_sig_en_o,
		output wire [`DATA_TIMEOUT_W-1:0] timeout_contr_wire,
		output wire sd_dat_bus_width,
		output wire sd_dat_bus_width_8bit,
		input wire buff_read_en,
		input wire buff_writ_en,
		input wire write_trans_active,
		input wire read_trans_active,
		input wire dat_line_act,
		input wire command_inh_dat,
		input wire com_inh_cmd,
		output wire data_transfer_direction,
		input wire start_tx_fifo_i,
		output wire [1:0] dma_en_and_blk_c_en,
		input wire [1:0] dma_int,
		output wire [31:0] adma_sys_addr,
		output wire blk_gap_req,
		input wire cc_int_puls
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
	localparam integer OPT_MEM_ADDR_BITS = 4;

	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg0;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg2;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg3;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg4;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg5;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg6;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg7;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg8;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg9;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg10;
    reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg11;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg12_1;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg13;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg14;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg15;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg16;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg17;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg18;
//	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg19;
	reg [C_S_AXI_DATA_WIDTH-1:0]	slv_reg22;
	
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
    integer     byte_index;
	//interrupt register
    reg [31:0] cmd_int_reg;
    reg [11:0] blk_size_cnt = 0;
    reg [11:0] blk_size_cn  = 0;
    reg [15:0] blk_count_cnt = 0;
	wire     buff_read_en_int;
	wire     buff_write_en_int;
	wire cmd_compl_int;
	reg  cmd_int_rst_reg;
	reg  cmd_start_reg;
	reg  [7:0]ACMDErrorStatus;
     
    //SD-eMMC host controller registers
	assign software_reset_o    = slv_reg11[24] ? 2'b11 : ( slv_reg11 [25] ? 2'b01 : ( slv_reg11 [26] ? 2'b10 : 2'b00 )); // software reset
	assign timeout_contr_wire  = 1'b1  << slv_reg11[19:16] << 4'hD;          // Data timeout register
	assign clock_divisor       = slv_reg11[15:8] >> 1;                     // Clock_divisor  shift >>1 will decrease it
	assign command_o           = cmd_sel ? 14'h171a : slv_reg3 [29:16];    // CMD_INDEX choose.
	assign argument_o          = arg_sel ? slv_reg0 : slv_reg2;            // CMD_Argument choose. Either Arg1 or Arg2  
	assign block_size_o        = slv_reg1 [11:0];                          // Block size register
	assign block_count_o       = slv_reg1 [31:16];                         // Block count register
	assign int_stat_o          = slv_reg12 [28:0];                         // Error and Normal Interrupts Status registers
    assign int_stat_en_o       = slv_reg13 [28:0];                         // Error and Normal Interrupts Status Enable Registers
    assign int_sig_en_o        = slv_reg14 [28:0];                         // Error and Normal Interrupts Signal Enable Registers
    assign sd_dat_bus_width    = slv_reg10 [1];                            // Select sd data bus width 
    assign sd_dat_bus_width_8bit = slv_reg10 [5];                          //Select sd 8-bit data bus
    assign data_transfer_direction = slv_reg3 [4];                         // CMD_INDEX
    assign dma_en_and_blk_c_en = slv_reg3 [1:0];                           // "DMA enable" and blk "blk count enable" signals
    assign adma_sys_addr       = slv_reg22;
    assign blk_gap_req         = slv_reg10[16];
    assign cmd_compl_int       = cc_int_sel ? 1'b0 : cmd_int_st[`INT_CMD_CC];
    assign cmd_int_rst         = acmd23_int_rst | cmd_int_rst_reg;
    assign cmd_start           = start_cmd_reg1 | cmd_start_reg;
	
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

	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;
	assign buff_read_en_int = ((dat_int_st[5] && buff_read_en) | (dat_int_st[0] && buff_read_en));
	assign buff_write_en_int = ((dat_int_st[5] && start_tx_fifo_i) | (dat_int_st[0] && !buff_read_en && start_tx_fifo_i) | (!buff_read_en && start_tx_fifo_i && cmd_int_st[0])); // have to be changed for the SD fifo status

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      slv_reg0 <= 0;
	      slv_reg1 <= 0;
	      slv_reg2 <= 0;
	      slv_reg3 <= 0;
//	      slv_reg4 <= 0;
//	      slv_reg5 <= 0;
//	      slv_reg6 <= 0;
//	      slv_reg7 <= 0;
//	      slv_reg8 <= 0;
	      slv_reg9 <= 0;
	      slv_reg10 <= 0;
	      slv_reg11 <= 0;
	      slv_reg12 <= 0;
	      slv_reg12_1 <= 0;
	      slv_reg13 <= 0;
	      slv_reg14 <= 0;
	      slv_reg15 <= 0;
//	      slv_reg16 <= 0;
//	      slv_reg17 <= 0;
//	      slv_reg18 <= 0;
//	      slv_reg19 <= 0;
	      cmd_start_reg <= 0;
	      cmd_int_rst_reg <= 0;
	      dat_int_rst <= 0;
	      blk_size_cnt <= 0;
	      blk_size_cn  <= 0;
          blk_count_cnt <= 0;
	    end
	  else begin
	    cmd_start_reg <= 1'b0;
	    cmd_int_rst_reg <= 1'b0;
	    dat_int_rst <= 1'b0;
	    slv_reg11[26:24] <= 3'b000;
	    if (dat_int_st || cmd_int_st) begin
	       slv_reg12_1 <= slv_reg12_1;
	    end
	    else begin
	       slv_reg12_1 <= 0;
	    end
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          5'h00:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                slv_reg0[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          5'h01: begin
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                slv_reg1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
                   blk_count_cnt <= 0;
	              end
	          5'h02:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                slv_reg2[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          5'h03: begin
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )begin
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                slv_reg3[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	              end
	              if (S_AXI_WSTRB == 4'hC )
	                cmd_start_reg <= 1'b1;
	                slv_reg9 [0] <= 1'b1;  // Present state register command inhibit busy
	              end
//	          5'h04:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 4
//	                slv_reg4[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
//	          5'h05:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 5
//	                slv_reg5[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
//	          5'h06:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 6
//	                slv_reg6[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
//	          5'h07:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 7
//	                slv_reg7[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
//	          5'h08:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 8
//	                slv_reg8[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
	          5'h09:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 9
	                slv_reg9[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0A:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 10
	                slv_reg10[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0B: 
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 11
	                slv_reg11[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	          5'h0C: begin
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 ) begin
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 12
	                slv_reg12_1[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end
	            end
	              cmd_int_rst_reg <= 1'b1;
	              dat_int_rst <= 1'b1;
	              blk_size_cnt <= 0;
	            end
	          5'h0D:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 13
	                slv_reg13[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0E:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 14
	                slv_reg14[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          5'h0F:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 15
	                slv_reg15[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
//	          5'h10:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 16
//	                slv_reg16[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
//	          5'h11:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 17
//	                slv_reg17[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
//	          5'h12:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 18
//	                slv_reg18[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end  
//	          5'h13:
//	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
//	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
//	                // Respective byte enables are asserted as per write strobes 
//	                // Slave register 19
//	                slv_reg19[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
//	              end
	          5'h16:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
                    // Slave register 19
                    slv_reg22[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
  	          default : begin
	                      slv_reg0 <= slv_reg0;
	                      slv_reg1 <= slv_reg1;
	                      slv_reg2 <= slv_reg2;
	                      slv_reg3 <= slv_reg3;
//	                      slv_reg4 <= slv_reg4;
//	                      slv_reg5 <= slv_reg5;
//	                      slv_reg6 <= slv_reg6;
//	                      slv_reg7 <= slv_reg7;
//	                      slv_reg8 <= slv_reg8;
	                      slv_reg9 <= slv_reg9;
	                      slv_reg10 <= slv_reg10;
	                      slv_reg11 <= slv_reg11;
	                      slv_reg12_1 <= slv_reg12_1;
	                      slv_reg13 <= slv_reg13;
	                      slv_reg14 <= slv_reg14;
	                      slv_reg15 <= slv_reg15;
//	                      slv_reg16 <= slv_reg16;
//	                      slv_reg17 <= slv_reg17;
//	                      slv_reg18 <= slv_reg18;
//	                      slv_reg19 <= slv_reg19;
	                      slv_reg22 <= slv_reg22;
	                    end
	        endcase
	        
	      end
	      
          // Error and Normal Interrupt registers 0x30
          slv_reg12 <= ((~slv_reg12_1[28:0]) & {dat_int_st[4], 2'b00, dma_int[1], autocmderror, 1'b0, dat_int_st[1], dat_int_st[3:2], cmd_int_st[4], cmd_int_st[1], cmd_int_st[3:2], 10'b0000000000, buff_read_en_int, buff_write_en_int, 2'b00, (dma_int[0] | cmd_int_st[`INT_CMD_DC]), cmd_compl_int});
          // Internal sd clock stable signal
          slv_reg11[1] <= Internal_clk_stable;
          slv_reg9 [24] <= 1'b1;
          slv_reg9 [23:20] <= {4{~dat_line_act}};
          slv_reg9 [19:16] <= 4'b1111;
          slv_reg9 [11] <= (buff_read_en && (blk_size_cnt != slv_reg1[11:0]));
          slv_reg9 [10] <= (start_tx_fifo_i && (blk_size_cn != slv_reg1[11:0]));
          slv_reg9 [8] <= write_trans_active;
          slv_reg9 [9] <= read_trans_active;
          slv_reg9 [2] <= dat_line_act;
          slv_reg9 [1] <= (command_inh_dat | read_trans_active);
          slv_reg9 [0] <= slv_reg9 [0] && !com_inh_cmd;
          if (buff_write_en_int)
              blk_size_cn <= 0;
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
	      if (~axi_arready && S_AXI_ARVALID )
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
	        5'h00   : reg_data_out <= slv_reg0;
	        5'h01   : reg_data_out <= slv_reg1;
	        5'h02   : reg_data_out <= slv_reg2;
	        5'h03   : reg_data_out <= slv_reg3;
	        5'h04   : reg_data_out <= response_0_i;    //slv_reg4;
	        5'h05   : reg_data_out <= response_1_i;    //slv_reg5;
	        5'h06   : reg_data_out <= response_2_i;    //slv_reg6;
	        5'h07   : reg_data_out <= response_3_i;    //slv_reg7;
	        5'h08   : reg_data_out <= 0;               //slv_reg8;
	        5'h09   : reg_data_out <= slv_reg9;
	        5'h0A   : reg_data_out <= slv_reg10;
	        5'h0B   : reg_data_out <= slv_reg11;
	        5'h0C   : reg_data_out <= (slv_reg12 & slv_reg13);
	        5'h0D   : reg_data_out <= slv_reg13;
	        5'h0E   : reg_data_out <= slv_reg14;
	        5'h0F   : reg_data_out <= {slv_reg15[31:16],8'b0,ACMDErrorStatus}; //slv_reg15;
	        5'h10   : reg_data_out <= 32'h4012C32B2;    //slv_reg16; Capabilities register
	        5'h11   : reg_data_out <= 0;               //slv_reg17;
	        5'h12   : reg_data_out <= 0;               //slv_reg18;
	        5'h13   : reg_data_out <= 0;               //slv_reg19;
	        5'h16   : reg_data_out <= slv_reg22;
	        5'h3F   : reg_data_out <= 32'h00020000;    //Host Controller Version

	        
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
	      // output the read data 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    
	
	reg [1:0] acmd23state;
	reg acmd23_int_rst;
	reg arg_sel;
	reg cmd_sel;
	reg cc_int_sel;
	reg autocmderror;
	reg start_cmd_reg1;
	parameter [1:0] ACMDE = 2'b00, // AutoCMD23 Enable wait state
	                ACMDC = 2'b01, // AutoCMD23 Completion wait state
	                ACMDS = 2'b10; // Associated CMDx Send state
	
	always@(posedge S_AXI_ACLK)
	begin: AUTOCMD23
	  if (S_AXI_ARESETN == 1'b0) begin
	    acmd23state <= 0;
	    arg_sel <= 0;
	    cmd_sel <= 0;
	    cc_int_sel <= 0;
	    autocmderror <= 0;
        start_cmd_reg1 <= 0;
        acmd23_int_rst <= 0;
        ACMDErrorStatus <= 0;
	  end
	  else begin
	    case (acmd23state)
	      ACMDE: begin
	               start_cmd_reg1 <= 1'b0;
	               acmd23_int_rst <= 1'b0;
	               if (slv_reg3[3:2] == 2'b10) begin
	                 arg_sel <= 1'b1;
	                 cmd_sel <= 1'b1;
	                 cc_int_sel <= 1'b1;
	                 if (cmd_start_reg)
	                   acmd23state <= ACMDC;
	               end
	               else begin
	                 arg_sel <= 1'b0;
                     cmd_sel <= 1'b0;
                     cc_int_sel <= 1'b0;
	               end
	            end
	      ACMDC: begin
	               if (|cmd_int_st) begin
	                 acmd23_int_rst <= 1'b1;
	               end
	               else if (cc_int_puls) begin
	                 if (response_0_i[15:0] == 16'h0900) begin
                       arg_sel <= 1'b0;
                       cmd_sel <= 1'b0;
                       cc_int_sel <= 1'b0;
	                   start_cmd_reg1 <= 1'b1;
	                   acmd23state <= ACMDS;
	                 end
	                 else begin
	                   acmd23state <= ACMDE;
	                   autocmderror <= 1'b1;
	                   ACMDErrorStatus <= {3'b0,cmd_int_st[`INT_CMD_CIE],cmd_int_st[`INT_CMD_EI],cmd_int_st[`INT_CMD_CCRCE],cmd_int_st[`INT_CMD_CTE],1'b0};
	                 end
	               end
	            end
	      ACMDS: begin
	               start_cmd_reg1 <= 1'b0;
	               acmd23_int_rst <= 1'b0;
                   if (cc_int_puls)
                     acmd23state <= ACMDE;
	             end
	    endcase
	  end
	  if (cmd_int_rst_reg)
	    autocmderror <= 0;
	end
	endmodule
