
################################################################
# This is a generated script based on design: system
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2015.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source system_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7z020clg400-1

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}



# CHANGE DESIGN NAME HERE
set design_name system

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   puts "INFO: Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]
  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]
  set diff_clk_to_pins [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_clock_rtl:1.0 diff_clk_to_pins ]

  # Create ports
  set data_out_to_pins_n [ create_bd_port -dir O -from 0 -to 0 data_out_to_pins_n ]
  set data_out_to_pins_p [ create_bd_port -dir O -from 0 -to 0 data_out_to_pins_p ]

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0 ]
  set_property -dict [ list \
CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
 ] $processing_system7_0

  # Create instance: processing_system7_0_axi_periph, and set properties
  set processing_system7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 processing_system7_0_axi_periph ]
  set_property -dict [ list \
CONFIG.NUM_MI {1} \
 ] $processing_system7_0_axi_periph

  # Create instance: rst_processing_system7_0_50M, and set properties
  set rst_processing_system7_0_50M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processing_system7_0_50M ]

  # Create instance: selectio_wiz_0, and set properties
  set selectio_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz:5.1 selectio_wiz_0 ]
  set_property -dict [ list \
CONFIG.BUS_DIR {OUTPUTS} \
CONFIG.BUS_IO_STD {LVDS_25} \
CONFIG.BUS_SIG_TYPE {DIFF} \
CONFIG.CLK_FWD {true} \
CONFIG.CLK_FWD_IO_STD {LVDS_25} \
CONFIG.CLK_FWD_SIG_TYPE {DIFF} \
CONFIG.CONFIG_CLK_FWD {true} \
CONFIG.SELIO_ACTIVE_EDGE {DDR} \
CONFIG.SELIO_BUS_IN_DELAY {NONE} \
CONFIG.SELIO_CLK_BUF {MMCM} \
CONFIG.SELIO_CLK_IO_STD {LVDS_25} \
CONFIG.SELIO_CLK_SIG_TYPE {DIFF} \
CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
CONFIG.SERIALIZATION_FACTOR {8} \
CONFIG.SYSTEM_DATA_WIDTH {1} \
CONFIG.USE_SERIALIZATION {true} \
 ] $selectio_wiz_0

  # Create instance: tx_selio_0, and set properties
  set tx_selio_0 [ create_bd_cell -type ip -vlnv user.org:user:tx_selio:1.0 tx_selio_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins processing_system7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_axi_periph_M00_AXI [get_bd_intf_pins processing_system7_0_axi_periph/M00_AXI] [get_bd_intf_pins tx_selio_0/S00_AXI]
  connect_bd_intf_net -intf_net selectio_wiz_0_diff_clk_to_pins [get_bd_intf_ports diff_clk_to_pins] [get_bd_intf_pins selectio_wiz_0/diff_clk_to_pins]

  # Create port connections
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0_axi_periph/ACLK] [get_bd_pins processing_system7_0_axi_periph/M00_ACLK] [get_bd_pins processing_system7_0_axi_periph/S00_ACLK] [get_bd_pins rst_processing_system7_0_50M/slowest_sync_clk] [get_bd_pins tx_selio_0/s00_axi_aclk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_processing_system7_0_50M/ext_reset_in]
  connect_bd_net -net rst_processing_system7_0_50M_interconnect_aresetn [get_bd_pins processing_system7_0_axi_periph/ARESETN] [get_bd_pins rst_processing_system7_0_50M/interconnect_aresetn]
  connect_bd_net -net rst_processing_system7_0_50M_peripheral_aresetn [get_bd_pins processing_system7_0_axi_periph/M00_ARESETN] [get_bd_pins processing_system7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_processing_system7_0_50M/peripheral_aresetn] [get_bd_pins tx_selio_0/s00_axi_aresetn]
  connect_bd_net -net selectio_wiz_0_data_out_to_pins_n [get_bd_ports data_out_to_pins_n] [get_bd_pins selectio_wiz_0/data_out_to_pins_n]
  connect_bd_net -net selectio_wiz_0_data_out_to_pins_p [get_bd_ports data_out_to_pins_p] [get_bd_pins selectio_wiz_0/data_out_to_pins_p]
  connect_bd_net -net tx_selio_0_dout [get_bd_pins selectio_wiz_0/data_out_from_device] [get_bd_pins tx_selio_0/dout]
  connect_bd_net -net tx_selio_0_reset [get_bd_pins selectio_wiz_0/clk_reset] [get_bd_pins selectio_wiz_0/io_reset] [get_bd_pins tx_selio_0/reset]
  connect_bd_net -net tx_selio_0_txclk [get_bd_pins selectio_wiz_0/clk_in] [get_bd_pins tx_selio_0/txclk]
  connect_bd_net -net tx_selio_0_txclk_div [get_bd_pins selectio_wiz_0/clk_div_in] [get_bd_pins tx_selio_0/txclk_div]

  # Create address segments
  create_bd_addr_seg -range 0x10000 -offset 0x43C00000 [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs tx_selio_0/S00_AXI/S00_AXI_reg] SEG_tx_selio_0_S00_AXI_reg

  # Perform GUI Layout
  regenerate_bd_layout -layout_string {
   guistr: "# # String gsaved with Nlview 6.5.5  2015-06-26 bk=1.3371 VDI=38 GEI=35 GUI=JA:1.8
#  -string -flagsOSRD
preplace port DDR -pg 1 -y 110 -defaultsOSRD
preplace port FIXED_IO -pg 1 -y 250 -defaultsOSRD
preplace port diff_clk_to_pins -pg 1 -y 320 -defaultsOSRD
preplace portBus data_out_to_pins_n -pg 1 -y 360 -defaultsOSRD
preplace portBus data_out_to_pins_p -pg 1 -y 340 -defaultsOSRD
preplace inst tx_selio_0 -pg 1 -lvl 3 -y 180 -defaultsOSRD
preplace inst rst_processing_system7_0_50M -pg 1 -lvl 1 -y 100 -defaultsOSRD
preplace inst selectio_wiz_0 -pg 1 -lvl 4 -y 340 -defaultsOSRD
preplace inst processing_system7_0_axi_periph -pg 1 -lvl 2 -y 110 -defaultsOSRD
preplace inst processing_system7_0 -pg 1 -lvl 1 -y 270 -defaultsOSRD
preplace netloc processing_system7_0_DDR 1 1 4 NJ 230 NJ 100 NJ 100 NJ
preplace netloc processing_system7_0_axi_periph_M00_AXI 1 2 1 760
preplace netloc rst_processing_system7_0_50M_interconnect_aresetn 1 1 1 440
preplace netloc processing_system7_0_M_AXI_GP0 1 1 1 430
preplace netloc tx_selio_0_reset 1 3 1 1010
preplace netloc tx_selio_0_dout 1 3 1 1020
preplace netloc tx_selio_0_txclk_div 1 3 1 1040
preplace netloc selectio_wiz_0_diff_clk_to_pins 1 4 1 NJ
preplace netloc processing_system7_0_FCLK_RESET0_N 1 0 2 30 360 430
preplace netloc rst_processing_system7_0_50M_peripheral_aresetn 1 1 2 440 240 760
preplace netloc processing_system7_0_FIXED_IO 1 1 4 NJ 260 NJ 260 NJ 250 NJ
preplace netloc selectio_wiz_0_data_out_to_pins_n 1 4 1 NJ
preplace netloc processing_system7_0_FCLK_CLK0 1 0 3 20 10 420 250 750
preplace netloc selectio_wiz_0_data_out_to_pins_p 1 4 1 NJ
preplace netloc tx_selio_0_txclk 1 3 1 1050
levelinfo -pg 1 0 220 590 890 1240 1450 -top 0 -bot 430
",
}

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


