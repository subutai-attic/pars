`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/19/2016 05:16:37 PM
// Design Name: 
// Module Name: sd_emmc_raid0
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
`include "sd_emmc_defines.h"

module sd_emmc_raid0(
           input axi_clk,
           input sd_clk,
           input hwreset,
           input rst,
           input start_i,
           input int_status_rst_i,
           output [1:0] setting_o,
           output reg start_xfr_o,
           output reg go_idle_o,
           output reg  [39:0] cmd_o,
           input [119:0] response_i,
           input [119:0] response1_i,
           input crc_ok_i,
           input crc1_ok_i,
           input index_ok_i,
           input index1_ok_i,
           input finish_i,
           input finish1_i,
           input busy_i, //direct signal from data sd data input (data[0])
           input [31:0] argument_i,
           input [`CMD_REG_SIZE-1:0] command_i,
           output [`INT_CMD_SIZE-1:0] int_status_o,
           output reg [31:0] response_0_o,
           output reg [31:0] response_1_o,
           output reg [31:0] response_2_o,
           output reg [31:0] response_3_o,
           output reg go_ahead_o,
           input inhibit_cmd_i,
           input inhibit_cmd1_i,
           input wire [31:0] read_fifo_data,
           output wire [31:0] m_axi_wdata,
           input [16:0] dma_data_cycles,
           input [1:0]  dma_int1,
           input [1:0]  adma_mst_state_i
       );

