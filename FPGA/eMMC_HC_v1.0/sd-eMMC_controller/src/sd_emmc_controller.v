`timescale 1 ns / 1 ps
`include "sd_defines.h"
        module sd_emmc_controller #
        (
                // Users to add parameters here

                // User parameters ends
                // Do not modify the parameters beyond this line


 		// Parameters of Axi Slave Bus Interface S00_AXI
                parameter integer C_S00_AXI_DATA_WIDTH    = 32,
                parameter integer C_S00_AXI_ADDR_WIDTH    = 7
              //  parameter integer C_M_AXIS_TDATA_WIDTH  = 32, 
              //  parameter integer C_M_AXIS_START_COUNT  = 32
      )
        (
        //SD interface
        output wire SD_CLK,
        output wire sd_cmd_o,
        input wire sd_cmd_i,
        output wire sd_cmd_t,
        output wire [3:0] sd_dat_o,
        input wire [3:0] sd_dat_i,
        output wire sd_dat_t,
        
        // Interupt pinout 
        output wire interrupt,
//        output wire int_data,
        
     // MAXIS
     //   input wire  m_axis_aclk,
     //   input wire  m_axis_aresetn,
     //   output wire  m_axis_tvalid,
     //   output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
     //   output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tstrb,
     //   output wire  m_axis_tlast,
     //   input wire  m_axis_tready,

        //input wire sd_card_detect,

                // User ports ends
                // Do not modify the ports beyond this line


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
                input wire  s00_axi_rready
        );
//SD clock
    wire [7:0]  divisor;
