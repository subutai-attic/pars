####### TX & RX ##########
source ./tx_selio_lvds/tx_selio_lvds.sdk/system_wrapper_hw_platform_0/ps7_init.tcl
connect arm hw
exec sleep 1
ps7_init
ps7_post_config 
fpga -f ./tx_selio_lvds/tx_selio_lvds.runs/impl_1/system_wrapper.bit
exec sleep 1
mwr 0x43C00004 0xA0A0A0A0
mwr 0x43C00000 1
mwr 0x43C10000 1
puts [mrd 0x43C00004]
exec sleep 1
mwr 0x43C00000 0
mwr 0X43C10000 0
mwr 0x43C10008 1
mwr 0x43C10008 0
exec sleep 1
puts "Test pattern"
puts [mrd 0x43C10004]


# Data send test
puts "Data test - 1"
mwr 0x43C00004 0xAAAAAAAA
mwr 0x43C00000 1
mwr 0x43C10000 1
puts [mrd 0x43C00004]
exec sleep 1
mwr 0x43C00000 0
mwr 0X43C10000 0
exec sleep 1 
puts "Data 1"
puts [mrd 0x43C10004]


# Data send test
puts "Data test - 2"
mwr 0x43C00004 0x01010101
mwr 0x43C00000 1
mwr 0x43C10000 1
puts [mrd 0x43C00004]
exec sleep 1
mwr 0x43C00000 0
mwr 0X43C10000 0
exec sleep 1 
puts "Data 2"
puts [mrd 0x43C10004]

# Data send test
puts "Data test - 3"
mwr 0x43C00004 0xFAFAFAFA
mwr 0x43C00000 1
mwr 0x43C10000 1
puts [mrd 0x43C00004]
exec sleep 1
mwr 0x43C00000 0
mwr 0X43C10000 0
exec sleep 1 
puts "Data 2"
mrd 0x43C10004
