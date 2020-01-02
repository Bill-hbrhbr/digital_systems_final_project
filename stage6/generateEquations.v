`timescale 1ns/1ns

module generateEquations_main(		
		output [3:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,

		// nodeHeads RAM
		output [4:0] nodeHeads_addr,
		output nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// nodeToElement RAM
		output [4:0] nodeToElement_addr,
		output nodeToElement_wren,
		input [63:0] nodeToElement_out,
		
		// RAM: float_matrix 4096x32
		output [11:0] matrix_addr_a, matrix_addr_b, 
		output [31:0] matrix_data_a, matrix_data_b,
		output matrix_wren_a, matrix_wren_b,
		input [31:0] matrix_out_a, matrix_out_b,
		
		// Misc
		input [4:0] numElements,
		input [4:0] numNodes,
		input [4:0] ground_node,
		input [4:0] numRefNodes
		
	);
	
	
	
	wire go_reset_data, go_initialize_matrix, go_choose_node, go_check_node_status, go_check_element_type, go_voltage, go_current, go_resistor;
	wire go_get_self_data, go_get_other_data, go_compute_1, go_compute_2, go_compute_3, go_compute_4, go_get_next_element;
		
	wire data_reset_done, matrix_initialized, loop_done, node_chosen, status_checked, node_valid, type_checked, self_data_got, other_data_got;
	wire is_voltage, is_current, is_resistor, voltage_done, current_done, resistor_done;
	wire compute_1_done, compute_2_done, compute_3_done, compute_4_done, next_element_got, end_of_list;
	
	wire [31:0] adder_data_a, adder_data_b, adder_out;
	wire [31:0] subtractor_data_a, subtractor_data_b, subtractor_out;
	wire [31:0] multiplier_data_a, multiplier_data_b, multiplier_out;
	
	generateEquations_controller Ctrl_6(
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
		.matrix_initialized(matrix_initialized),
		.loop_done(loop_done),
		.node_chosen(node_chosen),
		.node_valid(node_valid),
		.status_checked(status_checked),
		.type_checked(type_checked),
		.self_data_got(self_data_got),
		.other_data_got(other_data_got),
		.is_voltage(is_voltage),
		.is_current(is_current),
		.is_resistor(is_resistor),
		.voltage_done(voltage_done),
		.current_done(current_done),
		.resistor_done(resistor_done),
		.compute_1_done(compute_1_done),
		.compute_2_done(compute_2_done),
		.compute_3_done(compute_3_done),
		.compute_4_done(compute_4_done),
		.next_element_got(next_element_got),
		.end_of_list(end_of_list),
		
		
		// output handshakes
		.go_reset_data(go_reset_data),
		.go_initialize_matrix(go_initialize_matrix),
		.go_choose_node(go_choose_node),
		.go_check_node_status(go_check_node_status),
		.go_check_element_type(go_check_element_type),
		.go_voltage(go_voltage),
		.go_current(go_current),
		.go_resistor(go_resistor),
		.go_get_self_data(go_get_self_data),
		.go_get_other_data(go_get_other_data),
		.go_compute_1(go_compute_1),
		.go_compute_2(go_compute_2),
		.go_compute_3(go_compute_3),
		.go_compute_4(go_compute_4),
		.go_get_next_element(go_get_next_element)
		
	);
	
	
	generateEquations_datapath Data_6(
		// FPGA inputs
		.clk(clk),
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_initialize_matrix(go_initialize_matrix),
		.go_choose_node(go_choose_node),
		.go_check_node_status(go_check_node_status),
		.go_check_element_type(go_check_element_type),
		.go_voltage(go_voltage),
		.go_current(go_current),
		.go_resistor(go_resistor),
		.go_get_self_data(go_get_self_data),
		.go_get_other_data(go_get_other_data),
		.go_compute_1(go_compute_1),
		.go_compute_2(go_compute_2),
		.go_compute_3(go_compute_3),
		.go_compute_4(go_compute_4),
		.go_get_next_element(go_get_next_element),
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.matrix_initialized(matrix_initialized),
		.loop_done(loop_done),
		.node_chosen(node_chosen),
		.node_valid(node_valid),
		.status_checked(status_checked),
		.type_checked(type_checked),
		.self_data_got(self_data_got),
		.other_data_got(other_data_got),
		.is_voltage(is_voltage),
		.is_current(is_current),
		.is_resistor(is_resistor),
		.voltage_done(voltage_done),
		.current_done(current_done),
		.resistor_done(resistor_done),
		.compute_1_done(compute_1_done),
		.compute_2_done(compute_2_done),
		.compute_3_done(compute_3_done),
		.compute_4_done(compute_4_done),
		.next_element_got(next_element_got),
		.end_of_list(end_of_list),
	
		// nodeHeads RAM
		.nodeHeads_addr(nodeHeads_addr),
		.nodeHeads_wren(nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// nodeToElement RAM
		.nodeToElement_addr(nodeToElement_addr),
		.nodeToElement_wren(nodeToElement_wren),
		.nodeToElement_out(nodeToElement_out),
		
		// float_matrix RAM
		.matrix_addr_a(matrix_addr_a),
		.matrix_addr_b(matrix_addr_b),
		.matrix_data_a(matrix_data_a),
		.matrix_data_b(matrix_data_b),
		.matrix_wren_a(matrix_wren_a),
		.matrix_wren_b(matrix_wren_b),
		.matrix_out_a(matrix_out_a),
		.matrix_out_b(matrix_out_b),
		
		// adder
		.adder_data_a(adder_data_a),
		.adder_data_b(adder_data_b),
		.adder_out(adder_out),
		
		// subtractor
		.subtractor_data_a(subtractor_data_a),
		.subtractor_data_b(subtractor_data_b),
		.subtractor_out(subtractor_out),
		
		// multiplier
		.multiplier_data_a(multiplier_data_a),
		.multiplier_data_b(multiplier_data_b),
		.multiplier_out(multiplier_out),
		
		// Misc
		.numElements(numElements),
		.numNodes(numNodes),
		.ground_node(ground_node),
		.numRefNodes(numRefNodes)
		
	);
	
	adder Stage6_add(
		.clock(clk),
		.dataa(adder_data_a),
		.datab(adder_data_b),
		.result(adder_out)
	);
	
	subtractor Stage6_subtract(
		.clock(clk),
		.dataa(subtractor_data_a),
		.datab(subtractor_data_b),
		.result(subtractor_out)
	);
	
	multiplier Stage6_multiply(
		.clock(clk),
		.dataa(multiplier_data_a),
		.datab(multiplier_data_b),
		.result(multiplier_out)
	);
	
	
endmodule

	
