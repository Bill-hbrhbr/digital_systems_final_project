`timescale 1ns/1ns

module buildNodeList_main(
		output [3:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// element RAM
		output [4:0] element_addr,
		output element_wren,
		input [31:0] element_out,
		
		// float_register RAM
		output [4:0] float_register_addr,
		output float_register_wren,
		input [31:0] float_register_out,
		
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
		
		input [4:0] numElements,
		output [4:0] numNodes
	);
	

	wire data_reset_done, ram_reset_done, element_chosen, node_chosen, is_node_A, list_checked, list_exists;
	wire new_list_created, old_entry_read, old_entry_updated, new_entry_updated, memory_loaded, all_builded;
	
	wire go_reset_data, go_reset_ram, go_choose_element, build_node_A, build_node_B, check_list_exist;
	wire create_new_list, read_old_entry, update_old_entry, update_new_entry, ld_memory;
	
	buildNodeList_controller Ctrl_3(
		.current_state(cs),
		.next_state(ns),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(program_reset),  // ~KEY[0]
		
		// Initial and Final
		.start_process(start_process),
		.end_process(end_process),
		
		// Input handshakes
		.data_reset_done(data_reset_done),
		.ram_reset_done(ram_reset_done),
		.element_chosen(element_chosen),
		.node_chosen(node_chosen),
		.is_node_A(is_node_A),
		.list_checked(list_checked),
		.list_exists(list_exists),
		.new_list_created(new_list_created),
		.old_entry_read(old_entry_read),
		.old_entry_updated(old_entry_updated),
		.new_entry_updated(new_entry_updated),
		.memory_loaded(memory_loaded),
		.all_builded(all_builded),
		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_reset_ram(go_reset_ram),
		.go_choose_element(go_choose_element),
		.build_node_A(build_node_A),
		.build_node_B(build_node_B),
		.check_list_exist(check_list_exist),
		.create_new_list(create_new_list),
		.read_old_entry(read_old_entry),
		.update_old_entry(update_old_entry),
		.update_new_entry(update_new_entry),
		.ld_memory(ld_memory)
		
	);
	
	buildNodeList_datapath Data_3(
		// FPGA inputs
		.clk(clk),
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_reset_ram(go_reset_ram),
		.go_choose_element(go_choose_element),
		.build_node_A(build_node_A),
		.build_node_B(build_node_B),
		.check_list_exist(check_list_exist),
		.create_new_list(create_new_list),
		.read_old_entry(read_old_entry),
		.update_old_entry(update_old_entry),
		.update_new_entry(update_new_entry),
		.ld_memory(ld_memory),
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.ram_reset_done(ram_reset_done),
		.element_chosen(element_chosen),
		.node_chosen(node_chosen),
		.is_node_A(is_node_A),
		.list_checked(list_checked),
		.list_exists(list_exists),
		.new_list_created(new_list_created),
		.old_entry_read(old_entry_read),
		.old_entry_updated(old_entry_updated),
		.new_entry_updated(new_entry_updated),
		.memory_loaded(memory_loaded),
		.all_builded(all_builded),
		
		// element RAM
		.element_addr(element_addr),
		.element_wren(element_wren),
		.element_out(element_out),
		
		// float_register RAM
		.float_register_addr(float_register_addr),
		.float_register_wren(float_register_wren),
		.float_register_out(float_register_out),
		
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
		
		.numElements(numElements),
		.numNodes(numNodes)
		
	);
	
endmodule
