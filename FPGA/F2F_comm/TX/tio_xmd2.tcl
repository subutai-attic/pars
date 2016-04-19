####### TX & RX ##########
source ./tx_selio_lvds.sdk/system_wrapper_hw_platform_0/ps7_init.tcl
connect arm hw
exec sleep 1
ps7_init
ps7_post_config 
fpga -f ./tx_selio_lvds.runs/impl_2/system_wrapper.bit

exec sleep 1
puts [mrd 0x43C10004]



