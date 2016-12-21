`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2016 09:41:16 AM
// Design Name: 
// Module Name: RAID0
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RAID0(
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
        output wire [28:0] int_stat_o,
        output wire [`DATA_TIMEOUT_W-1:0] timeout_contr_wire,
        output wire sd_dat_bus_width,
        output wire sd_dat_bus_width_8bit,
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
        input wire cc_int_puls,
        output wire [2:0] UHSModSel
    );
endmodule
