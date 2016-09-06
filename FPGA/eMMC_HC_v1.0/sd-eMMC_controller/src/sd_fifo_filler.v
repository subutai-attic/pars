//////////////////////////////////////////////////////////////////////
////                                                              ////
//// WISHBONE SD Card Controller IP Core                          ////
////                                                              ////
//// sd_fifo_filler.v                                             ////
////                                                              ////
//// This file is part of the WISHBONE SD Card                    ////
//// Controller IP Core project                                   ////
//// http://opencores.org/project,sd_card_controller              ////
////                                                              ////
//// Description                                                  ////
//// Fifo interface between sd card and wishbone clock domains    ////
//// and DMA engine eble to write/read to/from CPU memory         ////
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

module sd_fifo_filler(
           input wb_clk,
           input rst,
           input fifo_reset,
           
           // AXI Signals
           (* mark_debug = "true" *) output [31:0] read_fifo_out,                     //wbm_dat_o,         
           (* mark_debug = "true" *) input  [31:0] write_fifo_in,                     //wbm_dat_i,
           (* mark_debug = "true" *) input  fifo_data_read_ready,                     //input from axi
           (* mark_debug = "true" *) input  fifo_data_write_ready,
           
           // Data Master Control signals
           input  en_rx_i,
           input  en_tx_i,
           
           //Data Serial signals
           (* mark_debug = "true" *) input  sd_clk,
           (* mark_debug = "true" *) input  [31:0] dat_i,
           (* mark_debug = "true" *) output [31:0] dat_o,
           (* mark_debug = "true" *) input  wr_i,
           (* mark_debug = "true" *) input  rd_i,
           
           //Signals for Data Master Control
           output sd_full_o,
           output sd_empty_o,
           output wb_full_o,
           output wb_empty_o
       );

(* mark_debug = "true" *) wire reset_fifo;
wire fifo_rd;

assign fifo_rd = !wb_empty_o & fifo_data_read_ready;
assign reset_fifo = !en_rx_i & fifo_reset;


// synchronous simple 32 bits fifo keeping data for the cpu to write into eMMC 
data_write data_writeDDReMMC_I (
	.wr_clk		(wb_clk),      				// input wire clk
    .rd_clk     (sd_clk),
    .rst        (rst | reset_fifo),                    // input wire srst
	.din		(write_fifo_in),      	// input wire [31 : 0] din
	.wr_en		(fifo_data_write_ready && !wb_full_o),  		// input wire wr_en
	.rd_en		(rd_i),  			// input wire rd_en
	.dout		(dat_o),    			// output wire [31 : 0] dout
	.full		(wb_full_o),    					// output wire full
	.empty		(sd_empty_o)  					// output wire empty
);

// synchronous simple 32 bits fifo keeping data for the cpu to read from eMMC
data_read data_read_eMMC_DDR_I (
	.wr_clk		(sd_clk),      				// input wire clk
	.rd_clk     (wb_clk),
	.rst		(rst | reset_fifo),    				// input wire srst
	.din		(dat_i),      	// input wire [31 : 0] din
	.wr_en		(wr_i),  		// input wire wr_en
	.rd_en		(fifo_rd),  			// input wire rd_en
	.dout		(read_fifo_out),    			// output wire [31 : 0] dout
	.full		(sd_full_o),    					// output wire full
	.empty		(wb_empty_o)  					// output wire empty
);

endmodule


