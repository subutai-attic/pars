####### TX ##########
source ./tx_selio_lvds/tx_selio_lvds.sdk/system_wrapper_hw_platform_0/ps7_init.tcl
connect arm hw
exec sleep 1
ps7_init
ps7_post_config 
fpga -f ./tx_selio_lvds/tx_selio_lvds.runs/impl_1/system_wrapper.bit
exec sleep 1
mwr 0x43C10004 0xA
mwr 0x43C10000 0x1
puts [mrd 0x43C10004]
#exec sleep 1
#mwr 0x43C10000 0
