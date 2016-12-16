//////////////////////////////////////////////////////////////////////
// Company: Optimal Dynamics LLC
// Engineer: Azamat Beksadaev, Baktiiar Kukanov 
// 
// Create Date: 10/02/2015 11:41:32 AM
// Design Name: 
// Module Name: data_serial
// Project Name: eMMC Host Controller
// Target Devices: Xilinx ZYNQ 7000
// Tool Versions: Vivado 2016.2
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// AXI SD-eMMC Card Controller IP Core                          ////
////                                                              ////
//// sd_data_serial_host.v                                        ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
////                                                              ////
////                                                              ////
//// Description                                                  ////
//// Module resposible for sending and receiving data through     ////
//// 4 and 8-bits eMMC card data interface                        ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
////                                                              ////
//// Contributers:                                                ////
////     - Azamat Beksadaev, abeksadaev@gmail.com                 ////
////     - Baktiiar Kukanov,                                      ////
////     - Eldar Ismailov                                         ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2013 Authors                                   ////
////                                                              ////
//// Based on original work by                                    ////
////     Adam Edvardsson (adam.edvardsson@orsoc.se)               ////
////                                                              ////
////     Copyright (C) 2009 Authors                               ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE. See the GNU Lesser General Public License for more  ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
`include "sd_emmc_defines.h"

module sd_data_serial_host(
           input sd_clk,
           input sd_clk90,
           input rst,
           //Tx Fifo
           input [31:0] data_in,
           output reg rd,
           //Rx Fifo
           output wire [31:0] data_out_o,
           output reg we,
           //tristate data
           output reg DAT_oe_o,
           output [7:0] DAT_dat_o,
           input [7:0] DAT_dat_i,
           //Controll signals
           input [`BLKSIZE_W-1:0] blksize,
           input bus_4bit,
           input bus_8bit,
           input [`BLKCNT_W-1:0] blkcnt,
           input [1:0] start,
           output sd_data_busy,
           output busy,
           output reg crc_ok,
           output read_trans_active,
           output write_trans_active,
           input start_write,
           output wire write_next_block,
           input wire [2:0] UHSMode
       );
       

reg [7:0] DAT_dat_reg;
wire [`BLKSIZE_W-1+3:0] data_cycles;
reg bus_4bit_reg;
reg bus_8bit_reg;
//CRC16
reg [15:0] crc_in;
reg crc_en;
reg crc_rst;
wire [15:0] crc_out [15:0];
reg [`BLKSIZE_W-1+4:0] transf_cnt;
parameter SIZE = 6;
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
parameter IDLE       = 6'b000001;
parameter WRITE_DAT  = 6'b000010;
parameter WRITE_WAIT  = 6'b000011;
parameter WRITE_CRC  = 6'b000100;
parameter WRITE_BUSY = 6'b001000;
parameter READ_WAIT  = 6'b010000;
parameter READ_DAT   = 6'b100000;
reg [3:0] crc_status;
reg busy_int;
reg [`BLKCNT_W-1:0] blkcnt_reg;
reg [`BLKSIZE_W-1:0] blksize_reg;
reg next_block;
wire start_bit;
reg [4:0] crc_c;
reg [7:0] last_din;
reg [3:0] crc_s;
reg [4:0] data_index;
reg [31:0] data_out;
wire [7:0] iddrQ1;
wire [7:0] iddrQ2;
wire DDR50;
reg [7:0] last_dinDDR;
reg [15:0] d1d2_reg;
reg [7:0] DAT_dat_regn;

assign data_out_o [31:0] = {data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24]};
assign DDR50 = UHSMode == 3'b100 ? 1'b1: 1'b0;
assign data_cycles = (bus_8bit && DDR50) ? blksize >> 1 : (bus_8bit && !DDR50) ? blksize : bus_4bit ? blksize << 1 : blksize << 3;


//sd data input pad register
always @(posedge sd_clk)
    DAT_dat_reg <= iddrQ1;

//sd data input pad register
always @(negedge sd_clk)
    DAT_dat_regn <= iddrQ2;
genvar i;
generate
    for(i=0; i<16; i=i+1) begin: CRC_16_gen
        sd_crc_16 CRC_16_i(
          crc_in[i],
          crc_en,
          sd_clk,
          crc_rst,
          crc_out[i]
          );
    end
endgenerate

IDDR_p IDDR_p_inst(
  .reset(rst),
  .clock(sd_clk),
  .in_ddr(DAT_dat_i),
  .iddr_Q1(iddrQ1),
  .iddr_Q2(iddrQ2)
);

ODDR_p ODDR_p_inst(
  .reset(rst),
  .clock(sd_clk90),
  .d1_wire(d1d2_reg[7:0]),
  .d2_wire(d1d2_reg[15:8]),
  .oq(DAT_dat_o)
);

assign busy = (state != IDLE);
assign start_bit = !DAT_dat_reg[0];
assign sd_data_busy = !DAT_dat_reg[0];
assign read_trans_active = ((state == READ_DAT) || (state == READ_WAIT));
assign write_trans_active = ((state == WRITE_DAT) || (state == WRITE_BUSY) || (state == WRITE_CRC) || (state == WRITE_WAIT));
assign write_next_block = ((state == WRITE_WAIT) && DAT_dat_reg[0] && next_block);

always @(state or start or start_bit or  transf_cnt or data_cycles or crc_status or crc_ok or busy_int or next_block or start_write)
begin: FSM_COMBO
    case(state)
        IDLE: begin
            if (start == 2'b01)
                next_state <= WRITE_WAIT;
            else if  (start == 2'b10)
                next_state <= READ_WAIT;
            else
                next_state <= IDLE;
        end
        WRITE_WAIT: begin
            if (start_write && DAT_dat_reg[0])
                next_state <= WRITE_DAT;
            else
                next_state <= WRITE_WAIT;
        end
        WRITE_DAT: begin
            if (transf_cnt >= data_cycles+20 && start_bit)
                next_state <= WRITE_CRC;
            else
                next_state <= WRITE_DAT;
        end
        WRITE_CRC: begin
            if (crc_status == 3)
                next_state <= WRITE_BUSY;
            else
                next_state <= WRITE_CRC;
        end
        WRITE_BUSY: begin
            if (!busy_int && next_block && crc_ok)
                next_state <= WRITE_WAIT;
            else if (!busy_int)
                next_state <= IDLE;
            else
                next_state <= WRITE_BUSY;
        end
        READ_WAIT: begin
            if (start_bit)
                next_state <= READ_DAT;
            else
                next_state <= READ_WAIT;
        end
        READ_DAT: begin
            if (transf_cnt == data_cycles+17) begin
              if(next_block && crc_ok)
                next_state <= READ_WAIT;
              else
                next_state <= IDLE;
            end
            else
                next_state <= READ_DAT;
        end
        default: next_state <= IDLE;
    endcase
    //abort
    if (start == 2'b11)
        next_state <= IDLE;
end

always @(posedge sd_clk or posedge rst)
begin: FSM_OUT
    if (rst) begin
        state <= IDLE;
        DAT_oe_o <= 1;
        crc_en <= 0;
        crc_rst <= 1;
        transf_cnt <= 0;
        rd <= 0;
        last_din <= 0;
        d1d2_reg <= 0;
        last_dinDDR <= 0;
        crc_c <= 0;
        crc_in <= 0;
        crc_status <= 0;
        crc_s <= 0;
        we <= 0;
        data_out <= 0;
        crc_ok <= 0;
        busy_int <= 0;
        data_index <= 0;
        next_block <= 0;
        blkcnt_reg <= 0;
        bus_4bit_reg <= 0;
        bus_8bit_reg <= 0;
    end
    else begin
        state <= next_state;
        case(state)
            IDLE: begin
                DAT_oe_o <= 1;
                crc_en <= 0;
                crc_rst <= 1;
                transf_cnt <= 0;
                crc_c <= 15;
                crc_status <= 0;
                crc_s <= 0;
                we <= 0;
                rd <= 0;
                data_index <= 0;
                next_block <= 0;
                blkcnt_reg <= blkcnt;
                blksize_reg <= blksize;
                bus_4bit_reg <= bus_4bit;
                bus_8bit_reg <= bus_8bit;
                d1d2_reg <= 16'hffff;
            end
            WRITE_WAIT: begin
                data_index <= 0;
                next_block <= 0;
            end
            WRITE_DAT: begin
                crc_ok <= 0;
                transf_cnt <= transf_cnt + 1;
                rd <= 0;
                if (transf_cnt == 0) begin
                  crc_rst <= 0;
                  crc_en <= 1;
                  DAT_oe_o <= 0;
                  d1d2_reg <= bus_8bit_reg ? 16'h0000 :(bus_4bit_reg ? 16'hF0F0 : 16'hFEFE);
                  data_index <= 5'h01;
                  if (bus_8bit_reg) begin
                    if (DDR50) begin
                      last_din <= data_in[31:24];
                      last_dinDDR <= data_in[23:16];
                      crc_in <= {data_in[23:16], data_in[31:24]};
                      rd <= 1'b1;
                    end
                    else begin
                      last_din <= data_in[31:24];
                      crc_in <= data_in[31:24];
                    end
                  end
                  else if (bus_4bit_reg) begin
                    if (DDR50) begin
                      last_din <= {4'hF, data_in[31:24]};
                      last_dinDDR <= {4'hF, data_in[23:16]};
                    end
                    else begin
                      last_din <= {4'hF,data_in[31:28]};
                      crc_in <= {4'hF,data_in[31:28]};
                    end
                  end
                  else begin
                    last_din <= {7'h7F, data_in[31]};
                    crc_in <= {7'h7F, data_in[31]};
                  end
                end
                else if ((transf_cnt >= 1) && (transf_cnt <= data_cycles)) begin
                    data_index <= data_index + 1;
                    if (bus_8bit_reg) begin
                      if(DDR50) begin
                        d1d2_reg <= {last_dinDDR, last_din};                      
                        last_din <= {
                            data_in[31-(data_index[0]<<4)], 
                            data_in[30-(data_index[0]<<4)], 
                            data_in[29-(data_index[0]<<4)], 
                            data_in[28-(data_index[0]<<4)],
                            data_in[27-(data_index[0]<<4)], 
                            data_in[26-(data_index[0]<<4)], 
                            data_in[25-(data_index[0]<<4)], 
                            data_in[24-(data_index[0]<<4)]
                            };
                        last_dinDDR <= {
                            data_in[23-(data_index[0]<<4)],
                            data_in[22-(data_index[0]<<4)],
                            data_in[21-(data_index[0]<<4)],
                            data_in[20-(data_index[0]<<4)],
                            data_in[19-(data_index[0]<<4)], 
                            data_in[18-(data_index[0]<<4)], 
                            data_in[17-(data_index[0]<<4)], 
                            data_in[16-(data_index[0]<<4)]
                            };
                        crc_in <= {
                            data_in[23-(data_index[0]<<4)], 
                            data_in[22-(data_index[0]<<4)], 
                            data_in[21-(data_index[0]<<4)], 
                            data_in[20-(data_index[0]<<4)],
                            data_in[19-(data_index[0]<<4)], 
                            data_in[18-(data_index[0]<<4)], 
                            data_in[17-(data_index[0]<<4)], 
                            data_in[16-(data_index[0]<<4)],

                            data_in[31-(data_index[0]<<4)], 
                            data_in[30-(data_index[0]<<4)], 
                            data_in[29-(data_index[0]<<4)], 
                            data_in[28-(data_index[0]<<4)],
                            data_in[27-(data_index[0]<<4)], 
                            data_in[26-(data_index[0]<<4)], 
                            data_in[25-(data_index[0]<<4)], 
                            data_in[24-(data_index[0]<<4)]
                            };
                        rd <= (data_index[0] == 1'b0/*not 3 - read delay !!!*/ && transf_cnt <= data_cycles-1);
                      end
                      else begin
                        d1d2_reg <= {2{last_din}};
                        last_din <= {
                            data_in[31-(data_index[1:0]<<3)], 
                            data_in[30-(data_index[1:0]<<3)], 
                            data_in[29-(data_index[1:0]<<3)], 
                            data_in[28-(data_index[1:0]<<3)],
                            data_in[27-(data_index[1:0]<<3)], 
                            data_in[26-(data_index[1:0]<<3)], 
                            data_in[25-(data_index[1:0]<<3)], 
                            data_in[24-(data_index[1:0]<<3)]
                            };
                        crc_in <= {
                            data_in[31-(data_index[1:0]<<3)], 
                            data_in[30-(data_index[1:0]<<3)], 
                            data_in[29-(data_index[1:0]<<3)], 
                            data_in[28-(data_index[1:0]<<3)],
                            data_in[27-(data_index[1:0]<<3)], 
                            data_in[26-(data_index[1:0]<<3)], 
                            data_in[25-(data_index[1:0]<<3)], 
                            data_in[24-(data_index[1:0]<<3)]
                            };
                        rd <= (data_index[1:0] == 2'h2/*not 3 - read delay !!!*/ && transf_cnt <= data_cycles-1);
//                            rd <= 1;
                      end
                    end
                    else if (bus_4bit_reg) begin
                        last_din <= {4'hF,
                            data_in[31-(data_index[2:0]<<2)], 
                            data_in[30-(data_index[2:0]<<2)], 
                            data_in[29-(data_index[2:0]<<2)], 
                            data_in[28-(data_index[2:0]<<2)]  
                            };
                        crc_in <= {4'hF,
                            data_in[31-(data_index[2:0]<<2)], 
                            data_in[30-(data_index[2:0]<<2)], 
                            data_in[29-(data_index[2:0]<<2)], 
                            data_in[28-(data_index[2:0]<<2)]
                            };
                        if (data_index[2:0] == 3'h6/*not 7 - read delay !!!*/ && transf_cnt <= data_cycles-1)
                            rd <= 1;
                    end
                    else begin
                        last_din <= {7'h7F, data_in[31-data_index]};
                        crc_in <= {7'h7F, data_in[31-data_index]};
                        if (data_index == 29/*not 31 - read delay !!!*/)
                            rd <= 1;
                    end
                    if (transf_cnt == data_cycles)
                        crc_en<=0;
                end
                else if (transf_cnt <= data_cycles +16) begin
                    crc_c <= crc_c - 1;
                    if (bus_8bit_reg)
                      if(DDR50)begin
                        d1d2_reg <= {
                          crc_out[15][crc_c],
                          crc_out[14][crc_c],
                          crc_out[13][crc_c],
                          crc_out[12][crc_c],
                          crc_out[11][crc_c],
                          crc_out[10][crc_c],
                          crc_out[9][crc_c],
                          crc_out[8][crc_c],
                          crc_out[7][crc_c],
                          crc_out[6][crc_c],
                          crc_out[5][crc_c],
                          crc_out[4][crc_c],
                          crc_out[3][crc_c],
                          crc_out[2][crc_c],
                          crc_out[1][crc_c],
                          crc_out[0][crc_c]
                          };
                      end
                      else begin
                        d1d2_reg <= {2{
                          crc_out[7][crc_c],
                          crc_out[6][crc_c],
                          crc_out[5][crc_c],
                          crc_out[4][crc_c],
                          crc_out[3][crc_c],
                          crc_out[2][crc_c],
                          crc_out[1][crc_c],
                          crc_out[0][crc_c]
                          }};
                      end
                    else if (bus_4bit_reg)
                        d1d2_reg <= {2{4'hF,
                          crc_out[3][crc_c],
                          crc_out[2][crc_c],
                          crc_out[1][crc_c],
                          crc_out[0][crc_c]
                          }};
                    else
                        d1d2_reg <= {2{7'h7F, crc_out[0][crc_c]}};
                end
                else if (transf_cnt == data_cycles+17) begin
//                    DAT_oe_o <= 0;
                    d1d2_reg <= 16'hFFFF;
                end
                else if (transf_cnt >= data_cycles+18) begin
                    DAT_oe_o <= 1;
                end
            end
            WRITE_CRC: begin
                DAT_oe_o <= 1;
                if (crc_status < 4)
                    crc_s[crc_status] <= DAT_dat_reg[0];
                crc_status <= crc_status + 4'h1;
                busy_int <= 1;
            end
            WRITE_BUSY: begin
                if (crc_s == 4'b1010)
                    crc_ok <= 1;
                else
                    crc_ok <= 0;
                busy_int <= !DAT_dat_reg[0];
                next_block <= ((blkcnt_reg - `BLKCNT_W'h1) != 0);
                if (next_state != WRITE_BUSY) begin
                    blkcnt_reg <= blkcnt_reg - `BLKCNT_W'h1;
                    crc_rst <= 1;
                    crc_c <= 15;
                    crc_status <= 0;
                end
                transf_cnt <= 0;
            end
            READ_WAIT: begin
                DAT_oe_o <= 1;
                crc_rst <= 0;
                crc_en <= 1;
                crc_in <= 0;
                crc_c <= 15;
                next_block <= 0;
                transf_cnt <= 0;
                data_index <= 0;
            end
            READ_DAT: begin
                if (transf_cnt < data_cycles) begin
                    if (bus_8bit_reg) begin
                      if (DDR50) begin
                        we <= (data_index[0] == 1'b1 || (transf_cnt == data_cycles-1 && !blkcnt_reg));
                        data_out[31-(data_index[0] << 4)] <= DAT_dat_reg[7];
                        data_out[30-(data_index[0] << 4)] <= DAT_dat_reg[6];
                        data_out[29-(data_index[0] << 4)] <= DAT_dat_reg[5];
                        data_out[28-(data_index[0] << 4)] <= DAT_dat_reg[4];
                        data_out[27-(data_index[0] << 4)] <= DAT_dat_reg[3];
                        data_out[26-(data_index[0] << 4)] <= DAT_dat_reg[2];
                        data_out[25-(data_index[0] << 4)] <= DAT_dat_reg[1];
                        data_out[24-(data_index[0] << 4)] <= DAT_dat_reg[0];

                        data_out[23-(data_index[0] << 4)] <= DAT_dat_regn[7];
                        data_out[22-(data_index[0] << 4)] <= DAT_dat_regn[6];
                        data_out[21-(data_index[0] << 4)] <= DAT_dat_regn[5];
                        data_out[20-(data_index[0] << 4)] <= DAT_dat_regn[4];
                        data_out[19-(data_index[0] << 4)] <= DAT_dat_regn[3];
                        data_out[18-(data_index[0] << 4)] <= DAT_dat_regn[2];
                        data_out[17-(data_index[0] << 4)] <= DAT_dat_regn[1];
                        data_out[16-(data_index[0] << 4)] <= DAT_dat_regn[0];
                      end
                      else begin
                        we <= (data_index[1:0] == 3 || (transf_cnt == data_cycles-1  && !blkcnt_reg));
                        data_out[31-(data_index[1:0]<<3)] <= DAT_dat_reg[7];
                        data_out[30-(data_index[1:0]<<3)] <= DAT_dat_reg[6];
                        data_out[29-(data_index[1:0]<<3)] <= DAT_dat_reg[5];
                        data_out[28-(data_index[1:0]<<3)] <= DAT_dat_reg[4];
                        data_out[27-(data_index[1:0]<<3)] <= DAT_dat_reg[3];
                        data_out[26-(data_index[1:0]<<3)] <= DAT_dat_reg[2];
                        data_out[25-(data_index[1:0]<<3)] <= DAT_dat_reg[1];
                        data_out[24-(data_index[1:0]<<3)] <= DAT_dat_reg[0];
                      end
                    end
                    else if (bus_4bit_reg) begin
                        we <= (data_index[2:0] == 7 || (transf_cnt == data_cycles-1  && !blkcnt_reg));
                        data_out[31-(data_index[2:0]<<2)] <= DAT_dat_reg[3];
                        data_out[30-(data_index[2:0]<<2)] <= DAT_dat_reg[2];
                        data_out[29-(data_index[2:0]<<2)] <= DAT_dat_reg[1];
                        data_out[28-(data_index[2:0]<<2)] <= DAT_dat_reg[0];
                    end
                    else begin
                        we <= (data_index == 31 || (transf_cnt == data_cycles-1  && !blkcnt_reg));
                        data_out[31-data_index] <= DAT_dat_reg[0];
                    end
                    data_index <= data_index + 5'h1;
                    if (DDR50)
                      crc_in <= {DAT_dat_regn,DAT_dat_reg};
                    else
                      crc_in <= DAT_dat_reg;
                    crc_ok <= 1;
                    transf_cnt <= transf_cnt + 16'h1;
                end
                else if (transf_cnt <= data_cycles + 16) begin
                    transf_cnt <= transf_cnt + 16'h1;
                    crc_en <= 0;
                    last_din <= DAT_dat_reg;
                    if (DDR50)
                      last_dinDDR <= DAT_dat_regn;
                    we<=0;
                    if (transf_cnt > data_cycles) begin
                        crc_c <= crc_c - 5'h1;
                        if  (crc_out[0][crc_c] != last_din[0])
                            crc_ok <= 0;
                        if  (crc_out[1][crc_c] != last_din[1] && (bus_4bit_reg || bus_8bit_reg))
                            crc_ok<=0;
                        if  (crc_out[2][crc_c] != last_din[2] && (bus_4bit_reg || bus_8bit_reg))
                            crc_ok <= 0;
                        if  (crc_out[3][crc_c] != last_din[3] && (bus_4bit_reg || bus_8bit_reg))
                            crc_ok <= 0;
                        if  (crc_out[4][crc_c] != last_din[4] && bus_8bit_reg)
                            crc_ok <= 0;
                        if  (crc_out[5][crc_c] != last_din[5] && bus_8bit_reg)
                            crc_ok <= 0;
                        if  (crc_out[6][crc_c] != last_din[6] && bus_8bit_reg)
                            crc_ok <= 0;
                        if  (crc_out[7][crc_c] != last_din[7] && bus_8bit_reg)
                            crc_ok <= 0;
                        if  (crc_out[8][crc_c] != last_dinDDR[0] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if  (crc_out[9][crc_c] != last_dinDDR[1] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if  (crc_out[10][crc_c] != last_dinDDR[2] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if  (crc_out[11][crc_c] != last_dinDDR[3] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if  (crc_out[12][crc_c] != last_dinDDR[4] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if  (crc_out[13][crc_c] != last_dinDDR[5] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if  (crc_out[14][crc_c] != last_dinDDR[6] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if  (crc_out[15][crc_c] != last_dinDDR[7] && bus_8bit_reg && DDR50)
                            crc_ok <= 0;
                        if (crc_c == 0) begin
                            next_block <= ((blkcnt_reg - `BLKCNT_W'h1) != 0);
                            blkcnt_reg <= blkcnt_reg - `BLKCNT_W'h1;
                            crc_rst <= 1;
                            last_dinDDR <= 0;
                        end
                    end
                end
            end
        endcase
    end
end

endmodule





