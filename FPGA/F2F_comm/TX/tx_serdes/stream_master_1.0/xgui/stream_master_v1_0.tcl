# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "INITIAL_NUMBER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUMBER_OF_OUTPUT_WORDS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ITERATION_NUMBER" -parent ${Page_0}
  set C_M_AXIS_TDATA_WIDTH [ipgui::add_param $IPINST -name "C_M_AXIS_TDATA_WIDTH" -parent ${Page_0} -widget comboBox]
  set_property tooltip {Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.} ${C_M_AXIS_TDATA_WIDTH}
  set C_M_AXIS_START_COUNT [ipgui::add_param $IPINST -name "C_M_AXIS_START_COUNT" -parent ${Page_0}]
  set_property tooltip {Start count is the numeber of clock cycles the master will wait before initiating/issuing any transaction.} ${C_M_AXIS_START_COUNT}


}

proc update_PARAM_VALUE.INITIAL_NUMBER { PARAM_VALUE.INITIAL_NUMBER } {
	# Procedure called to update INITIAL_NUMBER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INITIAL_NUMBER { PARAM_VALUE.INITIAL_NUMBER } {
	# Procedure called to validate INITIAL_NUMBER
	return true
}

proc update_PARAM_VALUE.ITERATION_NUMBER { PARAM_VALUE.ITERATION_NUMBER } {
	# Procedure called to update ITERATION_NUMBER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ITERATION_NUMBER { PARAM_VALUE.ITERATION_NUMBER } {
	# Procedure called to validate ITERATION_NUMBER
	return true
}

proc update_PARAM_VALUE.NUMBER_OF_OUTPUT_WORDS { PARAM_VALUE.NUMBER_OF_OUTPUT_WORDS } {
	# Procedure called to update NUMBER_OF_OUTPUT_WORDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUMBER_OF_OUTPUT_WORDS { PARAM_VALUE.NUMBER_OF_OUTPUT_WORDS } {
	# Procedure called to validate NUMBER_OF_OUTPUT_WORDS
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_M_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_TDATA_WIDTH { PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_M_AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_M_AXIS_START_COUNT { PARAM_VALUE.C_M_AXIS_START_COUNT } {
	# Procedure called to update C_M_AXIS_START_COUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_M_AXIS_START_COUNT { PARAM_VALUE.C_M_AXIS_START_COUNT } {
	# Procedure called to validate C_M_AXIS_START_COUNT
	return true
}


proc update_MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH PARAM_VALUE.C_M_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_M_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_M_AXIS_START_COUNT { MODELPARAM_VALUE.C_M_AXIS_START_COUNT PARAM_VALUE.C_M_AXIS_START_COUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_M_AXIS_START_COUNT}] ${MODELPARAM_VALUE.C_M_AXIS_START_COUNT}
}

proc update_MODELPARAM_VALUE.NUMBER_OF_OUTPUT_WORDS { MODELPARAM_VALUE.NUMBER_OF_OUTPUT_WORDS PARAM_VALUE.NUMBER_OF_OUTPUT_WORDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUMBER_OF_OUTPUT_WORDS}] ${MODELPARAM_VALUE.NUMBER_OF_OUTPUT_WORDS}
}

proc update_MODELPARAM_VALUE.INITIAL_NUMBER { MODELPARAM_VALUE.INITIAL_NUMBER PARAM_VALUE.INITIAL_NUMBER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INITIAL_NUMBER}] ${MODELPARAM_VALUE.INITIAL_NUMBER}
}

proc update_MODELPARAM_VALUE.ITERATION_NUMBER { MODELPARAM_VALUE.ITERATION_NUMBER PARAM_VALUE.ITERATION_NUMBER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ITERATION_NUMBER}] ${MODELPARAM_VALUE.ITERATION_NUMBER}
}

