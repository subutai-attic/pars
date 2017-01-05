`timescale 1 ns / 1 ps
`include "sd_emmc_defines.h"
    module sd_emmc_controller #
        (
 		        // Parameters of Axi Slave Bus Interface S00_AXI
                parameter integer C_S00_AXI_DATA_WIDTH    = 32,
                parameter integer C_S00_AXI_ADDR_WIDTH    = 32
        )
        (
        //SD interface
        output wire SD_CLK,
        output wire sd_cmd_o,
        input wire sd_cmd_i,
        output wire sd_cmd_t,
        output wire [7:0] sd_dat_o,
        input wire [7:0] sd_dat_i,
        output wire sd_dat_t,
        
        output wire sd_cmd1_o,
        input wire sd_cmd1_i,
        output wire sd_cmd1_t,
        output wire [7:0] sd_dat1_o,
        input wire [7:0] sd_dat1_i,
        output wire sd_dat1_t,

        // Interupt pinout 
        output wire interrupt,

        // Ports of Axi Slave Bus Interface S00_AXI
        input wire  s00_axi_aclk,
        input wire  s00_axi_aresetn,
        input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
        input wire [2 : 0] s00_axi_awprot,
        input wire  s00_axi_awvalid,
        output wire  s00_axi_awready,
        input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
        input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
        input wire  s00_axi_wvalid,
        output wire  s00_axi_wready,
        output wire [1 : 0] s00_axi_bresp,
        output wire  s00_axi_bvalid,
        input wire  s00_axi_bready,
        input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
        input wire [2 : 0] s00_axi_arprot,
        input wire  s00_axi_arvalid,
        output wire  s00_axi_arready,
        output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
        output wire [1 : 0] s00_axi_rresp,
        output wire  s00_axi_rvalid,
        input wire  s00_axi_rready,
        
        // Ports of Axi Master Bus Interface00
        input  wire        M_AXI_ACLK,
        input  wire        M_AXI_ARESETN,
        output wire [0:0]  M_AXI_AWID,
        output wire [31:0] M_AXI_AWADDR,
        output wire [7:0]  M_AXI_AWLEN,
        output wire [2:0]  M_AXI_AWSIZE,
        output wire [1:0]  M_AXI_AWBURST,
        output wire        M_AXI_AWLOCK,
        output wire [3:0]  M_AXI_AWCACHE,
        output wire [2:0]  M_AXI_AWPROT,
        output wire [3:0]  M_AXI_AWQOS,
        output wire        M_AXI_AWVALID,
        input  wire        M_AXI_AWREADY,
        output wire [31:0] M_AXI_WDATA,
        output wire [3:0]  M_AXI_WSTRB,
        output wire        M_AXI_WLAST,
        output wire        M_AXI_WVALID,
        input  wire        M_AXI_WREADY,
        input  wire [0:0]  M_AXI_BID,
        input  wire [1:0]  M_AXI_BRESP,
        input  wire        M_AXI_BVALID,
        output wire        M_AXI_BREADY,
        output wire [0:0]  M_AXI_ARID,
        output wire [31:0] M_AXI_ARADDR,
        output wire [7:0]  M_AXI_ARLEN,
        output wire [2:0]  M_AXI_ARSIZE,
        output wire [1:0]  M_AXI_ARBURST,
        output wire        M_AXI_ARLOCK,
        output wire [3:0]  M_AXI_ARCACHE,
        output wire [2:0]  M_AXI_ARPROT,
        output wire [3:0]  M_AXI_ARQOS,
        output wire        M_AXI_ARVALID,
        input  wire        M_AXI_ARREADY,
        input  wire [0:0]  M_AXI_RID,
        input  wire [31:0] M_AXI_RDATA,
        input  wire [1:0]  M_AXI_RRESP,
        input  wire        M_AXI_RLAST,
        input  wire        M_AXI_RVALID,
        output wire        M_AXI_RREADY,
        
        // Ports of Axi Master Bus Interface01
        input  wire        M01_AXI_ACLK,
        input  wire        M01_AXI_ARESETN,
        output wire [0:0]  M01_AXI_AWID,
        output wire [31:0] M01_AXI_AWADDR,
        output wire [7:0]  M01_AXI_AWLEN,
        output wire [2:0]  M01_AXI_AWSIZE,
        output wire [1:0]  M01_AXI_AWBURST,
        output wire        M01_AXI_AWLOCK,
        output wire [3:0]  M01_AXI_AWCACHE,
        output wire [2:0]  M01_AXI_AWPROT,
        output wire [3:0]  M01_AXI_AWQOS,
        output wire        M01_AXI_AWVALID,
        input  wire        M01_AXI_AWREADY,
        output wire [31:0] M01_AXI_WDATA,
        output wire [3:0]  M01_AXI_WSTRB,
        output wire        M01_AXI_WLAST,
        output wire        M01_AXI_WVALID,
        input  wire        M01_AXI_WREADY,
        input  wire [0:0]  M01_AXI_BID,
        input  wire [1:0]  M01_AXI_BRESP,
        input  wire        M01_AXI_BVALID,
        output wire        M01_AXI_BREADY,
        output wire [0:0]  M01_AXI_ARID,
        output wire [31:0] M01_AXI_ARADDR,
        output wire [7:0]  M01_AXI_ARLEN,
        output wire [2:0]  M01_AXI_ARSIZE,
        output wire [1:0]  M01_AXI_ARBURST,
        output wire        M01_AXI_ARLOCK,
        output wire [3:0]  M01_AXI_ARCACHE,
        output wire [2:0]  M01_AXI_ARPROT,
        output wire [3:0]  M01_AXI_ARQOS,
        output wire        M01_AXI_ARVALID,
        input  wire        M01_AXI_ARREADY,
        input  wire [0:0]  M01_AXI_RID,
        input  wire [31:0] M01_AXI_RDATA,
        input  wire [1:0]  M01_AXI_RRESP,
        input  wire        M01_AXI_RLAST,
        input  wire        M01_AXI_RVALID,
        output wire        M01_AXI_RREADY
    );

    //SD clock
    wire [7:0]  divisor;
    wire int_clk_stbl;

    wire go_idle;
    wire cmd_start_axi_clk;
    wire cmd_start_sd_clk;
    wire cmd_start;
    wire [1:0] cmd_setting;
    wire cmd_start_tx;
    wire [39:0] cmd;
    wire [119:0] cmd_response;
    wire [119:0] cmd1_response;
    wire cmd_crc_ok;
    wire cmd1_crc_ok;
    wire cmd_index_ok;
    wire cmd1_index_ok;
    wire cmd_finish;
    wire cmd1_finish;

    wire d_write;
    wire d_read;
    wire d_write1;
    wire d_read1;
    wire [31:0] data_in_rx_fifo;
    wire [31:0] data_in_rx_fifo1;
    wire [31:0] data_out_tx_fifo;
    wire [31:0] data_out_tx_fifo1;
    wire rx_fifo_full;
    wire rx_fifo1_full;
    wire sd_data_busy;
    wire sd_data_busy_dev1;
    wire data_busy;
    wire data_busy_dev1;
    wire data_crc_ok;
    wire data_crc_ok_dev1;
    wire rd_fifo;
    wire rd_fifo1;
    wire we_fifo;
    wire we_fifo1;

    wire data_start_rx;
    wire data_start_tx;
    wire cmd_int_rst_axi_clk;
    wire cmd_int_rst_sd_clk;
    wire cmd_int_rst;
    wire data_int_rst_axi_clk;
    wire data_int_rst_sd_clk;
    wire data_int_rst;

    //wb accessible registers
    wire [31:0] argument_axi_clk;
    wire [`CMD_REG_SIZE-1:0] command_axi_clk;
    wire [`DATA_TIMEOUT_W-1:0] data_timeout_axi_clk;
    wire [1:0] software_reset_axi_clk;
    wire [31:0] response_0_axi_clk;
    wire [31:0] response_1_axi_clk;
    wire [31:0] response_2_axi_clk;
    wire [31:0] response_3_axi_clk;
    wire [`BLKSIZE_W-1:0] block_size_axi_clk;
    wire controll_setting_axi_clk;
    wire controll_setting_8bit_axi_clk;
    wire [`INT_CMD_SIZE-1:0] cmd_int_status_axi_clk;
    wire [`INT_DATA_SIZE-1:0] data_int_status_axi_clk;
    wire [`BLKCNT_W-1:0] block_count_axi_clk;

    wire [31:0] argument_sd_clk;
    wire [`CMD_REG_SIZE-1:0] command_sd_clk;
    wire [`DATA_TIMEOUT_W-1:0] data_timeout_sd_clk;
    wire [31:0] response_0_sd_clk;
    wire [31:0] response_1_sd_clk;
    wire [31:0] response_2_sd_clk;
    wire [31:0] response_3_sd_clk;
    wire [`BLKSIZE_W-1:0] block_size_sd_clk;
    wire controll_setting_sd_clk;
    wire controll_setting_8bit_sd_clk;
    wire [`INT_CMD_SIZE-1:0] cmd_int_status_sd_clk;
    wire [`INT_DATA_SIZE-1:0] data_int_status_sd_clk;
    wire [`BLKCNT_W-1:0] block_count_sd_clk;
    
    //Software Reset
    wire soft_rst_cmd_axi_clk;
    wire soft_rst_dat_axi_clk;
    wire soft_rst_cmd_sd_clk;
    wire soft_rst_dat_sd_clk;
    wire next_block_st;
    wire next_block_st_dev1;
    wire next_block_st_axi;
    wire next_block_st_dev1_axi;
    wire fifo_reset;
    wire fifo1_reset;
    
    //Interrupts
    wire [28:0] int_status_reg;
    wire [28:0] int_status_en_reg;
    wire [28:0] int_signal_en_reg;

    // Present state register
    wire rd_trans_act_axi_clk;
    wire rd_trans_act_dev1_axi_clk;
    wire rd_trans_act_sd_clk;
    wire rd_trans_act_dev1_sd_clk;
    wire wr_trans_act_axi_clk;
    wire wr_trans_act_dev1_axi_clk;
    wire wr_trans_act_sd_clk;
    wire wr_trans_act_dev1_sd_clk;
    wire command_inhibit_dat_axi_clk;
    wire command_inhibit_dat_dev1_axi_clk;
    wire data_line_active_axi_clk;
    wire command_inhibit_cmd_sd_clk;
    wire command1_inhibit_cmd_sd_clk;
    wire command_inhibit_cmd_axi_clk;
    wire command1_inhibit_cmd_axi_clk;
    
    // Transfer mode register
    wire dat_trans_dir_axi_clk;
    wire dat_trans_dir_sd_clk;
    wire [31:0] read_fifo_out;
    wire [31:0] read_fifo1_out;
    wire fifo_data_read_ready;
    wire fifo1_data_read_ready;
    wire fifo_data_write_ready;
    wire fifo1_data_write_ready;
    
    // data write to SD card
    wire start_tx;
    wire start_dev1_tx;
    wire start_write_sd_clk;
    wire start_dev1_write_sd_clk;

    // dma
    wire [31:0] system_addr;
    wire [1:0] dma_and_blkcnt_en;
    wire [1:0] dma_int;
    wire [1:0] dma_int1;
    wire cmd_cmplt_axi_puls;
    wire stop_blk_gap_req;
    
    // data aligning
    wire [31:0] write_dat_fifo;
    wire [31:0] write_dat_fifo1;
    assign write_dat_fifo  = {M_AXI_RDATA[7:0],M_AXI_RDATA[15:8],M_AXI_RDATA[23:16],M_AXI_RDATA[31:24]};
    assign write_dat_fifo1 = {M01_AXI_RDATA[7:0],M01_AXI_RDATA[15:8],M01_AXI_RDATA[23:16],M01_AXI_RDATA[31:24]};
    
    // UHS mode
    wire [2:0] UHSModSel_axi_clk;
    wire [2:0] UHSModSel_sd_clk;
    wire sd_clk90;
    
    // raid0
    wire [16:0] data_cycle_o_axi;
    wire go_ahead;
    wire [1:0] adma_mst_state;
    wire [63:0] adma_mst_bd_line;
    
    sd_emmc_raid0 sd_emmc_raid_inst(
        .axi_clk            (M_AXI_ACLK),
        .sd_clk             (SD_CLK),
        .hwreset            (!s00_axi_aresetn),
        .rst                (!s00_axi_aresetn |  soft_rst_cmd_sd_clk),
        .start_i            (cmd_start_sd_clk),
        .int_status_rst_i   (cmd_int_rst_sd_clk),
        .setting_o          (cmd_setting),
        .start_xfr_o        (cmd_start_tx),
        .go_idle_o          (go_idle),
        .cmd_o              (cmd),
        .response_i         (cmd_response),
        .response1_i        (cmd1_response),
        .crc_ok_i           (cmd_crc_ok),
        .crc1_ok_i          (cmd1_crc_ok),
        .index_ok_i         (cmd_index_ok),
        .index1_ok_i        (cmd1_index_ok),
        .busy_i             (sd_data_busy),
        .finish_i           (cmd_finish),
        .finish1_i          (cmd1_finish),
        .argument_i         (argument_sd_clk),
        .command_i          (command_sd_clk),
        .int_status_o       (cmd_int_status_sd_clk),
        .response_0_o       (response_0_sd_clk),
        .response_1_o       (response_1_sd_clk),
        .response_2_o       (response_2_sd_clk),
        .response_3_o       (response_3_sd_clk),
        .go_ahead_o         (go_ahead),
        .inhibit_cmd_i      (command_inhibit_cmd_sd_clk),
        .inhibit_cmd1_i     (command1_inhibit_cmd_sd_clk),
        .read_fifo_data     (read_fifo_out),
        .m_axi_wdata        (M_AXI_WDATA),        
        .dma_data_cycles    (data_cycle_o_axi),
        .dma_int1           (dma_int1),
        .adma_mst_state_i   (adma_mst_state)
    );
        
    sd_emmc_controller_adma_mst sd_emmc_controller_adma_mst(
        .clock                  (M_AXI_ACLK),
        .reset                  (M_AXI_ARESETN),
        .is_we_en               (we_fifo),                  //used
        .dma_ena_trans_mode     (dma_and_blkcnt_en [0]),    //used
        .dir_dat_trans_mode     (dat_trans_dir_axi_clk),    //used
        .xfer_compl             (!data_busy),               //used
        .m_axi_wvalid           (M_AXI_WVALID),
        .m_axi_wready           (M_AXI_WREADY),
        .m_axi_awid             (M_AXI_AWID),
        .m_axi_awaddr           (M_AXI_AWADDR),
        .m_axi_awlock           (M_AXI_AWLOCK),
        .m_axi_awcache          (M_AXI_AWCACHE),
        .m_axi_awprot           (M_AXI_AWPROT),
        .m_axi_awqos            (M_AXI_AWQOS),
        .m_axi_awvalid          (M_AXI_AWVALID),
        .m_axi_awready          (M_AXI_AWREADY),
        .fifo_dat_rd_ready      (fifo_data_read_ready),     //used
        .m_axi_wlast            (M_AXI_WLAST),
        .dma_interrupts         (dma_int),                  //not used
        .dat_int_rst            (data_int_rst),             //used
        .m_axi_araddr           (M_AXI_ARADDR),
        .m_axi_arvalid          (M_AXI_ARVALID),
        .m_axi_arready          (M_AXI_ARREADY),
        .m_axi_rvalid           (M_AXI_RVALID),
        .m_axi_rready           (M_AXI_RREADY),
        .m_axi_rlast            (M_AXI_RLAST),
        .m_axi_arlen            (M_AXI_ARLEN),
        .m_axi_arsize           (M_AXI_ARSIZE),
        .m_axi_arburst          (M_AXI_ARBURST),
        .m_axi_awburst          (M_AXI_AWBURST),
        .m_axi_awlen            (M_AXI_AWLEN),
        .m_axi_rdata            (M_AXI_RDATA),
        .m_axi_awsize           (M_AXI_AWSIZE),
        .m_axi_wstrb            (M_AXI_WSTRB),
        .m_axi_bid              (M_AXI_BID),
        .m_axi_bresp            (M_AXI_BRESP),
        .m_axi_bvalid           (M_AXI_BVALID),
        .m_axi_bready           (M_AXI_BREADY),
        .m_axi_arid             (M_AXI_ARID),
        .m_axi_arlock           (M_AXI_ARLOCK),
        .m_axi_arcache          (M_AXI_ARCACHE),
        .m_axi_arprot           (M_AXI_ARPROT),
        .m_axi_arqos            (M_AXI_ARQOS),
        .m_axi_rid              (M_AXI_RID),
        .m_axi_rresp            (M_AXI_RRESP),
        .fifo_dat_wr_ready_o    (fifo_data_write_ready),    //used
        .fifo_rst               (fifo_reset),               //used
        .start_write            (start_tx),                 //used
        .ser_next_blk           (next_block_st_axi),        //used
        .write_timeout          ({d_read, d_write}),        //used
        .descriptor_pointer_i   (system_addr),              //no need to instantiate it to dma_slv
        .data_present           (command_axi_clk[5]),       //used
        .cmd_compl_puls         (cmd_cmplt_axi_puls),       //used
        .blk_gap_req            (stop_blk_gap_req),         //used
        .data_cycle_o           (data_cycle_o_axi),         //no need to instantiate it to dma_slv
        .adma_mst_state_o       (adma_mst_state),
        .adma_mst_bd_line_o     (adma_mst_bd_line)
    );
    
    sd_emmc_controller_adma_slv sd_emmc_controller_adma_slv0(
        .clock                  (M01_AXI_ACLK),
        .reset                  (M01_AXI_ARESETN),
        .m_axi_awid             (M01_AXI_AWID),
        .m_axi_awaddr           (M01_AXI_AWADDR),
        .m_axi_awlen            (M01_AXI_AWLEN),
        .m_axi_awsize           (M01_AXI_AWSIZE),
        .m_axi_awburst          (M01_AXI_AWBURST),
        .m_axi_awlock           (M01_AXI_AWLOCK),
        .m_axi_awcache          (M01_AXI_AWCACHE),
        .m_axi_awprot           (M01_AXI_AWPROT),
        .m_axi_awqos            (M01_AXI_AWQOS),
        .m_axi_awvalid          (M01_AXI_AWVALID),
        .m_axi_awready          (M01_AXI_AWREADY),
        .m_axi_wdata            (M01_AXI_WDATA),
        .m_axi_wstrb            (M01_AXI_WSTRB),
        .m_axi_wlast            (M01_AXI_WLAST),
        .m_axi_wvalid           (M01_AXI_WVALID),
        .m_axi_wready           (M01_AXI_WREADY),
        .m_axi_bid              (M01_AXI_BID),
        .m_axi_bresp            (M01_AXI_BRESP),
        .m_axi_bvalid           (M01_AXI_BVALID),
        .m_axi_bready           (M01_AXI_BREADY),
        .m_axi_arid             (M01_AXI_ARID),
        .m_axi_araddr           (M01_AXI_ARADDR),
        .m_axi_arlen            (M01_AXI_ARLEN),
        .m_axi_arsize           (M01_AXI_ARSIZE),
        .m_axi_arburst          (M01_AXI_ARBURST),
        .m_axi_arlock           (M01_AXI_ARLOCK),
        .m_axi_arcache          (M01_AXI_ARCACHE),
        .m_axi_arprot           (M01_AXI_ARPROT),
        .m_axi_arqos            (M01_AXI_ARQOS),
        .m_axi_arvalid          (M01_AXI_ARVALID),
        .m_axi_arready          (M01_AXI_ARREADY),
        .m_axi_rid              (M01_AXI_RID),
        .m_axi_rdata            (M01_AXI_RDATA),
        .m_axi_rresp            (M01_AXI_RRESP),
        .m_axi_rlast            (M01_AXI_RLAST),
        .m_axi_rvalid           (M01_AXI_RVALID),
        .m_axi_rready           (M01_AXI_RREADY),
        .read_fifo_data         (read_fifo1_out),
        .dma_ena_trans_mode     (dma_and_blkcnt_en [0]),
        .dir_dat_trans_mode     (dat_trans_dir_axi_clk),
        .data_present           (command_axi_clk[5]),
        .cmd_compl_puls         (cmd_cmplt_axi_puls),
        .fifo_dat_rd_ready      (fifo1_data_read_ready),
        .fifo_dat_wr_ready_o    (fifo1_data_write_ready),
        .fifo_rst               (fifo1_reset),
        .is_we_en               (we_fifo1),
        .write_timeout          ({d_read1, d_write1}),
        .xfer_compl             (!data_busy_dev1),
        .start_write            (start_dev1_tx),
        .ser_next_blk           (next_block_st_dev1_axi),
        .blk_gap_req            (stop_blk_gap_req),
        .dma_interrupts         (dma_int1),
        .dat_int_rst            (data_int_rst),
        .adma_mst_bd_line_i     (adma_mst_bd_line)
    );
    
    
    // Instantiation of Axi Bus Interface S00_AXI
    sd_emmc_controller_S00_AXI # ( 
        .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
    ) sd_emmc_controller_S00_AXI_inst (
        .S_AXI_ACLK             (s00_axi_aclk),
        .S_AXI_ARESETN          (s00_axi_aresetn),
        .S_AXI_AWADDR           (s00_axi_awaddr),
        .S_AXI_AWPROT           (s00_axi_awprot),
        .S_AXI_AWVALID          (s00_axi_awvalid),
        .S_AXI_AWREADY          (s00_axi_awready),
        .S_AXI_WDATA            (s00_axi_wdata),
        .S_AXI_WSTRB            (s00_axi_wstrb),
        .S_AXI_WVALID           (s00_axi_wvalid),
        .S_AXI_WREADY           (s00_axi_wready),
        .S_AXI_BRESP            (s00_axi_bresp),
        .S_AXI_BVALID           (s00_axi_bvalid),
        .S_AXI_BREADY           (s00_axi_bready),
        .S_AXI_ARADDR           (s00_axi_araddr),
        .S_AXI_ARPROT           (s00_axi_arprot),
        .S_AXI_ARVALID          (s00_axi_arvalid),
        .S_AXI_ARREADY          (s00_axi_arready),
        .S_AXI_RDATA            (s00_axi_rdata),
        .S_AXI_RRESP            (s00_axi_rresp),
        .S_AXI_RVALID           (s00_axi_rvalid),
        .S_AXI_RREADY           (s00_axi_rready),
        .clock_divisor          (divisor),
        .Internal_clk_stable    (int_clk_stbl),
        .cmd_start              (cmd_start),
        .cmd_int_rst            (cmd_int_rst),
        .dat_int_rst            (data_int_rst),
        .block_size_o           (block_size_axi_clk),
        .block_count_o          (block_count_axi_clk),
        .argument_o             (argument_axi_clk),
        .command_o              (command_axi_clk),
        .response_0_i           (response_0_axi_clk),
        .response_1_i           (response_1_axi_clk),
        .response_2_i           (response_2_axi_clk),
        .response_3_i           (response_3_axi_clk),
        .software_reset_o       (software_reset_axi_clk),  
        .cmd_int_st             (cmd_int_status_axi_clk),
        .dat_int_st             (data_int_status_axi_clk),
        .int_stat_o             (int_status_reg),
        .int_stat_en_o          (int_status_en_reg),
        .int_sig_en_o           (int_signal_en_reg),
        .timeout_contr_wire     (data_timeout_axi_clk),
        .sd_dat_bus_width       (controll_setting_axi_clk),   
        .sd_dat_bus_width_8bit  (controll_setting_8bit_axi_clk),   
        .write_trans_active     (wr_trans_act_axi_clk & wr_trans_act_dev1_axi_clk),
        .read_trans_active      (rd_trans_act_axi_clk & rd_trans_act_dev1_axi_clk),
        .dat_line_act           (data_line_active_axi_clk),
        .command_inh_dat        (command_inhibit_dat_axi_clk & command_inhibit_dat_dev1_axi_clk),
        .com_inh_cmd            (command_inhibit_cmd_axi_clk),
        .data_transfer_direction(dat_trans_dir_axi_clk),
        .dma_en_and_blk_c_en    (dma_and_blkcnt_en),
        .dma_int                (dma_int),
        .adma_sys_addr          (system_addr),
        .blk_gap_req            (stop_blk_gap_req),
        .cc_int_puls            (cmd_cmplt_axi_puls),
        .UHSModSel              (UHSModSel_axi_clk)
    );

    //Clock divider
    sd_clock_divider sd_clock_divider_i (
        .AXI_CLOCK(s00_axi_aclk),
        .sd_clk(SD_CLK),
        .DIVISOR(divisor),
        .AXI_RST(s00_axi_aresetn/* & int_clk_en*/),
        .Internal_clk_stable(int_clk_stbl),
        .sd_clk90(sd_clk90)
    );

    sd_mmc_cmd_serial_host cmd_serial_host0(
        .sd_clk              (SD_CLK),
        .rst                 (!s00_axi_aresetn | soft_rst_cmd_sd_clk | go_idle),
        .setting_i           (cmd_setting),
        .cmd_i               (cmd),
        .start_i             (cmd_start_tx),
        .finish_o            (cmd_finish),
        .response_o          (cmd_response),
        .crc_ok_o            (cmd_crc_ok),
        .index_ok_o          (cmd_index_ok),
        .cmd_dat_i           (sd_cmd_i),
        .cmd_out_o           (sd_cmd_o),
        .cmd_oe_o            (sd_cmd_t),
        .command_inhibit_cmd (command_inhibit_cmd_sd_clk),
        .go_ahead_i          (go_ahead)
    );

    sd_mmc_cmd_serial_host cmd_serial_host1(
        .sd_clk              (SD_CLK),
        .rst                 (!s00_axi_aresetn | soft_rst_cmd_sd_clk | go_idle),
        .setting_i           (cmd_setting),
        .cmd_i               (cmd),
        .start_i             (cmd_start_tx),
        .finish_o            (cmd1_finish),                 //output to raid0
        .response_o          (cmd1_response),               //output to raid0
        .crc_ok_o            (cmd1_crc_ok),                 //output to raid0
        .index_ok_o          (cmd1_index_ok),               //output to raid0
        .cmd_dat_i           (sd_cmd1_i),                   //card
        .cmd_out_o           (sd_cmd1_o),                   //card
        .cmd_oe_o            (sd_cmd1_t),                   //card
        .command_inhibit_cmd (command1_inhibit_cmd_sd_clk), //output to S00_AXI, raid0
        .go_ahead_i          (go_ahead)
    );

    sd_data_master sd_data_master0(
        .sd_clk           (SD_CLK),
        .rst              (!s00_axi_aresetn | soft_rst_dat_sd_clk ),
        .start_tx_i       (data_start_tx),
        .start_rx_i       (data_start_rx),
        .timeout_i        (data_timeout_sd_clk),
        .d_write_o        (d_write),
        .d_read_o         (d_read),
        .rx_fifo_full_i   (rx_fifo_full),
        .xfr_complete_i   (!data_busy),
        .crc_ok_i         (data_crc_ok),
        .int_status_o     (data_int_status_sd_clk),
        .int_status_rst_i (data_int_rst_sd_clk),
        .start_write      (start_write_sd_clk)
    );

    sd_data_serial_host sd_data_serial_host0(
        .sd_clk             (SD_CLK),
        .sd_clk90           (sd_clk90),
        .rst                (!s00_axi_aresetn | soft_rst_dat_sd_clk ),
        .data_in            (data_out_tx_fifo),
        .rd                 (rd_fifo),
        .data_out_o         (data_in_rx_fifo),
        .we                 (we_fifo),
        .DAT_oe_o           (sd_dat_t),
        .DAT_dat_o          (sd_dat_o),
        .DAT_dat_i          (sd_dat_i),
        .blksize            (block_size_sd_clk),
        .bus_4bit           (controll_setting_sd_clk),
        .bus_8bit           (controll_setting_8bit_sd_clk),
        .blkcnt             (block_count_sd_clk),
        .start              ({d_read, d_write}),
        .sd_data_busy       (sd_data_busy),
        .busy               (data_busy),
        .crc_ok             (data_crc_ok),
        .read_trans_active  (rd_trans_act_sd_clk),
        .write_trans_active (wr_trans_act_sd_clk),
        .start_write        (start_write_sd_clk),
        .write_next_block   (next_block_st),
        .UHSMode            (UHSModSel_sd_clk)
    );

    sd_data_master sd_data_master1(
        .sd_clk           (SD_CLK),
        .rst              (!s00_axi_aresetn | soft_rst_dat_sd_clk ),
        .start_tx_i       (data_start_tx),          //not compl ?
        .start_rx_i       (data_start_rx),          //not compl ?
        .timeout_i        (data_timeout_sd_clk),    //compl
        .d_write_o        (d_write1),               //compl
        .d_read_o         (d_read1),                //compl
        .rx_fifo_full_i   (rx_fifo1_full),          //compl
        .xfr_complete_i   (!data_busy_dev1),        //compl
        .crc_ok_i         (data_crc_ok_dev1),       //compl
        .int_status_o     (),                       //not compl
        .int_status_rst_i (),                       //not compl
        .start_write      (start_dev1_write_sd_clk) //compl
    );

    sd_data_serial_host sd_data_serial_host1(
        .sd_clk             (SD_CLK),
        .sd_clk90           (sd_clk90),
        .rst                (!s00_axi_aresetn | soft_rst_dat_sd_clk ),
        .data_in            (data_out_tx_fifo1),            //compl
        .rd                 (rd_fifo1),                     //compl
        .data_out_o         (data_in_rx_fifo1),             //compl
        .we                 (we_fifo1),                     //compl
        .DAT_oe_o           (sd_dat1_t),                    //compl
        .DAT_dat_o          (sd_dat1_o),                    //compl
        .DAT_dat_i          (sd_dat1_i),                    //compl
        .blksize            (block_size_sd_clk),            //compl
        .bus_4bit           (controll_setting_sd_clk),      //compl
        .bus_8bit           (controll_setting_8bit_sd_clk), //compl
        .blkcnt             (block_count_sd_clk),           //compl
        .start              ({d_read1, d_write1}),          //compl
        .sd_data_busy       (sd_data_busy_dev1),            //compl, not connected to raid0
        .busy               (data_busy_dev1),               //compl
        .crc_ok             (data_crc_ok_dev1),             //compl
        .read_trans_active  (rd_trans_act_dev1_sd_clk),     //compl
        .write_trans_active (wr_trans_act_dev1_sd_clk),     //compl
        .start_write        (start_dev1_write_sd_clk),      //compl
        .write_next_block   (next_block_st_dev1),           //compl
        .UHSMode            (UHSModSel_sd_clk)              //compl
        );

    sd_data_xfer_trig sd_data_xfer_trig0 (
        .sd_clk                (SD_CLK),
        .rst                   (!s00_axi_aresetn | soft_rst_dat_sd_clk ),
        .cmd_with_data_start_i (cmd_start_sd_clk & (command_sd_clk[5] == 1'b1)),
        .r_w_i                 (dat_trans_dir_sd_clk == 1'b1),
        .cmd_int_status_i      (cmd_int_status_sd_clk),
        .start_tx_o            (data_start_tx),
        .start_rx_o            (data_start_rx)
        );
        
    fifo18Kb fifo18Kb_inst0(
        .aclk           (s00_axi_aclk),
        .sd_clk         (SD_CLK),
        .rst(           !s00_axi_aresetn | soft_rst_dat_sd_clk | fifo_reset),
        .axi_data_in    (write_dat_fifo),
        .sd_data_in     (data_in_rx_fifo),
        .sd_data_out    (data_out_tx_fifo),
        .axi_data_out   (read_fifo_out),
        .sd_rd_en       (rd_fifo),
        .axi_rd_en      (fifo_data_read_ready),
        .axi_wr_en      (fifo_data_write_ready),
        .sd_wr_en       (we_fifo),
        .sd_full_o      (rx_fifo_full)
    );
    
        fifo18Kb fifo18Kb_inst1(
        .aclk           (s00_axi_aclk),
        .sd_clk         (SD_CLK),
        .rst            (!s00_axi_aresetn | soft_rst_dat_sd_clk | fifo1_reset),
        .axi_data_in    (write_dat_fifo1),          //compl
        .sd_data_in     (data_in_rx_fifo1),         //compl
        .sd_data_out    (data_out_tx_fifo1),        //compl
        .axi_data_out   (read_fifo1_out),           //compl
        .sd_rd_en       (rd_fifo1),                 //compl
        .axi_rd_en      (fifo1_data_read_ready),    //compl
        .axi_wr_en      (fifo1_data_write_ready),   //compl
        .sd_wr_en       (we_fifo1),                 //compl
        .sd_full_o      (rx_fifo1_full)             //compl
    );


    edge_detect soft_reset_edge_cmd (.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(software_reset_axi_clk[0]), .rise(soft_rst_cmd_axi_clk), .fall());
    edge_detect sotf_reset_edge_dat (.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(software_reset_axi_clk[1]), .rise(soft_rst_dat_axi_clk), .fall());
    edge_detect cmd_start_edge(.rst (!s00_axi_aresetn),      .clk(s00_axi_aclk), .sig(cmd_start),                 .rise(cmd_start_axi_clk),    .fall());
    edge_detect dat_int_rst_edge    (.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(data_int_rst),              .rise(data_int_rst_axi_clk), .fall());
    edge_detect cmd_int_rst_edge    (.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(cmd_int_rst),               .rise(cmd_int_rst_axi_clk),  .fall());
    edge_detect cmd_cmplt_edge      (.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(cmd_int_status_axi_clk[0]), .rise(),                     .fall(cmd_cmplt_axi_puls));
    edge_detect start_write         (.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(start_tx),                  .rise(start_tx_pulse),       .fall());
    edge_detect start_de1_write     (.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(start_dev1_tx),             .rise(start_dev1_tx_pulse),  .fall());
        
    monostable_domain_cross soft_reset_cross_cmd    (!s00_axi_aresetn, s00_axi_aclk, soft_rst_cmd_axi_clk, SD_CLK, soft_rst_cmd_sd_clk);
    monostable_domain_cross soft_reset_cross_dat    (!s00_axi_aresetn, s00_axi_aclk, soft_rst_dat_axi_clk, SD_CLK, soft_rst_dat_sd_clk);
    monostable_domain_cross cmd_start_cross         (!s00_axi_aresetn, s00_axi_aclk, cmd_start_axi_clk, SD_CLK, cmd_start_sd_clk);
    monostable_domain_cross data_int_rst_cross      (!s00_axi_aresetn, s00_axi_aclk, data_int_rst_axi_clk, SD_CLK, data_int_rst_sd_clk);
    monostable_domain_cross cmd_int_rst_cross       (!s00_axi_aresetn, s00_axi_aclk, cmd_int_rst_axi_clk, SD_CLK, cmd_int_rst_sd_clk);
    monostable_domain_cross start_write_cross       (!s00_axi_aresetn, s00_axi_aclk, start_tx_pulse, SD_CLK, start_write_sd_clk);
    monostable_domain_cross start_dev1_write_cross  (!s00_axi_aresetn, s00_axi_aclk, start_dev1_tx_pulse, SD_CLK, start_dev1_write_sd_clk);

    bistable_domain_cross #(32) argument_reg_cross                      (!s00_axi_aresetn, s00_axi_aclk, argument_axi_clk, SD_CLK, argument_sd_clk);
    bistable_domain_cross #(`CMD_REG_SIZE) command_reg_cross            (!s00_axi_aresetn, s00_axi_aclk, command_axi_clk, SD_CLK, command_sd_clk);
    bistable_domain_cross #(32) response_0_reg_cross                    (!s00_axi_aresetn, SD_CLK,      response_0_sd_clk, s00_axi_aclk, response_0_axi_clk);
    bistable_domain_cross #(32) response_1_reg_cross                    (!s00_axi_aresetn, SD_CLK,      response_1_sd_clk, s00_axi_aclk, response_1_axi_clk);
    bistable_domain_cross #(32) response_2_reg_cross                    (!s00_axi_aresetn, SD_CLK,      response_2_sd_clk, s00_axi_aclk, response_2_axi_clk);
    bistable_domain_cross #(32) response_3_reg_cross                    (!s00_axi_aresetn, SD_CLK,      response_3_sd_clk, s00_axi_aclk, response_3_axi_clk);
    bistable_domain_cross #(`DATA_TIMEOUT_W) data_timeout_reg_cross     (!s00_axi_aresetn, s00_axi_aclk, data_timeout_axi_clk, SD_CLK, data_timeout_sd_clk);
    bistable_domain_cross #(`BLKSIZE_W) block_size_cross                (!s00_axi_aresetn, s00_axi_aclk, block_size_axi_clk, SD_CLK, block_size_sd_clk);
    bistable_domain_cross #(1) controll_setting_cross                   (!s00_axi_aresetn, s00_axi_aclk, controll_setting_axi_clk, SD_CLK, controll_setting_sd_clk);
    bistable_domain_cross #(1) controll_setting_8bit_cross              (!s00_axi_aresetn, s00_axi_aclk, controll_setting_8bit_axi_clk, SD_CLK, controll_setting_8bit_sd_clk);
    bistable_domain_cross #(`INT_CMD_SIZE) cmd_int_status_cross         (!s00_axi_aresetn, SD_CLK, cmd_int_status_sd_clk, s00_axi_aclk, cmd_int_status_axi_clk);
    bistable_domain_cross #(1) read_trans_act_cross                     (!s00_axi_aresetn, SD_CLK, rd_trans_act_sd_clk, s00_axi_aclk, rd_trans_act_axi_clk);
    bistable_domain_cross #(1) read_trans_act_dev1_cross                (!s00_axi_aresetn, SD_CLK, rd_trans_act_dev1_sd_clk, s00_axi_aclk, rd_trans_act_dev1_axi_clk);
    bistable_domain_cross #(1) write_trans_act_cross                    (!s00_axi_aresetn, SD_CLK, wr_trans_act_sd_clk, s00_axi_aclk, wr_trans_act_axi_clk);
    bistable_domain_cross #(1) write_trans_act_dev1_cross               (!s00_axi_aresetn, SD_CLK, wr_trans_act_dev1_sd_clk, s00_axi_aclk, wr_trans_act_dev1_axi_clk);
    bistable_domain_cross #(1) data_line_act_cross                      (!s00_axi_aresetn, SD_CLK, data_busy, s00_axi_aclk, data_line_active_axi_clk);
    bistable_domain_cross #(1) command_inh_dat_cross                    (!s00_axi_aresetn, SD_CLK, sd_data_busy, s00_axi_aclk, command_inhibit_dat_axi_clk);
    bistable_domain_cross #(1) command_inh_dat_dev1_cross               (!s00_axi_aresetn, SD_CLK, sd_data_busy_dev1, s00_axi_aclk, command_inhibit_dat_dev1_axi_clk);
    bistable_domain_cross #(1) command_inh_cmd_cross                    (!s00_axi_aresetn, SD_CLK, command_inhibit_cmd_sd_clk, s00_axi_aclk, command_inhibit_cmd_axi_clk);
//    bistable_domain_cross #(1) command1_inh_cmd_cross                 (!s00_axi_aresetn, SD_CLK, command1_inhibit_cmd_sd_clk, s00_axi_aclk, command1_inhibit_cmd_axi_clk);
    bistable_domain_cross #(1) dat_trans_dir_cross                      (!s00_axi_aresetn, s00_axi_aclk, dat_trans_dir_axi_clk, SD_CLK, dat_trans_dir_sd_clk);
    bistable_domain_cross #(1) next_block                               (!s00_axi_aresetn, SD_CLK, next_block_st, s00_axi_aclk, next_block_st_axi);
    bistable_domain_cross #(1) next_block_dev1                          (!s00_axi_aresetn, SD_CLK, next_block_st_dev1, s00_axi_aclk, next_block_st_dev1_axi);
    bistable_domain_cross #(`BLKCNT_W) block_count_reg_cross            (!s00_axi_aresetn, s00_axi_aclk, block_count_axi_clk, SD_CLK, block_count_sd_clk);
    bistable_domain_cross #(`INT_DATA_SIZE) data_int_status_reg_cross   (!s00_axi_aresetn, SD_CLK, data_int_status_sd_clk, s00_axi_aclk, data_int_status_axi_clk);
    bistable_domain_cross #(3) UHSModSel_cross                          (!s00_axi_aresetn, s00_axi_aclk, UHSModSel_axi_clk, SD_CLK, UHSModSel_sd_clk);
    
    assign interrupt = |(int_status_reg & int_status_en_reg & int_signal_en_reg);
    
endmodule