// fft_ii_0_example_design.v

// Generated using ACDS version 18.1 625

`timescale 1 ps / 1 ps
module fft_ii_0_example_design (
		input  wire        core_clk_clk,              //    core_clk.clk
		input  wire        core_rst_reset_n,          //    core_rst.reset_n
		input  wire        core_sink_valid,           //   core_sink.valid
		output wire        core_sink_ready,           //            .ready
		input  wire [1:0]  core_sink_error,           //            .error
		input  wire        core_sink_startofpacket,   //            .startofpacket
		input  wire        core_sink_endofpacket,     //            .endofpacket
		input  wire [32:0] core_sink_data,            //            .data
		output wire        core_source_valid,         // core_source.valid
		input  wire        core_source_ready,         //            .ready
		output wire [1:0]  core_source_error,         //            .error
		output wire        core_source_startofpacket, //            .startofpacket
		output wire        core_source_endofpacket,   //            .endofpacket
		output wire [37:0] core_source_data           //            .data
	);

	wire  [15:0] core_source_imag; // port fragment
	wire  [15:0] core_source_real; // port fragment
	wire   [5:0] core_source_exp;  // port fragment

	fft_ii_0_example_design_core core (
		.clk          (core_clk_clk),              //    clk.clk
		.reset_n      (core_rst_reset_n),          //    rst.reset_n
		.sink_valid   (core_sink_valid),           //   sink.valid
		.sink_ready   (core_sink_ready),           //       .ready
		.sink_error   (core_sink_error),           //       .error
		.sink_sop     (core_sink_startofpacket),   //       .startofpacket
		.sink_eop     (core_sink_endofpacket),     //       .endofpacket
		.sink_real    (core_sink_data[32:17]),     //       .data
		.sink_imag    (core_sink_data[16:1]),      //       .data
		.inverse      (core_sink_data[0]),         //       .data
		.source_valid (core_source_valid),         // source.valid
		.source_ready (core_source_ready),         //       .ready
		.source_error (core_source_error),         //       .error
		.source_sop   (core_source_startofpacket), //       .startofpacket
		.source_eop   (core_source_endofpacket),   //       .endofpacket
		.source_real  (core_source_real[15:0]),    //       .data
		.source_imag  (core_source_imag[15:0]),    //       .data
		.source_exp   (core_source_exp[5:0])       //       .data
	);

	assign core_source_data = { core_source_real[15:0], core_source_imag[15:0], core_source_exp[5:0] };

endmodule
