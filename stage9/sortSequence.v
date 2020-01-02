module sortSequence_main(
		// Input handshakes
		output go_reset_data, go_calculate_width, go_set_element_seq, go_choose_next_node, go_check_node, go_set_node_seq,
		
		// Output hanshakes
		output data_reset_done, width_calculated, element_seq_set, node_chosen, all_nodes_set, node_checked, node_valid, node_seq_set,
		
		
		output [3:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// RAM: nodeHeads 64x32
		output [4:0] nodeHeads_addr,
		output nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// RAM: nodeSeq 5x32
		output [4:0] nodeSeq_addr,
		output [4:0] nodeSeq_data,
		output nodeSeq_wren,
		input [4:0] nodeSeq_out,

		// RAM: elementSeq 5x32
		output [4:0] elementSeq_addr,
		output [4:0] elementSeq_data,
		output elementSeq_wren,
		input [4:0] elementSeq_out,

		input [4:0] numNodes,
		input [4:0] numElements,
		output [9:0] block_width
	);
	
	// Input handshakes
	//wire go_reset_data, go_calculate_width, go_set_element_seq, go_choose_next_node, go_check_node, go_set_node_seq;
		
	// Output hanshakes
	//wire data_reset_done, width_calculated, element_seq_set, node_chosen, all_nodes_set, node_checked, node_valid, node_seq_set;
	
	sortSequence_controller Ctrl_9(
		.current_state(cs),
		.next_state(ns),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(program_reset),  // ~KEY[0]
		
		// Initial and Final
		.start_process(start_process),
		.end_process(end_process),
		
		// Input hanshakes
		.data_reset_done(data_reset_done),
		.width_calculated(width_calculated),
		.element_seq_set(element_seq_set),
		.node_chosen(node_chosen),
		.all_nodes_set(all_nodes_set),
		.node_checked(node_checked),
		.node_valid(node_valid),
		.node_seq_set(node_seq_set),
		
		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_calculate_width(go_calculate_width),
		.go_set_element_seq(go_set_element_seq),
		.go_choose_next_node(go_choose_next_node),
		.go_check_node(go_check_node),
		.go_set_node_seq(go_set_node_seq)
	);
	
	
	sortSequence_datapath Data_9(
		// FPGA inputs
		.clk(clk),

		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_calculate_width(go_calculate_width),
		.go_set_element_seq(go_set_element_seq),
		.go_choose_next_node(go_choose_next_node),
		.go_check_node(go_check_node),
		.go_set_node_seq(go_set_node_seq),
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.width_calculated(width_calculated),
		.element_seq_set(element_seq_set),
		.node_chosen(node_chosen),
		.all_nodes_set(all_nodes_set),
		.node_checked(node_checked),
		.node_valid(node_valid),
		.node_seq_set(node_seq_set),
		
		// RAM: nodeHeads 64x32
		.nodeHeads_addr(nodeHeads_addr),
		.nodeHeads_wren(nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// RAM: nodeSeq 5x32
		.nodeSeq_addr(nodeSeq_addr),
		.nodeSeq_data(nodeSeq_data),
		.nodeSeq_wren(nodeSeq_wren),
		.nodeSeq_out(nodeSeq_out),
		
		// RAM: elementSeq 5x32
		.elementSeq_addr(elementSeq_addr),
		.elementSeq_data(elementSeq_data),
		.elementSeq_wren(elementSeq_wren),
		.elementSeq_out(elementSeq_out),

		// Misc
		.numNodes(numNodes),
		.numElements(numElements),
		.block_width(block_width)

	);
	
	
endmodule
