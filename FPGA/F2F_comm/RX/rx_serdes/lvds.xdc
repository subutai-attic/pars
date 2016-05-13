set_property IOSTANDARD LVCMOS25 [get_ports UART_0_rxd]
set_property IOSTANDARD LVCMOS25 [get_ports UART_0_txd]
set_property PACKAGE_PIN Y11 [get_ports UART_0_rxd]
set_property PACKAGE_PIN AA11 [get_ports UART_0_txd]

#set_property PACKAGE_PIN D20 [get_ports {data_in_from_pins_p[0]}]
#set_property PACKAGE_PIN L18 [get_ports diff_clk_in_clk_p]

#set_property PACKAGE_PIN M19 [get_ports {data_in_from_pins_p[0]}]
#set_property PACKAGE_PIN N22 [get_ports {data_in_from_pins_p[1]}]
#set_property PACKAGE_PIN M21 [get_ports {data_in_from_pins_p[2]}]
#set_property PACKAGE_PIN P17 [get_ports {data_in_from_pins_p[3]}]
#set_property PACKAGE_PIN E19 [get_ports {data_in_from_pins_p[4]}]


#set_property PACKAGE_PIN D20 [get_ports {data_in_from_pins_p[0]}]

#E21 bad ------------------
#D20 bad


#D22 good +++++++++--------
#B21 good +++++++++++++++++++++
#C17 good +++++++++++++++++++++
#A16 good +++++++++++++++++++++????????????
#A18 good +++++++++++++++++++++
#A21 bad ------------------
#set_property PACKAGE_PIN B21 [get_ports {data_in_from_pins_p[1]}]
#set_property PACKAGE_PIN A21 [get_ports {data_in_from_pins_p[2]}]
#set_property PACKAGE_PIN B21 [get_ports {data_in_from_pins_p[3]}]
#set_property PACKAGE_PIN A21 [get_ports {data_in_from_pins_p[4]}]

#set_property PACKAGE_PIN A18 [get_ports {data_in_from_pins_p[3]}]
#B21

#set_property PACKAGE_PIN B21 [get_ports {data_in_from_pins_p[0]}]
#set_property PACKAGE_PIN C17 [get_ports {data_in_from_pins_p[1]}]
#set_property PACKAGE_PIN A16 [get_ports {data_in_from_pins_p[2]}]
#set_property PACKAGE_PIN A18 [get_ports {data_in_from_pins_p[3]}]
#not A16, B16
set_property PACKAGE_PIN A18 [get_ports {data_to_and_from_pins_p[0]}]
set_property PACKAGE_PIN B21 [get_ports {data_to_and_from_pins_p[1]}]
set_property PACKAGE_PIN C17 [get_ports {data_to_and_from_pins_p[2]}]

set_property PACKAGE_PIN B19 [get_ports {data_to_and_from_pins_p_1[0]}]
set_property PACKAGE_PIN D22 [get_ports {data_to_and_from_pins_p_1[1]}]


set_property PACKAGE_PIN D18 [get_ports diff_clk_in_clk_p]
