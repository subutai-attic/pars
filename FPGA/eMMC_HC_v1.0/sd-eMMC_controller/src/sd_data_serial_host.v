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
`include "sd_defines.h"

module sd_data_serial_host(
           (* mark_debug = "true" *) input sd_clk,
           input rst,
           //Tx Fifo
           input [31:0] data_in,
           output wire rd_out,
           //Rx Fifo
           output wire [31:0] data_out_o,
           output wire we_out,
           //tristate data
           output wire DAT_oe_out,
           output wire [7:0] DAT_dat_out,
           input [7:0] DAT_dat_i,
           //Controll signals
           input [`BLKSIZE_W-1:0] blksize,
           input bus_4bit,
           input bus_8bit,
           input ddr50_en,
           input [`BLKCNT_W-1:0] blkcnt,
           input [1:0] start,
           input [1:0] byte_alignment,
           output sd_data_busy,
           output busy,
           output wire crc_ok_out,
           output read_trans_active,
           output write_trans_active,
//           output next_block,
           input start_write,
           output wire write_next_block
       );
       

(* mark_debug = "true" *) reg [7:0] DAT_dat_reg;
reg DAT_oe_o;
reg [7:0] DAT_dat_o;
reg [`BLKSIZE_W-1+3:0] data_cycles;
reg bus_4bit_reg;
reg bus_8bit_reg;
//CRC16
reg [7:0] crc_in;
reg crc_en;
reg crc_rst;
wire [15:0] crc_out [7:0];
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
reg [1:0] byte_alignment_reg;
reg [`BLKSIZE_W-1:0] blksize_reg;
reg next_block;
wire start_bit;
reg [4:0] crc_c;
reg crc_ok;
reg [7:0] last_din;
reg [3:0] crc_s ;
reg [4:0] data_index;
reg [31:0] data_out;
reg rd;
reg we;

//sd data input pad register
always @(posedge sd_clk)
    DAT_dat_reg <= DAT_dat_i;

genvar i;
generate
    for(i=0; i<8; i=i+1) begin: CRC_16_gen
        sd_crc_16 CRC_16_i (crc_in[i],crc_en, sd_clk, crc_rst, crc_out[i]);
    end
endgenerate

assign busy = (state != IDLE);
assign start_bit = !DAT_dat_reg[0];
assign sd_data_busy = !DAT_dat_reg[0];
assign read_trans_active = ((state == READ_DAT) || (state == READ_WAIT));
assign write_trans_active = ((state == WRITE_DAT) || (state == WRITE_BUSY) || (state == WRITE_CRC) || (state == WRITE_WAIT));
assign write_next_block = ((state == WRITE_WAIT) && DAT_dat_reg[0] && next_block);

assign ddr_DAT_dat_o = (ddr50_en_reg) ? ddr_DAT_dat_op : DAT_dat_o;
assign DAT_oe_out    = (ddr50_en_reg) ? ddr_DAT_oe_o : DAT_oe_o;
assign we_out        = (ddr50_en_reg) ? ddr_we : we;
assign rd_out        = (ddr50_en_reg) ? ddr_rd : rd;
assign data_out_o [31:0] = {data_out[7:0], data_out[15:8], data_out[23:16], data_out[31:24]}; 


always @(state or start or start_bit or  transf_cnt or data_cycles or crc_status or crc_ok or busy_int or next_block)
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
            if (transf_cnt >= data_cycles+21 && start_bit)
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
            if (transf_cnt == data_cycles+17 && next_block && crc_ok)
                next_state <= READ_WAIT;
            else if (transf_cnt == data_cycles+17)
                next_state <= IDLE;
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
        crc_c <= 15;
        rd <= 0;
        last_din <= 0;
        crc_c <= 0;
        crc_in <= 0;
        DAT_dat_o <= 0;
        crc_status <= 0;
        crc_s <= 0;
        we <= 0;
        data_out <= 0;
        crc_ok <= 0;
        busy_int <= 0;
        data_index <= 0;
        next_block <= 0;
        blkcnt_reg <= 0;
        byte_alignment_reg <= 0;
        data_cycles <= 0;
        bus_4bit_reg <= 0;
        bus_8bit_reg <= 0;
    end
    else begin
        state <= next_state;
        case(state)
            IDLE: begin
                DAT_oe_o <= 1;
                DAT_dat_o <= 8'b11111111;
                crc_en <= 0;
                crc_rst <= 1;
                transf_cnt <= 0;
                crc_c <= 16;
                crc_status <= 0;
                crc_s <= 0;
                we <= 0;
                rd <= 0;
                data_index <= 0;
                next_block <= 0;
                blkcnt_reg <= blkcnt;
                byte_alignment_reg <= byte_alignment;
                blksize_reg <= blksize;
//                data_cycles <= (bus_4bit ? (blksize << 1)/* + `BLKSIZE_W'd2 */: (blksize << 3))/*+ `BLKSIZE_W'd8)*/;
                data_cycles <= (bus_8bit ? blksize : (bus_4bit ? (blksize << 1) : (blksize << 3)));
                bus_4bit_reg <= bus_4bit;
                bus_8bit_reg <= bus_8bit;
            end
            WRITE_WAIT: begin
                data_index <= 0;
                next_block <= 0;
            end
            WRITE_DAT: begin
                crc_ok <= 0;
                transf_cnt <= transf_cnt + 16'h1;
                rd <= 0;
                //special case
                if (transf_cnt == 0 && byte_alignment_reg == 2'b11 && bus_4bit_reg) begin
                    rd <= 1;
                end
                else if (transf_cnt == 1) begin
                    crc_rst <= 0;
                    crc_en <= 1;
                    if (bus_8bit_reg) begin
                        last_din <= {
                            data_in[31-(byte_alignment_reg << 3)], 
                            data_in[30-(byte_alignment_reg << 3)], 
                            data_in[29-(byte_alignment_reg << 3)], 
                            data_in[28-(byte_alignment_reg << 3)],
                            data_in[27-(byte_alignment_reg << 3)], 
                            data_in[26-(byte_alignment_reg << 3)], 
                            data_in[25-(byte_alignment_reg << 3)], 
                            data_in[24-(byte_alignment_reg << 3)]
                            };
                        crc_in <= {
                            data_in[31-(byte_alignment_reg << 3)], 
                            data_in[30-(byte_alignment_reg << 3)], 
                            data_in[29-(byte_alignment_reg << 3)], 
                            data_in[28-(byte_alignment_reg << 3)],
                            data_in[27-(byte_alignment_reg << 3)], 
                            data_in[26-(byte_alignment_reg << 3)], 
                            data_in[25-(byte_alignment_reg << 3)], 
                            data_in[24-(byte_alignment_reg << 3)]
                            };
                    end                    
                    else if (bus_4bit_reg) begin
                        last_din <= {4'hF,
                            data_in[31-(byte_alignment_reg << 3)], 
                            data_in[30-(byte_alignment_reg << 3)], 
                            data_in[29-(byte_alignment_reg << 3)], 
                            data_in[28-(byte_alignment_reg << 3)]
                            };
                        crc_in <= {4'hF,
                            data_in[31-(byte_alignment_reg << 3)], 
                            data_in[30-(byte_alignment_reg << 3)], 
                            data_in[29-(byte_alignment_reg << 3)], 
                            data_in[28-(byte_alignment_reg << 3)]
                            };
                    end
                    else begin
                        last_din <= {7'h7F, data_in[31-(byte_alignment_reg << 3)]};
                        crc_in <= {7'h7F, data_in[31-(byte_alignment_reg << 3)]};
                    end
                    DAT_oe_o <= 0;
//                    DAT_dat_o <= bus_4bit_reg ? 4'h0 : 4'he;
                    DAT_dat_o <= bus_8bit_reg ? 8'h0 :(bus_4bit_reg ? 8'hF0 : 8'hFE);
                    data_index <= bus_8bit_reg ? {2'b0, byte_alignment_reg, 1'b1} :(bus_4bit_reg ? {2'b00, byte_alignment_reg, 1'b1} : {byte_alignment_reg, 3'b001});
                end
                else if ((transf_cnt >= 2) && (transf_cnt <= data_cycles+1)) begin
                    DAT_oe_o<= 0;
                    if (bus_8bit_reg) begin
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
                        if (data_index[1:0] == 2'h2/*not 3 - read delay !!!*/ && transf_cnt <= data_cycles-1) begin
                            rd <= 1;
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
                        if (data_index[2:0] == 3'h6/*not 7 - read delay !!!*/ && transf_cnt <= data_cycles-1) begin
                            rd <= 1;
                        end
                    end
                    else begin
                        last_din <= {7'h7F, data_in[31-data_index]};
                        crc_in <= {7'h7F, data_in[31-data_index]};
                        if (data_index == 30/*not 31 - read delay !!!*/) begin
                            rd <= 1;
                        end
                    end
                    data_index <= data_index + 5'h1;
                    DAT_dat_o <= last_din;
                    if (transf_cnt == data_cycles+1)
                        crc_en<=0;
                end
                else if (transf_cnt > data_cycles+1 & crc_c!=0) begin
                    crc_en <= 0;
                    crc_c <= crc_c - 5'h1;
                    DAT_oe_o <= 0;
                    DAT_dat_o[0] <= crc_out[0][crc_c-1];
                    if (bus_8bit_reg)
                        DAT_dat_o[7:1] <= {crc_out[7][crc_c-1], crc_out[6][crc_c-1], crc_out[5][crc_c-1], crc_out[4][crc_c-1], crc_out[3][crc_c-1], crc_out[2][crc_c-1], crc_out[1][crc_c-1]};                   
                    else if (bus_4bit_reg)
                        DAT_dat_o[7:1] <= {4'hF,crc_out[3][crc_c-1], crc_out[2][crc_c-1], crc_out[1][crc_c-1]};
                    else
                        DAT_dat_o[7:1] <= {7'h7F};
                end
                else if (transf_cnt == data_cycles+18) begin
                    DAT_oe_o <= 0;
                    DAT_dat_o <= 8'hFF;
                end
                else if (transf_cnt >= data_cycles+19) begin
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
                    byte_alignment_reg <=  0;//byte_alignment_reg + blksize_reg[1:0] + 2'b1;
                    crc_rst <= 1;
                    crc_c <= 16;
                    crc_status <= 0;
                end
                transf_cnt <= 0;
            end
            READ_WAIT: begin
                DAT_oe_o <= 1;
                crc_rst <= 0;
                crc_en <= 1;
                crc_in <= 0;
                crc_c <= 15;// end
                next_block <= 0;
                transf_cnt <= 0;
                data_index <= 0;//bus_4bit_reg ? (byte_alignment_reg << 1) : (byte_alignment_reg << 3);
            end
            READ_DAT: begin
                if (transf_cnt < data_cycles) begin
                    if (bus_8bit_reg) begin
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
                    crc_in <= DAT_dat_reg;
                    crc_ok <= 1;
                    transf_cnt <= transf_cnt + 16'h1;
                end
                else if (transf_cnt <= data_cycles+16) begin
                    transf_cnt <= transf_cnt + 16'h1;
                    crc_en <= 0;
                    last_din <= DAT_dat_reg;
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
                        if (crc_c == 0) begin
                            next_block <= ((blkcnt_reg - `BLKCNT_W'h1) != 0);
                            blkcnt_reg <= blkcnt_reg - `BLKCNT_W'h1;
                            byte_alignment_reg <= 0;//byte_alignment_reg + blksize_reg[1:0] + 2'b1;
                            crc_rst <= 1;
                        end
                    end
                end
            end
        endcase
    end
end

reg [`BLKSIZE_W-1+3:0] ddr_data_cycles;
reg ddr_bus_4bit_reg;
reg ddr_bus_8bit_reg;
//CRC16
reg [7:0] ddr_crc_in;
reg ddr_crc_en;
reg ddr_crc_rst;
wire [15:0] ddr_crc_out [7:0];
reg [`BLKSIZE_W-1+4:0] ddr_transf_cnt;
parameter DDR_SIZE = 6;
reg [DDR_SIZE-1:0] ddr_state;
reg [DDR_SIZE-1:0] ddr_next_state;
parameter DDR_IDLE       = 6'b000001;
parameter DDR_WRITE_DAT  = 6'b000010;
parameter DDR_WRITE_WAIT  = 6'b000011;
parameter DDR_WRITE_CRC  = 6'b000100;
parameter DDR_WRITE_BUSY = 6'b001000;
parameter DDR_READ_WAIT  = 6'b010000;
parameter DDR_READ_DAT   = 6'b100000;
reg [3:0] ddr_crc_status;
reg ddr_busy_int;
reg [`BLKCNT_W-1:0] ddr_blkcnt_reg;
reg [1:0] ddr_byte_alignment_reg;
reg [`BLKSIZE_W-1:0] ddr_blksize_reg;
reg ddr_next_block;
reg [4:0] ddr_crc_c;
reg ddr_crc_ok;
reg [7:0] ddr_last_din;
reg [7:0] ddr_last_din_n;
reg [3:0] ddr_crc_s ;
reg [4:0] ddr_data_index;
reg [31:0] ddr_data_out;
reg ddr_rd;
reg ddr_we;
wire [7:0] ddr_DAT_dat_o;
reg [7:0] ddr_DAT_dat_op;
reg [7:0] ddr_DAT_dat_on;
reg ddr_DAT_oe_o;
reg ddr50_en_reg;



always @(ddr_state or start or start_bit or  ddr_transf_cnt or ddr_data_cycles or ddr_crc_status or ddr_crc_ok or ddr_busy_int or ddr_next_block)
begin: FSM_DDR
    case(ddr_state)
        DDR_IDLE: begin
            if (start == 2'b01)
                ddr_next_state <= DDR_WRITE_WAIT;
            else if  (start == 2'b10)
                ddr_next_state <= DDR_READ_WAIT;
            else
                ddr_next_state <= DDR_IDLE;
        end
        DDR_WRITE_WAIT: begin
            if (start_write && DAT_dat_reg[0])
                ddr_next_state <= DDR_WRITE_DAT;
            else
                ddr_next_state <= DDR_WRITE_WAIT;
        end
        DDR_WRITE_DAT: begin
            if (ddr_transf_cnt >= ddr_data_cycles+21 && start_bit)
                ddr_next_state <= DDR_WRITE_CRC;
            else
                ddr_next_state <= DDR_WRITE_DAT;
        end
        DDR_WRITE_CRC: begin
            if (ddr_crc_status == 3)
                ddr_next_state <= DDR_WRITE_BUSY;
            else
                ddr_next_state <= DDR_WRITE_CRC;
        end
        DDR_WRITE_BUSY: begin
            if (!ddr_busy_int && ddr_next_block && ddr_crc_ok)
                ddr_next_state <= DDR_WRITE_WAIT;
            else if (!ddr_busy_int)
                ddr_next_state <= DDR_IDLE;
            else
                ddr_next_state <= DDR_WRITE_BUSY;
        end
        DDR_READ_WAIT: begin
            if (start_bit)
                ddr_next_state <= DDR_READ_DAT;
            else
                ddr_next_state <= DDR_READ_WAIT;
        end
        DDR_READ_DAT: begin
            if (ddr_transf_cnt == ddr_data_cycles+17 && ddr_next_block && ddr_crc_ok)
                ddr_next_state <= DDR_READ_WAIT;
            else if (ddr_transf_cnt == ddr_data_cycles+17)
                ddr_next_state <= DDR_IDLE;
            else
                ddr_next_state <= DDR_READ_DAT;
        end
        default: ddr_next_state <= DDR_IDLE;
    endcase
    //abort
    if (start == 2'b11)
        ddr_next_state <= DDR_IDLE;
end

always @(posedge sd_clk or posedge rst)
begin: FSM_DDR_P
    if (rst) begin
        ddr_state <= DDR_IDLE;
        ddr_DAT_oe_o <= 1;
        ddr_crc_en <= 0;
        ddr_crc_rst <= 1;
        ddr_transf_cnt <= 0;
        ddr_crc_c <= 15;
        ddr_rd <= 0;
        ddr_last_din <= 0;
        ddr_crc_c <= 0;
        ddr_crc_in <= 0;
        ddr_DAT_dat_op <= 0;
        ddr_crc_status <= 0;
        ddr_crc_s <= 0;
        ddr_we <= 0;
        ddr_data_out <= 0;
        ddr_crc_ok <= 0;
        ddr_busy_int <= 0;
        ddr_data_index <= 0;
        ddr_next_block <= 0;
        ddr_blkcnt_reg <= 0;
        ddr_byte_alignment_reg <= 0;
        ddr_data_cycles <= 0;
        ddr_bus_4bit_reg <= 0;
        ddr_bus_8bit_reg <= 0;
        ddr50_en_reg <= 0;
    end
    else begin
        ddr_state <= ddr_next_state;
        case(ddr_state)
            DDR_IDLE: begin
                ddr_DAT_oe_o <= 1;
                ddr_DAT_dat_op <= 8'b11111111;
                ddr_crc_en <= 0;
                ddr_crc_rst <= 1;
                ddr_transf_cnt <= 0;
                ddr_crc_c <= 16;
                ddr_crc_status <= 0;
                ddr_crc_s <= 0;
                ddr_we <= 0;
                ddr_rd <= 0;
                ddr_data_index <= 0;
                ddr_next_block <= 0;
                ddr_blkcnt_reg <= blkcnt;
                ddr_byte_alignment_reg <= byte_alignment;
                ddr_blksize_reg <= blksize;
                ddr_data_cycles <= (bus_8bit ? blksize : (bus_4bit ? (blksize << 1) : (blksize << 3)));
                ddr_bus_4bit_reg <= bus_4bit;
                ddr_bus_8bit_reg <= bus_8bit;
                ddr50_en_reg <= ddr50_en;
            end
            DDR_WRITE_WAIT: begin
                ddr_data_index <= 0;
                ddr_next_block <= 0;
            end
            DDR_WRITE_DAT: begin
                ddr_crc_ok <= 0;
                ddr_transf_cnt <= transf_cnt + 16'h1;
                ddr_rd <= 0;
                //special case
                if (ddr_transf_cnt == 0 && ddr_byte_alignment_reg == 2'b11 && ddr_bus_4bit_reg) begin
                    ddr_rd <= 1;
                end
                else if (ddr_transf_cnt == 1) begin
                    ddr_crc_rst <= 0;
                    ddr_crc_en <= 1;
                    if (ddr_bus_8bit_reg) begin
                        ddr_last_din <= {
                            data_in[31-(ddr_byte_alignment_reg << 4)], 
                            data_in[30-(ddr_byte_alignment_reg << 4)], 
                            data_in[29-(ddr_byte_alignment_reg << 4)], 
                            data_in[28-(ddr_byte_alignment_reg << 4)],
                            data_in[27-(ddr_byte_alignment_reg << 4)], 
                            data_in[26-(ddr_byte_alignment_reg << 4)], 
                            data_in[25-(ddr_byte_alignment_reg << 4)], 
                            data_in[24-(ddr_byte_alignment_reg << 4)]
                            };
                        ddr_crc_in <= {
                            data_in[31-(ddr_byte_alignment_reg << 4)], 
                            data_in[30-(ddr_byte_alignment_reg << 4)], 
                            data_in[29-(ddr_byte_alignment_reg << 4)], 
                            data_in[28-(ddr_byte_alignment_reg << 4)],
                            data_in[27-(ddr_byte_alignment_reg << 4)], 
                            data_in[26-(ddr_byte_alignment_reg << 4)], 
                            data_in[25-(ddr_byte_alignment_reg << 4)], 
                            data_in[24-(ddr_byte_alignment_reg << 4)]
                            };
                    end                    
                    ddr_DAT_oe_o <= 0;
                    ddr_DAT_dat_op <= ddr_bus_8bit_reg ? 8'h0 :(ddr_bus_4bit_reg ? 8'hF0 : 8'hFE);
                    ddr_data_index <= ddr_bus_8bit_reg ? {2'b0, ddr_byte_alignment_reg, 1'b1} :(ddr_bus_4bit_reg ? {2'b00, ddr_byte_alignment_reg, 1'b1} : {ddr_byte_alignment_reg, 3'b001});
                end
                else if ((ddr_transf_cnt >= 2) && (ddr_transf_cnt <= ddr_data_cycles+1)) begin
                    ddr_DAT_oe_o<= 0;
                    if (ddr_bus_8bit_reg) begin
                        ddr_last_din <= {
                            data_in[31-(ddr_data_index[0]<<4)], 
                            data_in[30-(ddr_data_index[0]<<4)], 
                            data_in[29-(ddr_data_index[0]<<4)], 
                            data_in[28-(ddr_data_index[0]<<4)],
                            data_in[27-(ddr_data_index[0]<<4)], 
                            data_in[26-(ddr_data_index[0]<<4)], 
                            data_in[25-(ddr_data_index[0]<<4)], 
                            data_in[24-(ddr_data_index[0]<<4)]
                            };
                        ddr_crc_in <= {
                            data_in[31-(ddr_data_index[0]<<4)], 
                            data_in[30-(ddr_data_index[0]<<4)], 
                            data_in[29-(ddr_data_index[0]<<4)], 
                            data_in[28-(ddr_data_index[0]<<4)],
                            data_in[27-(ddr_data_index[0]<<4)], 
                            data_in[26-(ddr_data_index[0]<<4)], 
                            data_in[25-(ddr_data_index[0]<<4)], 
                            data_in[24-(ddr_data_index[0]<<4)]
                            };
                            // 31 -> 15 -> 31
                        if (ddr_data_index[0] == 2'h1/*not 3 - read delay !!!*/ && ddr_transf_cnt <= ddr_data_cycles-1) begin
                            ddr_rd <= 1;
                        end
                    end
                    ddr_data_index <= ddr_data_index + 5'h1;
                    ddr_DAT_dat_op <= ddr_last_din;
                    if (ddr_transf_cnt == ddr_data_cycles+1)
                        ddr_crc_en<=0;
                end
                else if (ddr_transf_cnt > ddr_data_cycles+1 & ddr_crc_c!=0) begin
                    ddr_crc_en <= 0;
                    ddr_crc_c <= ddr_crc_c - 5'h1;
                    ddr_DAT_oe_o <= 0;
                    ddr_DAT_dat_op[0] <= ddr_crc_out[0][ddr_crc_c-1];
                    if (bus_8bit_reg)
                        ddr_DAT_dat_op[7:1] <= {ddr_crc_out[7][ddr_crc_c-1], ddr_crc_out[6][ddr_crc_c-1], ddr_crc_out[5][ddr_crc_c-1], ddr_crc_out[4][ddr_crc_c-1], ddr_crc_out[3][ddr_crc_c-1], ddr_crc_out[2][ddr_crc_c-1], ddr_crc_out[1][ddr_crc_c-1]};                   
                end
                else if (ddr_transf_cnt == ddr_data_cycles+18) begin
                    ddr_DAT_oe_o <= 0;
                    ddr_DAT_dat_op <= 8'hFF;
                end
                else if (ddr_transf_cnt >= ddr_data_cycles+19) begin
                    ddr_DAT_oe_o <= 1;
                end
            end
            DDR_WRITE_CRC: begin
                ddr_DAT_oe_o <= 1;
                if (ddr_crc_status < 4)
                    ddr_crc_s[ddr_crc_status] <= DAT_dat_reg[0];
                ddr_crc_status <= ddr_crc_status + 4'h1;
                ddr_busy_int <= 1;
            end
            DDR_WRITE_BUSY: begin
                if (ddr_crc_s == 4'b1010)
                    ddr_crc_ok <= 1;
                else
                    ddr_crc_ok <= 0;
                ddr_busy_int <= !DAT_dat_reg[0];
                ddr_next_block <= ((ddr_blkcnt_reg - `BLKCNT_W'h1) != 0);
                if (ddr_next_state != DDR_WRITE_BUSY) begin
                    ddr_blkcnt_reg <= ddr_blkcnt_reg - `BLKCNT_W'h1;
                    ddr_byte_alignment_reg <=  0;//byte_alignment_reg + blksize_reg[1:0] + 2'b1;
                    ddr_crc_rst <= 1;
                    ddr_crc_c <= 16;
                    ddr_crc_status <= 0;
                end
                ddr_transf_cnt <= 0;
            end
            DDR_READ_WAIT: begin
                ddr_DAT_oe_o <= 1;
                ddr_crc_rst <= 0;
                ddr_crc_en <= 1;
                ddr_crc_in <= 0;
                ddr_crc_c <= 15;// end
                ddr_next_block <= 0;
                ddr_transf_cnt <= 0;
                ddr_data_index <= 0;//bus_4bit_reg ? (byte_alignment_reg << 1) : (byte_alignment_reg << 3);
            end
            DDR_READ_DAT: begin
                if (ddr_transf_cnt < ddr_data_cycles) begin
                    if (bus_8bit_reg) begin
                        ddr_we <= (ddr_data_index[0] == 1 || (ddr_transf_cnt == ddr_data_cycles-1  && !ddr_blkcnt_reg));
                        ddr_data_out[15-(ddr_data_index[0]<<3)] <= DAT_dat_reg[7];
                        ddr_data_out[14-(ddr_data_index[0]<<3)] <= DAT_dat_reg[6];
                        ddr_data_out[13-(ddr_data_index[0]<<3)] <= DAT_dat_reg[5];
                        ddr_data_out[12-(ddr_data_index[0]<<3)] <= DAT_dat_reg[4];
                        ddr_data_out[11-(ddr_data_index[0]<<3)] <= DAT_dat_reg[3];
                        ddr_data_out[10-(ddr_data_index[0]<<3)] <= DAT_dat_reg[2];
                        ddr_data_out[9 -(ddr_data_index[0]<<3)] <= DAT_dat_reg[1];
                        ddr_data_out[8 -(ddr_data_index[0]<<3)] <= DAT_dat_reg[0];
                        
                        // 15 -> 7 -> 15
                    end
                    ddr_data_index <= ddr_data_index + 5'h1;
                    ddr_crc_in <= DAT_dat_reg;
                    ddr_crc_ok <= 1;
                    ddr_transf_cnt <= ddr_transf_cnt + 16'h1;
                end
                else if (ddr_transf_cnt <= ddr_data_cycles+16) begin
                    ddr_transf_cnt <= ddr_transf_cnt + 16'h1;
                    ddr_crc_en <= 0;
                    ddr_last_din <= DAT_dat_reg;
                    ddr_we<=0;
                    if (ddr_transf_cnt > ddr_data_cycles) begin
                        ddr_crc_c <= ddr_crc_c - 5'h1;
                        if  (ddr_crc_out[0][ddr_crc_c] != ddr_last_din[0])
                            ddr_crc_ok <= 0;
                        if  (ddr_crc_out[1][ddr_crc_c] != ddr_last_din[1] && bus_8bit_reg)
                            ddr_crc_ok<=0;
                        if  (ddr_crc_out[2][ddr_crc_c] != ddr_last_din[2] && bus_8bit_reg)
                            ddr_crc_ok <= 0;
                        if  (ddr_crc_out[3][ddr_crc_c] != ddr_last_din[3] && bus_8bit_reg)
                            ddr_crc_ok <= 0;
                        if  (ddr_crc_out[4][ddr_crc_c] != ddr_last_din[4] && bus_8bit_reg)
                            ddr_crc_ok <= 0;
                        if  (ddr_crc_out[5][ddr_crc_c] != ddr_last_din[5] && bus_8bit_reg)
                            ddr_crc_ok <= 0;
                        if  (ddr_crc_out[6][ddr_crc_c] != ddr_last_din[6] && bus_8bit_reg)
                            ddr_crc_ok <= 0;
                        if  (ddr_crc_out[7][ddr_crc_c] != ddr_last_din[7] && bus_8bit_reg)
                            ddr_crc_ok <= 0;
                        if (ddr_crc_c == 0) begin
                            ddr_next_block <= ((ddr_blkcnt_reg - `BLKCNT_W'h1) != 0);
                            ddr_blkcnt_reg <= ddr_blkcnt_reg - `BLKCNT_W'h1;
                            ddr_byte_alignment_reg <= 0;//byte_alignment_reg + blksize_reg[1:0] + 2'b1;
                            ddr_crc_rst <= 1;
                        end
                    end
                end
            end

        endcase            
    end                
end 

always @(negedge sd_clk or posedge rst)
begin: FSM_DDR_N
    if (rst) begin
    end
    else begin
//        state <= next_state;
        case(state)
            DDR_IDLE: begin
//                ddr_transf_cnt <= 0;
//                ddr_crc_c <= 16;
//                ddr_crc_status <= 0;
//                ddr_crc_s <= 0;
//                ddr_data_index <= 0;
            end
            DDR_WRITE_WAIT: begin
//                ddr_data_index <= 0;
            end
            DDR_WRITE_DAT: begin
                //special case
                if (ddr_transf_cnt == 1) begin
                    if (ddr_bus_8bit_reg) begin
                        ddr_last_din_n <= {
                            data_in[31-(ddr_byte_alignment_reg << 3)], 
                            data_in[30-(ddr_byte_alignment_reg << 3)], 
                            data_in[29-(ddr_byte_alignment_reg << 3)], 
                            data_in[28-(ddr_byte_alignment_reg << 3)],
                            data_in[27-(ddr_byte_alignment_reg << 3)], 
                            data_in[26-(ddr_byte_alignment_reg << 3)], 
                            data_in[25-(ddr_byte_alignment_reg << 3)], 
                            data_in[24-(ddr_byte_alignment_reg << 3)]
                            };
                        ddr_crc_in <= {
                            data_in[31-(ddr_byte_alignment_reg << 3)], 
                            data_in[30-(ddr_byte_alignment_reg << 3)], 
                            data_in[29-(ddr_byte_alignment_reg << 3)], 
                            data_in[28-(ddr_byte_alignment_reg << 3)],
                            data_in[27-(ddr_byte_alignment_reg << 3)], 
                            data_in[26-(ddr_byte_alignment_reg << 3)], 
                            data_in[25-(ddr_byte_alignment_reg << 3)], 
                            data_in[24-(ddr_byte_alignment_reg << 3)]
                            };
                    end            
                    ddr_DAT_dat_on <= ddr_bus_8bit_reg ? 8'h0 :(ddr_bus_4bit_reg ? 8'hF0 : 8'hFE);                           
//                    ddr_data_index <= ddr_bus_8bit_reg ? {2'b0, ddr_byte_alignment_reg, 1'b1} :(ddr_bus_4bit_reg ? {2'b00, ddr_byte_alignment_reg, 1'b1} : {ddr_byte_alignment_reg, 3'b001});
                end
                else if ((ddr_transf_cnt >= 2) && (ddr_transf_cnt <= ddr_data_cycles+1)) begin
                    if (ddr_bus_8bit_reg) begin
                        ddr_last_din_n <= {
                            data_in[31-(ddr_data_index[1:0]<<3)], 
                            data_in[30-(ddr_data_index[1:0]<<3)], 
                            data_in[29-(ddr_data_index[1:0]<<3)], 
                            data_in[28-(ddr_data_index[1:0]<<3)],
                            data_in[27-(ddr_data_index[1:0]<<3)], 
                            data_in[26-(ddr_data_index[1:0]<<3)], 
                            data_in[25-(ddr_data_index[1:0]<<3)], 
                            data_in[24-(ddr_data_index[1:0]<<3)]
                            };
                        ddr_crc_in <= {
                            data_in[31-(ddr_data_index[1:0]<<3)], 
                            data_in[30-(ddr_data_index[1:0]<<3)], 
                            data_in[29-(ddr_data_index[1:0]<<3)], 
                            data_in[28-(ddr_data_index[1:0]<<3)],
                            data_in[27-(ddr_data_index[1:0]<<3)], 
                            data_in[26-(ddr_data_index[1:0]<<3)], 
                            data_in[25-(ddr_data_index[1:0]<<3)], 
                            data_in[24-(ddr_data_index[1:0]<<3)]
                            };
                    end
//                    ddr_data_index <= ddr_data_index + 5'h1;
                    ddr_DAT_dat_on <= ddr_last_din_n;
//                    if (ddr_transf_cnt == ddr_data_cycles+1)
//                        ddr_crc_en<=0;
                end
                else if (ddr_transf_cnt > ddr_data_cycles+1 & ddr_crc_c!=0) begin
//                    ddr_crc_en <= 0;
//                    ddr_crc_c <= ddr_crc_c - 5'h1;
//                    ddr_DAT_oe_o <= 0;
                    ddr_DAT_dat_on[0] <= ddr_crc_out[0][ddr_crc_c-1];
                    if (bus_8bit_reg)
                        ddr_DAT_dat_on[7:1] <= {ddr_crc_out[7][ddr_crc_c-1], ddr_crc_out[6][ddr_crc_c-1], ddr_crc_out[5][ddr_crc_c-1], ddr_crc_out[4][ddr_crc_c-1], ddr_crc_out[3][ddr_crc_c-1], ddr_crc_out[2][ddr_crc_c-1], ddr_crc_out[1][ddr_crc_c-1]};                   
                end
                else if (ddr_transf_cnt == ddr_data_cycles+18) begin
//                    ddr_DAT_oe_o <= 0;
                    ddr_DAT_dat_on <= 8'hFF;
                end
//                else if (ddr_transf_cnt >= ddr_data_cycles+19) begin
//                    ddr_DAT_oe_o <= 1;
//                end
            end
            DDR_WRITE_CRC: begin
//                ddr_DAT_oe_o <= 1;
//                if (ddr_crc_status < 4)
//                    ddr_crc_s[ddr_crc_status] <= DAT_dat_reg[0];
//                ddr_crc_status <= ddr_crc_status + 4'h1;
//                ddr_busy_int <= 1;
            end
            DDR_WRITE_BUSY: begin
//                if (ddr_crc_s == 4'b1010)
//                    ddr_crc_ok <= 1;
//                else
//                    ddr_crc_ok <= 0;
//                ddr_busy_int <= !DAT_dat_reg[0];
//                ddr_next_block <= ((ddr_blkcnt_reg - `BLKCNT_W'h1) != 0);
//                if (ddr_next_state != DDR_WRITE_BUSY) begin
////                    ddr_blkcnt_reg <= ddr_blkcnt_reg - `BLKCNT_W'h1;
//                    ddr_byte_alignment_reg <=  0;//byte_alignment_reg + blksize_reg[1:0] + 2'b1;
//                    ddr_crc_rst <= 1;
//                    ddr_crc_c <= 16;
//                    ddr_crc_status <= 0;
//                end
//                ddr_transf_cnt <= 0;
            end
            DDR_READ_WAIT: begin
//                ddr_DAT_oe_o <= 1;
//                ddr_crc_rst <= 0;
//                ddr_crc_en <= 1;
//                ddr_crc_in <= 0;
//                ddr_crc_c <= 15;// end
//                ddr_next_block <= 0;
//                ddr_transf_cnt <= 0;
//                ddr_data_index <= 0;//bus_4bit_reg ? (byte_alignment_reg << 1) : (byte_alignment_reg << 3);
            end
            DDR_READ_DAT: begin
                if (ddr_transf_cnt < ddr_data_cycles) begin
                    if (bus_8bit_reg) begin
                        ddr_data_out[31-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[7];
                        ddr_data_out[30-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[6];
                        ddr_data_out[29-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[5];
                        ddr_data_out[28-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[4];
                        ddr_data_out[27-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[3];
                        ddr_data_out[26-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[2];
                        ddr_data_out[25-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[1];
                        ddr_data_out[24-(ddr_data_index[1:0]<<3)] <= DAT_dat_reg[0];
                    end
//                    ddr_data_index <= ddr_data_index + 5'h1;
//                    ddr_crc_in <= DAT_dat_reg;
//                    ddr_crc_ok <= 1;
//                    ddr_transf_cnt <= ddr_transf_cnt + 16'h1;
                end
//                else if (ddr_transf_cnt <= ddr_data_cycles+16) begin
//                    ddr_transf_cnt <= ddr_transf_cnt + 16'h1;
//                    ddr_crc_en <= 0;
//                    ddr_last_din_n <= DAT_dat_reg;
//                    if (ddr_transf_cnt > ddr_data_cycles) begin
//                        ddr_crc_c <= ddr_crc_c - 5'h1;
//                        if  (ddr_crc_out[0][ddr_crc_c] != ddr_last_din_n[0])
//                            ddr_crc_ok <= 0;
//                        if  (ddr_crc_out[1][ddr_crc_c] != ddr_last_din_n[1] && bus_8bit_reg)
//                            ddr_crc_ok<=0;
//                        if  (ddr_crc_out[2][ddr_crc_c] != ddr_last_din_n[2] && bus_8bit_reg)
//                            ddr_crc_ok <= 0;
//                        if  (ddr_crc_out[3][ddr_crc_c] != ddr_last_din_n[3] && bus_8bit_reg)
//                            ddr_crc_ok <= 0;
//                        if  (ddr_crc_out[4][ddr_crc_c] != ddr_last_din_n[4] && bus_8bit_reg)
//                            ddr_crc_ok <= 0;
//                        if  (ddr_crc_out[5][ddr_crc_c] != ddr_last_din_n[5] && bus_8bit_reg)
//                            ddr_crc_ok <= 0;
//                        if  (ddr_crc_out[6][ddr_crc_c] != ddr_last_din_n[6] && bus_8bit_reg)
////                            ddr_crc_ok <= 0;
//                        if  (ddr_crc_out[7][ddr_crc_c] != ddr_last_din_n[7] && bus_8bit_reg)
////                            ddr_crc_ok <= 0;
//                        if (ddr_crc_c == 0) begin
//                            ddr_next_block <= ((ddr_blkcnt_reg - `BLKCNT_W'h1) != 0);
//                            ddr_blkcnt_reg <= ddr_blkcnt_reg - `BLKCNT_W'h1;
//                            ddr_byte_alignment_reg <= 0;//byte_alignment_reg + blksize_reg[1:0] + 2'b1;
//                            ddr_crc_rst <= 1;
//                        end
//                    end
//                end
            end

        endcase            
    end                
end 

// ODDR: Output Double Data Rate Output Register with Set, Reset
//       and Clock Enable.
//       Artix-7
// Xilinx HDL Language Template, version 2016.2

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst0 (
  .Q(DAT_dat_out[0]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[0]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[0]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst1 (
  .Q(DAT_dat_out[1]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[1]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[1]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst2 (
  .Q(DAT_dat_out[2]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[2]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[2]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst3 (
  .Q(DAT_dat_out[3]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[3]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[3]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst4 (
  .Q(DAT_dat_out[4]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[4]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[4]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst5 (
  .Q(DAT_dat_out[5]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[5]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[5]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst6 (
  .Q(DAT_dat_out[6]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[6]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[6]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);

ODDR #(
  .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
  .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
  .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
) ODDR_inst7 (
  .Q(DAT_dat_out[7]),   // 1-bit DDR output
  .C(sd_clk),   // 1-bit clock input
  .CE(1), // 1-bit clock enable input
  .D1(ddr_DAT_dat_o[7]), // 1-bit data input (positive edge)
  .D2(ddr_DAT_dat_on[7]), // 1-bit data input (negative edge)
  .R(0),   // 1-bit reset
  .S(0)    // 1-bit set
);
// End of ODDR_inst instantiation

endmodule





