module configureCircuit_main(
		output [4:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// RAM: nodeSeq 32x5
		output [4:0] nodeSeq_addr,
		output nodeSeq_wren,
		input [4:0] nodeSeq_out,
		
		// RAM: elementSeq 32x5
		output [4:0] elementSeq_addr,
		output elementSeq_wren,
		input [4:0] elementSeq_out,
		
		// RAM: processor 1024x48
		output [9:0] processor_addr,
		output [47:0] processor_data,
		output processor_wren,
		input [47:0] processor_out,
		
		// RAM: element 32x32
		output [4:0] element_addr,
		output element_wren,
		input [31:0] element_out,
		
		input [4:0] numNodes,
		input [4:0] numElements,
		input [9:0] block_width,
		input [53:0] node_vga_pos,
		output [9:0] numCommands
	);

	
	wire go_reset_data, go_clear_signals, write_dashed_node_line, go_choose_element, go_get_element_info;
	wire go_search_node_A, go_search_node_B, go_write_element_wire, go_write_element_sprite, go_write_top_node, go_write_bot_node;
		

	wire data_reset_done, signals_cleared, dashed_node_line_written, element_chosen, element_info_obtained, all_elements_written;
	wire node_A_found, node_B_found, element_wire_written, element_sprite_written, top_node_written, bot_node_written;
	
	
	configureCircuit_controller Ctrl_10(
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
		.signals_cleared(signals_cleared),
		.dashed_node_line_written(dashed_node_line_written),
		.element_chosen(element_chosen),
		.element_info_obtained(element_info_obtained),
		.all_elements_written(all_elements_written),
		.node_A_found(node_A_found),
		.node_B_found(node_B_found),
		.element_wire_written(element_wire_written),
		.element_sprite_written(element_sprite_written),
		.top_node_written(top_node_written),
		.bot_node_written(bot_node_written),
		
		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_clear_signals(go_clear_signals),
		.write_dashed_node_line(write_dashed_node_line),
		.go_choose_element(go_choose_element),
		.go_get_element_info(go_get_element_info),
		.go_search_node_A(go_search_node_A),
		.go_search_node_B(go_search_node_B),
		.go_write_element_wire(go_write_element_wire),
		.go_write_element_sprite(go_write_element_sprite),
		.go_write_top_node(go_write_top_node),
		.go_write_bot_node(go_write_bot_node)
	);
	
	
	configureCircuit_datapath Data_10(
		/*
		.nodeA(nodeA),
		.nodeB(nodeB),
		.nodeA_pos(nodeA_pos),
		.nodeB_pos(nodeB_pos),
		.top_node_pos(top_node_pos),
		.bot_node_pos(bot_node_pos),
		.top_bot_diff(top_bot_diff),
		.centerX(centerX),
		.centerY(centerY),
		.element_left_pos(element_left_pos),
		.element_top_pos(element_top_pos),
		*/
		
		// FPGA inputs
		.clk(clk),
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_clear_signals(go_clear_signals),
		.write_dashed_node_line(write_dashed_node_line),
		.go_choose_element(go_choose_element),
		.go_get_element_info(go_get_element_info),
		.go_search_node_A(go_search_node_A),
		.go_search_node_B(go_search_node_B),
		.go_write_element_wire(go_write_element_wire),
		.go_write_element_sprite(go_write_element_sprite),
		.go_write_top_node(go_write_top_node),
		.go_write_bot_node(go_write_bot_node),
		
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.signals_cleared(signals_cleared),
		.dashed_node_line_written(dashed_node_line_written),
		.element_chosen(element_chosen),
		.element_info_obtained(element_info_obtained),
		.all_elements_written(all_elements_written),
		.node_A_found(node_A_found),
		.node_B_found(node_B_found),
		.element_wire_written(element_wire_written),
		.element_sprite_written(element_sprite_written),
		.top_node_written(top_node_written),
		.bot_node_written(bot_node_written),
		
		// RAM: nodeSeq
		.nodeSeq_addr(nodeSeq_addr),
		.nodeSeq_wren(nodeSeq_wren),
		.nodeSeq_out(nodeSeq_out),
		
		// RAM: elementSeq
		.elementSeq_addr(elementSeq_addr),
		.elementSeq_wren(elementSeq_wren),
		.elementSeq_out(elementSeq_out),
		
		// RAM: processor
		.processor_addr(processor_addr),
		.processor_data(processor_data),
		.processor_wren(processor_wren),
		.processor_out(processor_out),
		
		// RAM: element
		.element_addr(element_addr),
		.element_wren(element_wren),
		.element_out(element_out),
		
		// Misc
		.numNodes(numNodes),
		.numElements(numElements),
		.block_width(block_width),
		.node_vga_pos(node_vga_pos),
		.numCommands(numCommands)

	);
	


	
endmodule
