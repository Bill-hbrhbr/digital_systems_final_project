`timescale 1ns/1ns

module searchSuperNode_main(		
		output [3:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,

		// nodeHeads RAM
		output [4:0] nodeHeads_addr,
		output [63:0] nodeHeads_data,
		output nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// nodeToElement RAM
		output [4:0] nodeToElement_addr,
		output [63:0] nodeToElement_data,
		output nodeToElement_wren,
		input [63:0] nodeToElement_out,
		
		// refNodes RAM
		output [4:0] refNodes_addr,
		output [4:0] refNodes_data,
		output refNodes_wren,
		input [4:0] refNodes_out,
		
		// Misc
		input [4:0] numElements,
		input [4:0] numNodes,
		input [4:0] ground_node,
		output [4:0] numRefNodes
		
	);
	
	
	wire go_reset_data, go_to_next_node, go_check_node_status, go_register_reference_node, go_check_element_type;
	wire go_store_element_addr, go_update_voltage_difference, begin_search_new_node, go_to_next_element, go_backtrace_dfs, go_backtrace_curr_search_addr;
		
	
	wire data_reset_done, loop_done, next_node_reached, node_checked, node_valid, reference_node_registered;
	wire is_voltage, type_checked, current_element_addr_stored, voltage_difference_updated, new_node_search_began;
	wire next_element_reached, end_of_list_reached, whole_dfs_done, backtrace_done, backtrace_curr_search_addr_done;
	
	wire [31:0] adder_data_a, adder_data_b, adder_out, subtractor_data_a, subtractor_data_b, subtractor_out;
	
	searchSuperNode_controller Ctrl_5(
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
		.loop_done(loop_done),
		.next_node_reached(next_node_reached),
		.node_checked(node_checked),
		.node_valid(node_valid),
		.reference_node_registered(reference_node_registered),
		.is_voltage(is_voltage),
		.type_checked(type_checked),
		.current_element_addr_stored(current_element_addr_stored),
		.voltage_difference_updated(voltage_difference_updated),
		.new_node_search_began(new_node_search_began),
		.next_element_reached(next_element_reached),
		.end_of_list_reached(end_of_list_reached),
		.whole_dfs_done(whole_dfs_done),
		.backtrace_done(backtrace_done),
		.backtrace_curr_search_addr_done(backtrace_curr_search_addr_done),
		
		
		// output handshakes
		.go_reset_data(go_reset_data),
		.go_to_next_node(go_to_next_node),
		.go_check_node_status(go_check_node_status),
		.go_register_reference_node(go_register_reference_node),
		.go_check_element_type(go_check_element_type),
		.go_store_element_addr(go_store_element_addr),
		.go_update_voltage_difference(go_update_voltage_difference),
		.begin_search_new_node(begin_search_new_node),
		.go_to_next_element(go_to_next_element),
		.go_backtrace_dfs(go_backtrace_dfs),
		.go_backtrace_curr_search_addr(go_backtrace_curr_search_addr)
		
	);
	
	
	
	searchSuperNode_datapath Data_5(
		// FPGA inputs
		.clk(clk),
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_to_next_node(go_to_next_node),
		.go_check_node_status(go_check_node_status),
		.go_register_reference_node(go_register_reference_node),
		.go_check_element_type(go_check_element_type),
		.go_store_element_addr(go_store_element_addr),
		.go_update_voltage_difference(go_update_voltage_difference),
		.begin_search_new_node(begin_search_new_node),
		.go_to_next_element(go_to_next_element),
		.go_backtrace_dfs(go_backtrace_dfs),
		.go_backtrace_curr_search_addr(go_backtrace_curr_search_addr),
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.loop_done(loop_done),
		.next_node_reached(next_node_reached),
		.node_checked(node_checked),
		.node_valid(node_valid),
		.reference_node_registered(reference_node_registered),
		.is_voltage(is_voltage),
		.type_checked(type_checked),
		.current_element_addr_stored(current_element_addr_stored),
		.voltage_difference_updated(voltage_difference_updated),
		.new_node_search_began(new_node_search_began),
		.next_element_reached(next_element_reached),
		.end_of_list_reached(end_of_list_reached),
		.whole_dfs_done(whole_dfs_done),
		.backtrace_done(backtrace_done),
		.backtrace_curr_search_addr_done(backtrace_curr_search_addr_done),
		
		
		// nodeHeads RAM
		.nodeHeads_addr(nodeHeads_addr),
		.nodeHeads_data(nodeHeads_data),
		.nodeHeads_wren(nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// nodeToElement RAM
		.nodeToElement_addr(nodeToElement_addr),
		.nodeToElement_data(nodeToElement_data),
		.nodeToElement_wren(nodeToElement_wren),
		.nodeToElement_out(nodeToElement_out),
		
		// refNodes RAM
		.refNodes_addr(refNodes_addr),
		.refNodes_data(refNodes_data),
		.refNodes_wren(refNodes_wren),
		.refNodes_out(refNodes_out),
		
		// adder
		.adder_data_a(adder_data_a),
		.adder_data_b(adder_data_b),
		.adder_out(adder_out),
		
		// subtractor
		.subtractor_data_a(subtractor_data_a),
		.subtractor_data_b(subtractor_data_b),
		.subtractor_out(subtractor_out),
		
		// Misc
		.numElements(numElements),
		.numNodes(numNodes),
		.ground_node(ground_node),
		.numRefNodes(numRefNodes)
	);
	
	adder Stage5_add(
		.clock(clk),
		.dataa(adder_data_a),
		.datab(adder_data_b),
		.result(adder_out)
	);
	
	subtractor Stage5_subtract(
		.clock(clk),
		.dataa(subtractor_data_a),
		.datab(subtractor_data_b),
		.result(subtractor_out)
	);
endmodule
