module searchSuperNode_datapath(
		// FPGA inputs
		input clk,
		
		// Input handshakes
		input go_reset_data, go_to_next_node, go_check_node_status, go_register_reference_node, go_check_element_type,
		input go_store_element_addr, go_update_voltage_difference, begin_search_new_node, go_to_next_element, go_backtrace_dfs, go_backtrace_curr_search_addr,
		
		// Output hanshakes
		output reg data_reset_done, loop_done, next_node_reached, node_checked, node_valid, reference_node_registered,
		output reg is_voltage, type_checked, current_element_addr_stored, voltage_difference_updated, new_node_search_began,
		output reg next_element_reached, end_of_list_reached, whole_dfs_done, backtrace_done, backtrace_curr_search_addr_done,
		
		// nodeHeads RAM
		output reg [4:0] nodeHeads_addr,
		output reg [63:0] nodeHeads_data,
		output reg nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// nodeToElement RAM
		output [4:0] nodeToElement_addr,
		output reg [63:0] nodeToElement_data,
		output reg nodeToElement_wren,
		input [63:0] nodeToElement_out,
		
		// refNodes RAM
		output reg [4:0] refNodes_addr,
		output reg [4:0] refNodes_data,
		output reg refNodes_wren,
		input [4:0] refNodes_out,
		
		// adder
		output reg [31:0] adder_data_a,
		output reg [31:0] adder_data_b,
		input [31:0] adder_out,
		
		// subtractor
		output reg [31:0] subtractor_data_a,
		output reg [31:0] subtractor_data_b,
		input [31:0] subtractor_out,
		
		// Misc
		input [4:0] numElements,
		input [4:0] numNodes,
		input [4:0] ground_node,
		output [4:0] numRefNodes
		
	);
	
	assign numRefNodes = refNodes_addr + 1;
	
	// The register that stores whether a node has already found its reference node
	reg [31:0] reference_set;
	
	// Countdown timer for add_sub circuits
	reg [3:0] add_sub_cd;
	
	//starting from the ground node, loop over all the possible node addresses for a turn
	reg [4:0] nodeHeads_loop_index;
	
	// The address of the current element in the nodeToElement list
	reg [4:0] curr_search_addr;
	assign nodeToElement_addr = curr_search_addr;	
	
	// The address of the next element in the nodeToElement list
	wire [4:0] next_search_addr;
	assign next_search_addr = nodeToElement_out[62:58];
	
	// The type of the current element
	wire [1:0] element_type;
	assign element_type = nodeToElement_out[33:32];
	
	// Propogation delay control
	reg ram_delay;
	
	
	// A pointer that does a dfs search starting from the reference node
	// Increment/decrement accordingly
	reg [4:0] dfs_index;
	reg [4:0] dfs_addresses [0:4];
	
	// The current voltage difference (in floating point rep.)
	reg [31:0] volt_diff [0:31];
	
	integer i;
	initial begin
		for (i = 0; i < 5; i = i + 1) begin
			dfs_addresses[i] = 0;
		end
		
		for (i = 0; i < 32; i = i + 1) begin
			volt_diff[i] = 0;
		end
	end
	
	
	always @(posedge clk) begin: datapath
		
		if (go_reset_data) begin
			loop_done = 0;
			next_node_reached = 0;
			node_checked = 0;
			node_valid = 0;
			reference_node_registered = 0;
			is_voltage = 0;
			type_checked = 0;
			current_element_addr_stored = 0;
			voltage_difference_updated = 0;
			new_node_search_began = 0;
			next_element_reached = 0;
			end_of_list_reached = 0;
			whole_dfs_done = 0;
			backtrace_done = 0;
			backtrace_curr_search_addr_done = 0;
			
			// RAMS
			nodeHeads_addr = 0;
			nodeHeads_data = 0;
			nodeHeads_wren = 0;
		
			//nodeToElement_addr = 0;
			nodeToElement_data = 0;
			nodeToElement_wren = 0;
			
			refNodes_addr = 5'b11111;
			refNodes_data = 0;
			refNodes_wren = 0;
			
			// Helper signals
			reference_set = 0;
			dfs_index = 0;
			add_sub_cd = 0;
			//refNodes_index = 5'b11111;
			nodeHeads_loop_index = ground_node;
			curr_search_addr = 0;
			ram_delay = 0;
			
			data_reset_done = 1;
		end
		else begin
			data_reset_done = 0;
		end
		
		
		if (~loop_done & ~next_node_reached & go_to_next_node) begin
			node_checked = 0;
			whole_dfs_done = 0;
			
			nodeHeads_addr = nodeHeads_loop_index;
			nodeHeads_wren = 0;
			next_node_reached = 1;
			
			nodeHeads_loop_index = nodeHeads_loop_index + 1;
			if (nodeHeads_loop_index == ground_node) begin
				loop_done = 1;
			end
		end
		
		// CHECK_NODE_STATUS
		if (~node_checked & go_check_node_status) begin
			next_node_reached = 0;
			
			ram_delay = ram_delay + 1;
			if (!ram_delay) begin
				// list build & reference hasn't been set
				node_valid = nodeHeads_out[63] & ~reference_set[nodeHeads_addr];
				node_checked = 1;
			end
		end
		
		
		// REGISTER_REF_NODE
		if (~reference_node_registered & go_register_reference_node) begin
			node_checked = 0;
			
			// Store the reference node into the ram
			refNodes_addr = refNodes_addr + 1;
			refNodes_data = nodeHeads_addr;
			refNodes_wren = 1;
			
			// Update the nodeHeads reference node and voltage difference
			nodeHeads_data = nodeHeads_out;
			nodeHeads_data[41:37] = refNodes_addr;  // Eqn index
			nodeHeads_data[36:32] = nodeHeads_addr; // Ref node addr
			nodeHeads_data[31:0] = 0; // reference to itself
			nodeHeads_wren = 1;
			
			// Start building the dfs search base
			dfs_index = 0;
			dfs_addresses[dfs_index] = nodeHeads_addr;
			volt_diff[nodeHeads_addr] = 0;
			reference_set[nodeHeads_addr] = 1;
			
			// Starts searching from this reference node
			curr_search_addr = nodeHeads_out[46:42];  // addr of the first element in the list
			reference_node_registered = 1;
		end
		
		// CHECK_ELEMENT_TYPE
		if (~type_checked & go_check_element_type) begin
			reference_node_registered = 0;
			new_node_search_began = 0;
			next_element_reached = 0;
			
			refNodes_wren = 0;
			nodeHeads_wren = 0;
			
			ram_delay = ram_delay + 1;
			if (!ram_delay) begin
				// Doesn't go to a node that has already been set a reference
				is_voltage = !element_type & ~reference_set[nodeToElement_out[43:39]];
				type_checked = 1;
			end
		end
		
		// Store the old address
		if (~current_element_addr_stored & go_store_element_addr) begin
			type_checked = 0;
			
			nodeHeads_data = nodeHeads_out;
			nodeHeads_data[51:47] = curr_search_addr;
			nodeHeads_wren = 1;
			
			current_element_addr_stored = 1;
		end
		
		// Update the voltage
		if (~voltage_difference_updated & go_update_voltage_difference) begin
			current_element_addr_stored = 0;
			
			nodeHeads_addr = nodeToElement_out[43:39];  // Addr of the other node
			nodeHeads_wren = 0;
			
			adder_data_a = volt_diff[nodeToElement_out[38:34]];  // Volt diff of the current node
			adder_data_b = nodeToElement_out[31:0]; // The element value
			
			subtractor_data_a = volt_diff[nodeToElement_out[38:34]];
			subtractor_data_b = nodeToElement_out[31:0];
			
			volt_diff[nodeToElement_out[43:39]] = nodeToElement_out[44] ? subtractor_out : adder_out;
			
			add_sub_cd = add_sub_cd + 1;
			// Update the other node
			if (!add_sub_cd) begin
				nodeHeads_data = nodeHeads_out;
				nodeHeads_data[41:37] = refNodes_addr;  // Eqn index
				nodeHeads_data[36:32] = refNodes_out;   // ref node addr
				nodeHeads_data[31:0] = volt_diff[nodeToElement_out[43:39]];
				nodeHeads_wren = 1;
				
				reference_set[nodeHeads_addr] = 1; // Set the new address to the already processed state
				// Add the new node to the stack
				dfs_index = dfs_index + 1;
				dfs_addresses[dfs_index] = nodeHeads_addr;
				voltage_difference_updated = 1;
			end
		end
		
		
		// SWITCH_NODE
		// switch to the other node if the connection is a voltage source
		if (~new_node_search_began & begin_search_new_node) begin
			voltage_difference_updated = 0;
			nodeHeads_wren = 0;
			
			curr_search_addr = nodeHeads_out[46:42];
			new_node_search_began = 1;
		end
		
		if (~end_of_list_reached & ~next_element_reached & go_to_next_element) begin
			type_checked = 0;
			backtrace_curr_search_addr_done = 0;
			ram_delay = ram_delay + 1;
			
			if (!ram_delay) begin
				if (nodeToElement_out[63]) begin
					end_of_list_reached = 1;
				end
				else begin
					curr_search_addr = next_search_addr;
					next_element_reached = 1;
				end
			end
		end
		
		if (~whole_dfs_done & ~backtrace_done & go_backtrace_dfs) begin
			end_of_list_reached = 0;
			
			if (!dfs_index) begin
				whole_dfs_done = 1;
			end
			
			else begin
				dfs_index = dfs_index - 1;
				nodeHeads_addr = dfs_addresses[dfs_index];
				nodeHeads_wren = 0;
				backtrace_done = 1;
			end
		end
		
		if (~backtrace_curr_search_addr_done & go_backtrace_curr_search_addr) begin
			backtrace_done = 0;
			ram_delay = ram_delay + 1;
			if (!ram_delay) begin
				curr_search_addr = nodeHeads_out[51:47];
				backtrace_curr_search_addr_done = 1;
			end
		end
		
		
	end
	
endmodule