//    wire int_clk_en;
    wire int_clk_stbl;

    wire go_idle;
    wire cmd_start_wb_clk;
    wire cmd_start_sd_clk;
    wire cmd_start;
    wire [1:0] cmd_setting;
    wire cmd_start_tx;
    wire [39:0] cmd;
    wire [119:0] cmd_response;
    wire cmd_crc_ok;
    wire cmd_index_ok;
    wire cmd_finish;

    wire d_write;
    wire d_read;
    wire [31:0] data_in_rx_fifo;
    wire [31:0] data_out_tx_fifo;
    wire start_tx_fifo;
    wire start_rx_fifo;
    wire tx_fifo_empty;
    wire tx_fifo_full;
    wire rx_fifo_full;
    wire sd_data_busy;
    wire data_busy;
    wire data_crc_ok;
    wire rd_fifo;
    wire we_fifo;

    wire data_start_rx;
    wire data_start_tx;
    wire cmd_int_rst_wb_clk;
    wire cmd_int_rst_sd_clk;
    wire cmd_int_rst;
    wire data_int_rst_wb_clk;
    wire data_int_rst_sd_clk;
    wire data_int_rst;

    //wb accessible registers
    wire [31:0] argument_reg_wb_clk;
    wire [`CMD_REG_SIZE-1:0] command_reg_wb_clk;
    wire [`CMD_TIMEOUT_W-1:0] cmd_timeout_reg_wb_clk;
    wire [`DATA_TIMEOUT_W-1:0] data_timeout_reg_wb_clk;
    wire [1:0] software_reset_reg_axi_clk;
    wire [31:0] response_0_reg_wb_clk;
    wire [31:0] response_1_reg_wb_clk;
    wire [31:0] response_2_reg_wb_clk;
    wire [31:0] response_3_reg_wb_clk;
    wire [`BLKSIZE_W-1:0] block_size_reg_axi_clk;
    wire controll_setting_reg_wb_clk;
    wire [`INT_CMD_SIZE-1:0] cmd_int_status_reg_wb_clk;
    wire [`INT_DATA_SIZE-1:0] data_int_status_reg_wb_clk;
    wire [`INT_CMD_SIZE-1:0] cmd_int_enable_reg_wb_clk;
    wire [`INT_DATA_SIZE-1:0] data_int_enable_reg_wb_clk;
    wire [`BLKCNT_W-1:0] block_count_reg_axi_clk;
    wire [31:0] dma_addr_reg_wb_clk;
    wire [7:0] clock_divider_reg_wb_clk;

    wire [31:0] argument_reg_sd_clk;
    wire [`CMD_REG_SIZE-1:0] command_reg_sd_clk;
    wire [`CMD_TIMEOUT_W-1:0] cmd_timeout_reg_sd_clk;
    wire [`DATA_TIMEOUT_W-1:0] data_timeout_reg_sd_clk;
    wire [2:0] software_reset_reg_sd_clk;
    wire [31:0] response_0_reg_sd_clk;
    wire [31:0] response_1_reg_sd_clk;
    wire [31:0] response_2_reg_sd_clk;
    wire [31:0] response_3_reg_sd_clk;
    wire [`BLKSIZE_W-1:0] block_size_reg_sd_clk;
    wire controll_setting_reg_sd_clk;
    wire [`INT_CMD_SIZE-1:0] cmd_int_status_reg_sd_clk;
    wire [`INT_DATA_SIZE-1:0] data_int_status_reg_sd_clk;
    wire [`BLKCNT_W-1:0] block_count_reg_sd_clk;
    wire [1:0] dma_addr_reg_sd_clk;
    wire [7:0] clock_divider_reg_sd_clk;
    
    //Software Reset
    wire soft_rst_cmd_axi_clk;
    wire soft_rst_dat_axi_clk;
    wire soft_rst_cmd_sd_clk;
    wire soft_rst_dat_sd_clk;
    wire cmd_serial_h_rst_h;
    wire data_master_rst_ack;
    wire next_block_st;
    wire fifo_reset;
    
    //Interrupts
    wire [28:0] int_status_reg;
    wire [28:0] int_status_en_reg;
    wire [28:0] int_signal_en_reg;

    // Present state register
    wire tx_fifo_full_axi_clk;
    wire rx_fifo_empty_sd_clk;
    wire rx_fifo_empty_axi_clk;
    wire rd_trans_act_axi_clk;
    wire rd_trans_act_sd_clk;
    wire wr_trans_act_axi_clk;
    wire wr_trans_act_sd_clk;
    wire command_inhibit_dat_axi_clk;
    wire data_line_active_axi_clk;
    wire command_inhibit_cmd_sd_clk;
    wire command_inhibit_cmd_axi_clk;
    
    // Transfer mode register
    wire dat_trans_dir_axi_clk;
    wire dat_trans_dir_sd_clk;
    wire [31:0] read_fifo_out;
    wire [31:0] write_fifo_out;
    wire        fifo_data_read_ready;
    wire        fifo_data_write_ready;
    
    // data write to SD card
    wire start_tx;
    wire start_write_sd_clk;


