# pars
This repo includes the Pars Board Project related FPGA design, PCB design and the software source code folders. 
The PCB design folder includes the Pars Board 1 and Pars Board 2 Hardware schematics, layout and Gerber files.
The Liquid Router HW, which is derived from the Pars Board 2 HW is in another repo, namely https://github.com/subutai-io/liquid-router.git
The FPGA folder includes the eMMC 5.0 host controller ip core design and the RAID0 controller ip core.
The software folder includes the BSP for the Pars Board 1 and Pars Board 2 HW.

HW-RAID-0 this is IP core which will drive 2 eMMC HC like single HC, while increasing the performance of write and read