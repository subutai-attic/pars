
`timescale 1 ns / 1 ps

	module stream_master_v1_0 #
	(
		// Users to add parameters here
        parameter NUMBER_OF_OUTPUT_WORDS = 8,
        parameter INITIAL_NUMBER = 1,
        parameter ITERATION_NUMBER = 2,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M_AXIS
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M_AXIS
		input wire  m_axis_aclk,
		input wire  m_axis_aresetn,
		output wire  m_axis_tvalid,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] m_axis_tdata,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] m_axis_tstrb,
		output wire  m_axis_tlast,
		input wire  m_axis_tready
	);
// Instantiation of Axi Bus Interface M_AXIS
	stream_master_v1_0_M_AXIS # ( 
	    .NUMBER_OF_OUTPUT_WORDS(NUMBER_OF_OUTPUT_WORDS),
	    .INITIAL_NUMBER(INITIAL_NUMBER),
	    .ITERATION_NUMBER(ITERATION_NUMBER),
		.C_M_AXIS_TDATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M_AXIS_START_COUNT)
	) stream_master_v1_0_M_AXIS_inst (
		.M_AXIS_ACLK(m_axis_aclk),
		.M_AXIS_ARESETN(m_axis_aresetn),
		.M_AXIS_TVALID(m_axis_tvalid),
		.M_AXIS_TDATA(m_axis_tdata),
		.M_AXIS_TSTRB(m_axis_tstrb),
		.M_AXIS_TLAST(m_axis_tlast),
		.M_AXIS_TREADY(m_axis_tready)
	);

	// Add user logic here

	// User logic ends

	endmodule