// Instantiation of Axi Bus Interface S00_AXI
        sd_emmc_controller_S00_AXI # ( 
            .C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
            .C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
        ) sd_emmc_controller_S00_AXI_inst (
            .S_AXI_ACLK(s00_axi_aclk),
            .S_AXI_ARESETN(s00_axi_aresetn),
            .S_AXI_AWADDR(s00_axi_awaddr),
            .S_AXI_AWPROT(s00_axi_awprot),
            .S_AXI_AWVALID(s00_axi_awvalid),
            .S_AXI_AWREADY(s00_axi_awready),
            .S_AXI_WDATA(s00_axi_wdata),
            .S_AXI_WSTRB(s00_axi_wstrb),
            .S_AXI_WVALID(s00_axi_wvalid),
            .S_AXI_WREADY(s00_axi_wready),
            .S_AXI_BRESP(s00_axi_bresp),
            .S_AXI_BVALID(s00_axi_bvalid),
            .S_AXI_BREADY(s00_axi_bready),
            .S_AXI_ARADDR(s00_axi_araddr),
            .S_AXI_ARPROT(s00_axi_arprot),
            .S_AXI_ARVALID(s00_axi_arvalid),
            .S_AXI_ARREADY(s00_axi_arready),
            .S_AXI_RDATA(s00_axi_rdata),
            .S_AXI_RRESP(s00_axi_rresp),
            .S_AXI_RVALID(s00_axi_rvalid),
            .S_AXI_RREADY(s00_axi_rready),
            .read_fifo_in(read_fifo_out),
            .write_fifo_out(write_fifo_out),
            .fifo_data_read_ready(fifo_data_read_ready),
            .fifo_data_write_ready(fifo_data_write_ready),
            .clock_divisor(divisor),
//            .internal_clock_en(int_clk_en),
            .Internal_clk_stable(int_clk_stbl),
            .cmd_start(cmd_start),
            .cmd_int_rst(cmd_int_rst),
            .dat_int_rst(data_int_rst),
            .block_size_reg(block_size_reg_axi_clk),
            .block_count_reg(block_count_reg_axi_clk),
            .argument_reg(argument_reg_wb_clk),
            .command_reg(command_reg_wb_clk),
            .response_0_reg(response_0_reg_wb_clk),
            .response_1_reg(response_1_reg_wb_clk),
            .response_2_reg(response_2_reg_wb_clk),
            .response_3_reg(response_3_reg_wb_clk),
            .software_reset_reg(software_reset_reg_axi_clk),  
            .fifo_reset(fifo_reset),          
            .timeout_reg(cmd_timeout_reg_wb_clk),
            .cmd_int_st(cmd_int_status_reg_wb_clk),
            .dat_int_st(data_int_status_reg_wb_clk),
            .rst_compl_cmd(cmd_serial_h_rst_h),
            .rst_compl_dat(data_master_rst_ack),
            .int_stat_reg(int_status_reg),
            .int_stat_en_reg(int_status_en_reg),
            .int_sig_en_reg(int_signal_en_reg),
            .timeout_contr_wire(data_timeout_reg_wb_clk),
            .sd_dat_bus_width(controll_setting_reg_wb_clk),
            .buff_read_en(!rx_fifo_empty_axi_clk),
            .buff_writ_en(!tx_fifo_full_axi_clk),
            .write_trans_active(wr_trans_act_axi_clk),
            .read_trans_active(rd_trans_act_axi_clk),
            .dat_line_act(data_line_active_axi_clk),
            .command_inh_dat(command_inhibit_dat_axi_clk),
            .com_inh_cmd(command_inhibit_cmd_axi_clk),
            .data_transfer_direction(dat_trans_dir_axi_clk),
            .start_tx_fifo_i(start_tx_fifo),
            .start_tx_o(start_tx)
        );

    // Clock divider
        sd_clock_divider sd_clock_divider_i (
            .AXI_CLOCK(s00_axi_aclk),
            .sd_clk(SD_CLK),
            .DIVISOR(divisor),
            .AXI_RST(s00_axi_aresetn/* & int_clk_en*/),
            .Internal_clk_stable(int_clk_stbl)
        );

    sd_cmd_master sd_cmd_master0(
        .sd_clk       (SD_CLK),
        .rst          (!s00_axi_aresetn | 
                        soft_rst_cmd_sd_clk),
        .start_i      (cmd_start_sd_clk),
        .int_status_rst_i(cmd_int_rst_sd_clk),
        .setting_o    (cmd_setting),
        .start_xfr_o  (cmd_start_tx),
        .go_idle_o    (go_idle),
        .cmd_o        (cmd),
        .response_i   (cmd_response),
        .crc_ok_i     (cmd_crc_ok),
        .index_ok_i   (cmd_index_ok),
        .busy_i       (sd_data_busy),
        .finish_i     (cmd_finish),
        .argument_i   (argument_reg_sd_clk),
        .command_i    (command_reg_sd_clk),
        .timeout_i    (cmd_timeout_reg_sd_clk),
        .int_status_o (cmd_int_status_reg_sd_clk),
        .response_0_o (response_0_reg_sd_clk),
        .response_1_o (response_1_reg_sd_clk),
        .response_2_o (response_2_reg_sd_clk),
        .response_3_o (response_3_reg_sd_clk)
        );

    sd_mmc_cmd_serial_host cmd_serial_host0(
        .sd_clk     (SD_CLK),
        .rst        (!s00_axi_aresetn | 
                     soft_rst_cmd_sd_clk |
                     go_idle),
        .setting_i  (cmd_setting),
        .cmd_i      (cmd),
        .start_i    (cmd_start_tx),
        .finish_o   (cmd_finish),
        .response_o (cmd_response),
        .crc_ok_o   (cmd_crc_ok),
        .index_ok_o (cmd_index_ok),
        .cmd_dat_i  (sd_cmd_i),
        .cmd_out_o  (sd_cmd_o),
        .cmd_oe_o   (sd_cmd_t),
        .rst_ack_cmd_serial_h (cmd_serial_h_rst_h),
        .command_inhibit_cmd (command_inhibit_cmd_sd_clk)
        );

    sd_data_master sd_data_master0(
        .sd_clk           (SD_CLK),
        .rst              (!s00_axi_aresetn | 
                           soft_rst_dat_sd_clk ),
        .start_tx_i       (data_start_tx),
        .start_rx_i       (data_start_rx),
        .timeout_i          (data_timeout_reg_sd_clk),
        .d_write_o        (d_write),
        .d_read_o         (d_read),
        .start_tx_fifo_o  (start_tx_fifo),
        .start_rx_fifo_o  (start_rx_fifo),
        .tx_fifo_empty_i  (tx_fifo_empty),
        .tx_fifo_full_i   (tx_fifo_full),
        .rx_fifo_full_i   (rx_fifo_full),
        .xfr_complete_i   (!data_busy),
        .crc_ok_i         (data_crc_ok),
        .int_status_o     (data_int_status_reg_sd_clk),
        .int_status_rst_i (data_int_rst_sd_clk),
        .rst_ack_dat_master (data_master_rst_ack),
        .next_block(next_block_st),
        .start_write(start_write_sd_clk)
        );

    sd_data_serial_host sd_data_serial_host0(
        .sd_clk         (SD_CLK),
        .rst            (!s00_axi_aresetn | 
                        soft_rst_dat_sd_clk ),
        .data_in        (data_out_tx_fifo),
        .rd             (rd_fifo),
        .data_out_o       (data_in_rx_fifo),
        .we             (we_fifo),
        .DAT_oe_o       (sd_dat_t),
        .DAT_dat_o      (sd_dat_o),
        .DAT_dat_i      (sd_dat_i),
        .blksize        (block_size_reg_sd_clk),
        .bus_4bit       (controll_setting_reg_sd_clk),
        .blkcnt         (block_count_reg_sd_clk),
        .start          ({d_read, d_write}),
        .byte_alignment (dma_addr_reg_sd_clk),
        .sd_data_busy   (sd_data_busy),
        .busy           (data_busy),
        .crc_ok         (data_crc_ok),
        .TLAST          (m_axis_tlast),
        .read_trans_active (rd_trans_act_sd_clk),
        .write_trans_active(wr_trans_act_sd_clk),
        .next_block(next_block_st),
        .start_write(start_write_sd_clk)
        );

    sd_fifo_filler sd_fifo_filler0(
        .wb_clk    (s00_axi_aclk),
        .rst       (!s00_axi_aresetn |
                    soft_rst_dat_sd_clk ),
        .wbm_adr_o (wbm_adr),
        .wbm_we_o  (m_wb_we_o),
        .read_fifo_out (read_fifo_out),
        .write_fifo_in (write_fifo_out),
        .wbm_cyc_o (m_wb_cyc_o),
        .wbm_stb_o (m_wb_stb_o),
        .fifo_data_read_ready (fifo_data_read_ready),
        .fifo_data_write_ready(fifo_data_write_ready),
        .en_rx_i   (start_rx_fifo),
        .en_tx_i   (start_tx_fifo),
        .adr_i     (dma_addr_reg_wb_clk),
        .sd_clk    (SD_CLK),
        .dat_i     (data_in_rx_fifo),
        .dat_o     (data_out_tx_fifo),
        .wr_i      (we_fifo),
        .rd_i      (rd_fifo),
        .sd_empty_o  (tx_fifo_empty),
        .sd_full_o   (rx_fifo_full),
        .wb_full_o   (tx_fifo_full),
        .wb_empty_o  (rx_fifo_empty_sd_clk),
        .fifo_reset(fifo_reset)
        );

    sd_data_xfer_trig sd_data_xfer_trig0 (
        .sd_clk                (SD_CLK),
        .rst                   (!s00_axi_aresetn |
                                soft_rst_dat_sd_clk ),
        .cmd_with_data_start_i (cmd_start_sd_clk & (command_reg_sd_clk[5] == 1'b1)),
        .r_w_i                 (dat_trans_dir_sd_clk == 1'b1),
        .cmd_int_status_i      (cmd_int_status_reg_sd_clk),
        .start_tx_o            (data_start_tx),
        .start_rx_o            (data_start_rx)
        );

    edge_detect soft_reset_edge_cmd(.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(software_reset_reg_axi_clk[0]), .rise(soft_rst_cmd_axi_clk), .fall());
    edge_detect sotf_reset_edge_dat(.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(software_reset_reg_axi_clk[1]), .rise(soft_rst_dat_axi_clk), .fall());
    
    edge_detect cmd_start_edge(.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(cmd_start), .rise(cmd_start_wb_clk), .fall());
    edge_detect dat_int_rst_edge(.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(data_int_rst), .rise(data_int_rst_wb_clk), .fall());
    edge_detect cmd_int_rst_edge(.rst(!s00_axi_aresetn), .clk(s00_axi_aclk), .sig(cmd_int_rst), .rise(cmd_int_rst_wb_clk), .fall());
    
    monostable_domain_cross soft_reset_cross_cmd(!s00_axi_aresetn, s00_axi_aclk, soft_rst_cmd_axi_clk, SD_CLK, soft_rst_cmd_sd_clk);
    monostable_domain_cross soft_reset_cross_dat(!s00_axi_aresetn, s00_axi_aclk, soft_rst_dat_axi_clk, SD_CLK, soft_rst_dat_sd_clk);

    monostable_domain_cross cmd_start_cross(!s00_axi_aresetn, s00_axi_aclk, cmd_start_wb_clk, SD_CLK, cmd_start_sd_clk);
    monostable_domain_cross data_int_rst_cross(!s00_axi_aresetn, s00_axi_aclk, data_int_rst_wb_clk, SD_CLK, data_int_rst_sd_clk);
    monostable_domain_cross cmd_int_rst_cross(!s00_axi_aresetn, s00_axi_aclk, cmd_int_rst_wb_clk, SD_CLK, cmd_int_rst_sd_clk);

    bistable_domain_cross #(1) data_write_cross(!s00_axi_aresetn, s00_axi_aclk, start_tx, SD_CLK, start_write_sd_clk);

    bistable_domain_cross #(32) argument_reg_cross(!s00_axi_aresetn, s00_axi_aclk, argument_reg_wb_clk, SD_CLK, argument_reg_sd_clk);
    bistable_domain_cross #(`CMD_REG_SIZE) command_reg_cross(!s00_axi_aresetn, s00_axi_aclk, command_reg_wb_clk, SD_CLK, command_reg_sd_clk);
    bistable_domain_cross #(32) response_0_reg_cross(!s00_axi_aresetn, SD_CLK, response_0_reg_sd_clk, s00_axi_aclk, response_0_reg_wb_clk);
    bistable_domain_cross #(32) response_1_reg_cross(!s00_axi_aresetn, SD_CLK, response_1_reg_sd_clk, s00_axi_aclk, response_1_reg_wb_clk);
    bistable_domain_cross #(32) response_2_reg_cross(!s00_axi_aresetn, SD_CLK, response_2_reg_sd_clk, s00_axi_aclk, response_2_reg_wb_clk);
    bistable_domain_cross #(32) response_3_reg_cross(!s00_axi_aresetn, SD_CLK, response_3_reg_sd_clk, s00_axi_aclk, response_3_reg_wb_clk);
    bistable_domain_cross #(`CMD_TIMEOUT_W) cmd_timeout_reg_cross(!s00_axi_aresetn, s00_axi_aclk, cmd_timeout_reg_wb_clk, SD_CLK, cmd_timeout_reg_sd_clk);
    bistable_domain_cross #(`DATA_TIMEOUT_W) data_timeout_reg_cross(!s00_axi_aresetn, s00_axi_aclk, data_timeout_reg_wb_clk, SD_CLK, data_timeout_reg_sd_clk);
    bistable_domain_cross #(`BLKSIZE_W) block_size_reg_cross(!s00_axi_aresetn, s00_axi_aclk, block_size_reg_axi_clk, SD_CLK, block_size_reg_sd_clk);
    bistable_domain_cross #(1) controll_setting_reg_cross(!s00_axi_aresetn, s00_axi_aclk, controll_setting_reg_wb_clk, SD_CLK, controll_setting_reg_sd_clk);
    bistable_domain_cross #(`INT_CMD_SIZE) cmd_int_status_reg_cross(!s00_axi_aresetn, SD_CLK, cmd_int_status_reg_sd_clk, s00_axi_aclk, cmd_int_status_reg_wb_clk);
    
    bistable_domain_cross #(1) buffer_read_enable_cross(!s00_axi_aresetn, SD_CLK, rx_fifo_empty_sd_clk, s00_axi_aclk, rx_fifo_empty_axi_clk);
    bistable_domain_cross #(1) buffer_write_enable_cross(!s00_axi_aresetn, SD_CLK, tx_fifo_full, s00_axi_aclk, tx_fifo_full_axi_clk);
    bistable_domain_cross #(1) read_trans_act_cross(!s00_axi_aresetn, SD_CLK, rd_trans_act_sd_clk, s00_axi_aclk, rd_trans_act_axi_clk);
    bistable_domain_cross #(1) write_trans_act_cross(!s00_axi_aresetn, SD_CLK, wr_trans_act_sd_clk, s00_axi_aclk, wr_trans_act_axi_clk);
    bistable_domain_cross #(1) data_line_act_cross(!s00_axi_aresetn, SD_CLK, data_busy, s00_axi_aclk, data_line_active_axi_clk);
    bistable_domain_cross #(1) command_inh_dat_cross(!s00_axi_aresetn, SD_CLK, sd_data_busy, s00_axi_aclk, command_inhibit_dat_axi_clk);
    bistable_domain_cross #(1) command_inh_cmd_cross(!s00_axi_aresetn, SD_CLK, command_inhibit_cmd_sd_clk, s00_axi_aclk, command_inhibit_cmd_axi_clk);
    bistable_domain_cross #(1) dat_trans_dir_cross(!s00_axi_aresetn, s00_axi_aclk, dat_trans_dir_axi_clk, SD_CLK, dat_trans_dir_sd_clk);
    
   // bistable_domain_cross #(8) clock_divider_reg_cross(!s00_axi_aresetn, s00_axi_aclk, clock_divider_reg_wb_clk, s00_axi_aclk, clock_divider_reg_sd_clk);
    bistable_domain_cross #(`BLKCNT_W) block_count_reg_cross(!s00_axi_aresetn, s00_axi_aclk, block_count_reg_axi_clk, SD_CLK, block_count_reg_sd_clk);
    bistable_domain_cross #(2) dma_addr_reg_cross(!s00_axi_aresetn, s00_axi_aclk, 0, SD_CLK, dma_addr_reg_sd_clk);
    bistable_domain_cross #(`INT_DATA_SIZE) data_int_status_reg_cross(!s00_axi_aresetn, SD_CLK, data_int_status_reg_sd_clk, s00_axi_aclk, data_int_status_reg_wb_clk);
    
    
   // assign m_axis_tstrb = 4'b1111;
    assign interrupt = |(int_status_reg & int_status_en_reg & int_signal_en_reg);
//    assign int_data = |(data_int_status_reg_wb_clk & data_int_enable_reg_wb_clk);
    
endmodule