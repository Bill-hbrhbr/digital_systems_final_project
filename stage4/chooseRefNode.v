`timescale 1ns/1ns

module chooseRefNode_main (
		output [3:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset, input_over, go,
		input [9:0] data_in,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// Hex Display
		output [6:0] h0, h1, h2, h3, h4, h5,
		
		// count
		input [4:0] numNodes,
		output [4:0] ground_node
		
	);
	

		
	wire data_reset_done, done_judge, node_index_valid;
		
	wire go_reset_data, go_display_choose, go_display_refnode, ld_node_index, go_judge_valid, go_display_invalid;
		
	
	chooseRefNode_controller Ctrl_4(
		.current_state(cs),
		.next_state(ns),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(program_reset),    // ~KEY[0]
		.input_over(input_over),          // ~KEY[2]
		.go(go),                          // ~KEY[3]
		
		// Initial and Final
		.start_process(start_process),
		.end_process(end_process),
		
		// Input handshakes
		.data_reset_done(data_reset_done),
		.done_judge(done_judge),
		.node_index_valid(node_index_valid),
		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_display_choose(go_display_choose),
		.go_display_refnode(go_display_refnode),
		.ld_node_index(ld_node_index),
		.go_judge_valid(go_judge_valid),
		.go_display_invalid(go_display_invalid)
		
	);
	
	
	chooseRefNode_datapath Data_4(
		// FPGA inputs
		.clk(clk),
		.data_in(data_in),   // SW[9:0]
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_display_choose(go_display_choose),
		.go_display_refnode(go_display_refnode),
		.ld_node_index(ld_node_index),
		.go_judge_valid(go_judge_valid),
		.go_display_invalid(go_display_invalid),
		 
		 // Output handshakes
		.data_reset_done(data_reset_done),
		.done_judge(done_judge),
		.node_index_valid(node_index_valid),
		
		// HEX display
		.h0(h0),
		.h1(h1),
		.h2(h2),
		.h3(h3),
		.h4(h4),
		.h5(h5),
		
		.numNodes(numNodes),
		.ground_node(ground_node)
	);
	
endmodule
