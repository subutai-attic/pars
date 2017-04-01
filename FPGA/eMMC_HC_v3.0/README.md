This is the AXI SD-eMMC Host Controller IP Core repository
==========================================================
The AXI SD-eMMC Host Controller (HC) IP Core is SD/eMMC card communication controller designed to be
used in a System-on-Chip. IP core provides interface for any CPU with AXI bus. The communication between the MMC/SD card controller and MMC/SD card is performed according to the SD/eMMC protocol.

## Introduction
This IP core based on the "Wishbone SD Card Controller IP Core" project from https://github.com/mczerski/SD-card-controller
The IP core has been rewritten from Wishbone to the AXI interface and adapted to "SD Specification Part A2 Version 3.00" and "JEDEC Standard No. 84-B51". Major changes:

- Control register address map has been changed for almost all registers,
- Data bytes alignment order has been changed,
- Interrupt generation logic has been added for data and command layer,
- FIFO replaced to Xilinx standard FIFO primitive,
- ODDR, IDDR primitives are added,
- SDMA module is created, then wrapped into the ADMA module,
- Extended amount of control registers,

## Features
The SD/eMMC HC provides the following features:
- 4-bit SD card or/and  8-bit eMMC card mode (does not support SPI mode)
- Hardware interrupt for data and command transactions
- 32-bit AXI Interface
- 50 MGh clock, Single Data Rate (SDR) or/and Double Data Rate (DDR)
- ADMA2 support
- AutoCMD23 feature support
- Compatible with Linux distributed Arasan SDHCI driver

## Howto
To make driver support 8-bit need to add a line "mmc->caps |= MMC_CAP_8_BIT_DATA;" to the "drivers/mmc/host/sdhci.c#L3107"

## The hardware on which HC were run
- Boards:
	- Parallella
	- ZedBoard
- Cards:
	- Hardkernel v0.3

## License
This core is free software. You can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 2.1 of the License, or (at your option) any later version.
