`timescale 1ns/1ns
	
module calculateVoltage_main(		
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
		
		// RAM: float_matrix 4096x32
		output [11:0] matrix_addr_a,
		output matrix_wren_a,
		input [31:0] matrix_out_a,
		
		// RAM: nodeVoltage 32x32
		output [4:0] nodeVoltage_addr,
		output [31:0] nodeVoltage_data,
		output nodeVoltage_wren,
		input [31:0] nodeVoltage_out,
		
		// Misc
		input [4:0] numNodes,
		input [4:0] numRefNodes
	);
	
	wire go_reset_data, go_choose_node, go_check_node, go_do_ops, ld_memory;
	wire data_reset_done, node_chosen, all_done, node_checked, node_valid, ops_done, memory_loaded;
	
	wire [31:0] fp_to_int_data, fp_to_int_out, multiplier_data_a, multiplier_data_b, multiplier_out;
	wire [31:0] adder_data_a, adder_data_b, adder_out;
	
	calculateVoltage_controller Ctrl_8(
		.current_state(cs),
		.next_state(ns),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(program_reset),  // ~KEY[0]
		
		// Initial and Final
		.start_process(start_process),
		.end_process(end_process),
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.node_chosen(node_chosen),
		.all_done(all_done),
		.node_checked(node_checked),
		.node_valid(node_valid),
		.ops_done(ops_done),
		.memory_loaded(memory_loaded),
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_choose_node(go_choose_node),
		.go_check_node(go_check_node),
		.go_do_ops(go_do_ops),
		.ld_memory(ld_memory)
		
	);
	
	
	calculateVoltage_datapath Data_8(
		// FPGA inputs
		.clk(clk),
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_choose_node(go_choose_node),
		.go_check_node(go_check_node),
		.go_do_ops(go_do_ops),
		.ld_memory(ld_memory),
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.node_chosen(node_chosen),
		.all_done(all_done),
		.node_checked(node_checked),
		.node_valid(node_valid),
		.ops_done(ops_done),
		.memory_loaded(memory_loaded),
	
		// nodeHeads RAM
		.nodeHeads_addr(nodeHeads_addr),
		.nodeHeads_wren(nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// float_matrix RAM
		.matrix_addr_a(matrix_addr_a),
		.matrix_wren_a(matrix_wren_a),
		.matrix_out_a(matrix_out_a),
		
		// nodeVoltage RAM
		.nodeVoltage_addr(nodeVoltage_addr),
		.nodeVoltage_data(nodeVoltage_data),
		.nodeVoltage_wren(nodeVoltage_wren),
		.nodeVoltage_out(nodeVoltage_out),
		
		// adder
		.adder_data_a(adder_data_a),
		.adder_data_b(adder_data_b),
		.adder_out(adder_out),
		
		// multiplier
		.multiplier_data_a(multiplier_data_a),
		.multiplier_data_b(multiplier_data_b),
		.multiplier_out(multiplier_out),
		
		// FP to INT converter
		.fp_to_int_data(fp_to_int_data),
		.fp_to_int_out(fp_to_int_out),
		
		.numNodes(numNodes),
		.numRefNodes(numRefNodes)
		
	);
	
	fp_to_int Stage8_convert(
		.clock(clk),
		.dataa(fp_to_int_data),
		.result(fp_to_int_out)
	);
	
	multiplier Stage8_multiply(
		.clock(clk),
		.dataa(multiplier_data_a),
		.datab(multiplier_data_b),
		.result(multiplier_out)
	);
	
	adder Stage8_add(
		.clock(clk),
		.dataa(adder_data_a),
		.datab(adder_data_b),
		.result(adder_out)
	);

endmodule
