//////////////////////////////////////////////////////////////////////////////////
// Company: Optimal Dynamics LLC
// Engineer: Azamat Beksadaev, Baktiiar Kukanov 
// 
// Create Date: 10/02/2015 11:41:32 AM
// Design Name: 
// Module Name: defines.h
// Project Name: RAID 0 Controller
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
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_defines.h                                                 ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Header file with common definitions                          ////
////                                                              ////
//// Author(s):                                                   ////
////     - Marek Czerski, ma.czerski@gmail.com                    ////
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


//sdma boubdaries
`define A11 8
`define A12 16
`define A13 32
`define A14 64
`define A15 128 
`define A16 256 
`define A17 512 
`define A18 1024

//adma attributes
`define valid 0
`define End 1
`define DatTarg 2
`define AddrSel 3
`define BurstLen 11:4
`define DatTransDir 1:0

//global defines
`define BLKSIZE_W 12
`define BLKCNT_W 16
`define CMD_TIMEOUT_W 24
`define DATA_TIMEOUT_W 29

//cmd module interrupts
`define INT_CMD_SIZE 6
`define INT_CMD_CC 0        //Completion Error
`define INT_CMD_EI 1        //End bit Error
`define INT_CMD_CTE 2       //Timeout interrupt
`define INT_CMD_CCRCE 3     //CRC Error Interrupt
`define INT_CMD_CIE  4      //Index Error Interrupt
`define INT_CMD_DC 5        // Data line not busy

//data module interrupts
`define INT_DATA_SIZE 6
`define INT_DATA_CC 0
`define INT_DATA_EI 1
`define INT_DATA_CTE 2
`define INT_DATA_CCRCE 3
`define INT_DATA_CFE 4
`define INT_DATA_BRE 5

//command register defines
`define CMD_REG_SIZE 14
`define CMD_RESPONSE_CHECK 1:0
//`define CMD_BUSY_CHECK 2
`define CMD_CRC_CHECK 3
`define CMD_IDX_CHECK 4
`define CMD_WITH_DATA 5
`define CMD_INDEX 13:8

//register addreses
`define argument 8'h00
`define command 8'h04
`define resp0 8'h08
`define resp1 8'h0c
`define resp2 8'h10
`define resp3 8'h14
`define data_timeout 8'h18
`define controller 8'h1c
`define cmd_timeout 8'h20
`define clock_d 8'h24
`define reset 8'h28
`define voltage 8'h2c
`define capa 8'h30
`define cmd_isr 8'h34
`define cmd_iser 8'h38
`define data_isr 8'h3c
`define data_iser 8'h40
`define blksize 8'h44
`define blkcnt 8'h48
`define dst_src_addr 8'h60

//wb module defines
`define RESET_BLOCK_SIZE 12'd511
`define RESET_CLK_DIV 0
`define SUPPLY_VOLTAGE_mV 3300