//-----------Types--------------------------------------------------------
reg [`CMD_TIMEOUT_W-1:0] timeout_reg;
reg crc_check;
reg index_check;
reg busy_check;
reg expect_response;
reg long_response;
reg [`INT_CMD_SIZE-1:0] int_status_reg;
reg [`CMD_TIMEOUT_W-1:0] watchdog;
parameter SIZE = 2;
(* mark_debug = "true" *) reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE       = 2'b00;
parameter EXECUTE    = 2'b01;
parameter BUSY_CHECK = 2'b10;
wire finish;
localparam NEW_SEC_COUNT = 32'h03AB4000;
wire [31:0] mult_emmc_cmd_resp;
reg ExtCSDModify;
wire [31:0] resp;
wire [31:0] resp1;

assign resp1 = response1_i[119:88];
assign resp  = response_i[119:88];

assign setting_o[1:0]       = {long_response, expect_response};
assign int_status_o         = state == IDLE ? int_status_reg : 5'h0;
assign finish               = finish_i & finish1_i;
assign mult_emmc_cmd_resp   = response_i[119:88] & response1_i[119:88];
assign m_axi_wdata          = ExtCSDModify ? NEW_SEC_COUNT : read_fifo_data;

always @(state or start_i or finish or go_idle_o or busy_check or busy_i)
begin: FSM_COMBO
    case(state)
        IDLE: begin
            if (start_i)
                next_state <= EXECUTE;
            else
                next_state <= IDLE;
        end
        EXECUTE: begin
            if ((finish && !busy_check) || go_idle_o)
                next_state <= IDLE;
            else if (finish && busy_check)
                next_state <= BUSY_CHECK;
            else
                next_state <= EXECUTE;
        end
        BUSY_CHECK: begin
            if (!busy_i)
                next_state <= IDLE;
            else
                next_state <= BUSY_CHECK;
        end
        default: next_state <= IDLE;
    endcase
end

always @(posedge sd_clk or posedge rst)
begin: FSM_SEQ
    if (rst) begin
        state <= IDLE;
    end
    else begin
        state <= next_state;
    end
end

always @(posedge sd_clk or posedge rst)
begin
    if (rst) begin
        crc_check <= 0;
        response_0_o <= 0;
        response_1_o <= 0;
        response_2_o <= 0;
        response_3_o <= 0;
        int_status_reg <= 0;
        expect_response <= 0;
        long_response <= 0;
        cmd_o <= 0;
        start_xfr_o <= 0;
        index_check <= 0;
        busy_check <= 0;
        watchdog <= 0;
        timeout_reg <= 0;
        go_idle_o <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                go_idle_o <= 0;
                index_check <= command_i[`CMD_IDX_CHECK];
                crc_check <= command_i[`CMD_CRC_CHECK];
                if (command_i[`CMD_RESPONSE_CHECK] == 2'b11) begin
                    busy_check <= 1'b1;
                end
                else begin
                    busy_check <= 1'b0;
                end
                if (command_i[`CMD_RESPONSE_CHECK]  == 2'b10 || command_i[`CMD_RESPONSE_CHECK] == 2'b11) begin
                    expect_response <=  1;
                    long_response <= 0;
                end
                else if (command_i[`CMD_RESPONSE_CHECK] == 2'b01) begin
                    expect_response <= 1;
                    long_response <= 1;
                end
                else begin
                    expect_response <= 0;
                    long_response <= 0;
                end
                cmd_o[39:38] <= 2'b01;
                cmd_o[37:32] <= command_i[`CMD_INDEX];  //CMD_INDEX
                cmd_o[31:0] <= argument_i;              //CMD_Argument0
                timeout_reg <= (command_i[`CMD_RESPONSE_CHECK] == 2'b10) ? 120 : ((command_i[`CMD_RESPONSE_CHECK] == 2'b01)? 250: 0);
                watchdog <= 0;
                if (start_i) begin
                    start_xfr_o <= 1;
                    int_status_reg <= 0;
                end
            end
            EXECUTE: begin
                start_xfr_o <= 0;
                watchdog <= watchdog + `CMD_TIMEOUT_W'd1;
                if (timeout_reg && watchdog >= timeout_reg) begin
                    int_status_reg[`INT_CMD_CTE] <= 1;
                    int_status_reg[`INT_CMD_EI] <= 1;
                    go_idle_o <= 1;
                end
                //Incoming New Status
                else begin //if ( req_in_int == 1) begin
                    if (finish) begin //Data avaible
                        if (crc_check & !crc_ok_i & !crc1_ok_i) begin
                            int_status_reg[`INT_CMD_CCRCE] <= 1;
                            int_status_reg[`INT_CMD_EI] <= 1;
                        end
                        if (index_check & !index_ok_i & !index1_ok_i) begin
                            int_status_reg[`INT_CMD_CIE] <= 1;
                            int_status_reg[`INT_CMD_EI] <= 1;
                        end
                        if (next_state != BUSY_CHECK) begin
                            int_status_reg[`INT_CMD_CC] <= 1;
                        end
                        if (expect_response != 0 & (~long_response)) begin
                            response_0_o <= mult_emmc_cmd_resp; //response_i[119:88];
                        end
                        else if (expect_response != 0 & long_response) begin
                            response_3_o <= {8'h00, response_i[119:96]};
                            response_2_o <= response_i[95:64];
                            response_1_o <= response_i[63:32];
                            response_0_o <= response_i[31:0];
                        end
                        // end
                    end ////Data avaible
                end //Status change
            end //EXECUTE state
            BUSY_CHECK: begin
                start_xfr_o <= 0;
                go_idle_o <= 0;
                if (next_state != BUSY_CHECK) begin
                    int_status_reg[`INT_CMD_CC] <= 1;
                    int_status_reg[`INT_CMD_DC] <= 1;
                end
            end
        endcase
        if (int_status_rst_i)
            int_status_reg <= 0;
    end
end

always @(posedge sd_clk or posedge rst)
begin: MULT_MMC_RESP_SYNC
  if (rst) begin
    go_ahead_o <= 0;
  end
  else begin
    if (inhibit_cmd_i && inhibit_cmd1_i) begin
      go_ahead_o <= 1;
    end
    else begin
      go_ahead_o <= 0;
    end
  end
end

(* mark_debug = "true" *) reg  [3:0] r_state;

localparam  R_PWR_ON    = 4'b1111,
            R_IDLE      = 4'b0000,
            R_READY     = 4'b0001,
            R_IDENT     = 4'b0010,
            R_STBY      = 4'b0011,
            R_TRANSF    = 4'b0100,
            R_RCV_DAT   = 4'b0101,  // *Remark: This state means storage receives data. Not HC receives.
            R_SND_DAT   = 4'b0110,  // *Remark: This state means storage sends data. Not HC sends.
            EXT_CSD_MOD = 4'b0111;

localparam  CMD0        = 6'b000000,
            CMD1        = 6'b000001,
            CMD2        = 6'b000010,
            CMD3        = 6'b000011,
            CMD7        = 6'b000111,
            CMD8        = 6'b001000,
            CMD17       = 6'b010001,
            CMD18       = 6'b010010,
            CMD24       = 6'b011000,
            CMD25       = 6'b011001;
            
 
always @(posedge axi_clk or posedge hwreset)
begin: RAID_FSM_CMD_LYR
  if (hwreset) begin
    r_state <= R_PWR_ON;
  end
  else begin
    case (r_state)
      R_PWR_ON: begin
                  if (command_i[`CMD_INDEX] == CMD0 && finish)
                    r_state <= R_IDLE;
                  end
      R_IDLE: begin
                if (command_i[`CMD_INDEX] == CMD1 && mult_emmc_cmd_resp == 32'hC0FF_8080)
                  r_state <= R_READY;
              end
      R_READY: begin
                 if (command_i[`CMD_INDEX] == CMD2 && finish)
                   r_state <= R_IDENT;
                 else if (command_i[`CMD_INDEX] == CMD0 && finish)
                   r_state <= R_IDLE;
               end
      R_IDENT: begin
                 if (command_i[`CMD_INDEX] == CMD3 && mult_emmc_cmd_resp == 32'h0000_0500) // card status is READY_FOR_DATA and CURRENT_STATE = Ident
                   r_state <= R_STBY;
               else if (command_i[`CMD_INDEX] == CMD0 && finish)
                 r_state <= R_IDLE;
               end
      R_STBY: begin
                if (command_i[`CMD_INDEX] == CMD7 && mult_emmc_cmd_resp == 32'h0000_0700) // card status is READY_FOR_DATA and CURRENT_STATE = Stby
                  r_state <= R_TRANSF;
                else if (command_i[`CMD_INDEX] == CMD0 && finish)
                  r_state <= R_IDLE;
              end
      R_TRANSF: begin
                  ExtCSDModify <= 1'b0;
                  if (command_i[`CMD_INDEX] == CMD8 && mult_emmc_cmd_resp == 32'h0000_0900 && finish)  // card status is READY_FOR_DATA and CURRENT_STATE = transf
                    r_state <= EXT_CSD_MOD;
                  else if ((command_i[`CMD_INDEX] == (CMD24 || CMD25)) && mult_emmc_cmd_resp == 32'h0000_0900 && finish)
                    r_state <= R_RCV_DAT;
                  else if (command_i[`CMD_INDEX] == CMD0 && finish)
                    r_state <= R_IDLE;
                end
      EXT_CSD_MOD: begin
                     if(dma_data_cycles == 52) begin
                       ExtCSDModify <= 1'b0;
                       r_state <= R_TRANSF;
                     end
                   end
      R_RCV_DAT: begin
                 end
      R_SND_DAT: begin
                 end
    endcase
  end
end









endmodule
