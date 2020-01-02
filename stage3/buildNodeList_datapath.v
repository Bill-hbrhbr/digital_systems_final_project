`timescale 1ns/1ns

module buildNodeList_datapath(
		// FPGA inputs
		input clk,
		
		// Input handshakes
		input go_reset_data, go_reset_ram, go_choose_element, build_node_A, build_node_B, check_list_exist, 
		input create_new_list, read_old_entry, update_old_entry, update_new_entry, ld_memory,
		
		// Output hanshakes
		output reg data_reset_done = 0, ram_reset_done, element_chosen, node_chosen, is_node_A, list_checked, list_exists,
		output reg new_list_created, old_entry_read, old_entry_updated, new_entry_updated, memory_loaded, all_builded,
		
		// element RAM
		output reg [4:0] element_addr,
		output element_wren,
		input [31:0] element_out,
		
		// float_register RAM
		output [4:0] float_register_addr,
		output float_register_wren,
		input [31:0] float_register_out,
		
		// nodeHeads RAM
		output reg [4:0] nodeHeads_addr,
		output reg [63:0] nodeHeads_data,
		output reg nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// nodeToElement RAM
		output reg [4:0] nodeToElement_addr,
		output reg [63:0] nodeToElement_data,
		output reg nodeToElement_wren,
		input [63:0] nodeToElement_out,
		
		input [4:0] numElements,
		output reg [4:0] numNodes
		
	);
	
	assign element_wren = 0;
	assign float_register_addr = element_addr;
	assign float_register_wren = 0;
	
	wire [4:0] node_A_addr, node_B_addr;
	wire [4:0] other_node_addr;
	wire [4:0] old_entry_addr;
	reg [4:0] new_entry_addr;
	wire [1:0] element_type;
	
	assign node_A_addr = element_out[31:27];
	assign node_B_addr = element_out[26:22];
	assign other_node_addr = is_node_A ? node_B_addr : node_A_addr;
	
	assign old_entry_addr = nodeHeads_out[51:47];
	assign element_type = element_out[21:20];
	
	// name: element
	// 32-bit wide, 32 words (max 32 elements)
	// bit [31:27]: node A number
	// bit [26:22]: node B number
	/* bit [21:20]: element type
		00 - independent voltage source
		01 - independent current source
		10 - resistor
		11 - undefined
	*/
	// bit [19:10]: element exponent
	// bit [9:0]: element value
	/******************************************/
	// name: nodeHeads
	// 64-bit wide, 32 words
	// bit [63]: 0-not builded, 1-builded
	// bit [62]: 0-ref node not set, 1-ref node set
	
	// bit [61:52]: unused
	
	// bit [51:47]: current `nodeToElement` address for searching/traversing
	// bit [46:42]: address of the first connected element in  `nodeToElement`
	// bit [41:37]: index of the corresponding node row in the system of linear equations
	// bit [36:32]: address of the reference node in `nodeHeads`
	
	/* bit [31:0]: voltage value difference with respect to the ref node
			value is in floating-point format
			value is 0 if the ref node is itself
			value of the current node - value of the 
	*/
	/******************************************/
	// name: nodeToElement
	// 64-bit wide, 32 words
	// bit [63]: 0-is not end of the list; 1-is the end of the list
	// bit [62:58]: address of the next element
	
	// bit [57:45]: unused
	
	// bit [44]: the current node is the node 0-A/1-B of this element 
	// bit [43:39]: address of the other node of the element
	// bit [38:34]: address of the current node
	/* bit [33:32]: element type
		00 - independent voltage source
		01 - independent current source
		10 - resistor
		11 - undefined
	*/ 
	// bit [31:0]: element value in floating point
	
	reg ram_delay;
	
	always @(posedge clk) begin: datapath
		
		if (go_reset_data) begin
			ram_reset_done = 0;
			element_chosen = 0;
			node_chosen = 0;
			is_node_A = 0;
			list_checked = 0;
			list_exists = 0;
			new_list_created = 0;
			old_entry_read = 0;
			old_entry_updated = 0;
			new_entry_updated = 0;
			memory_loaded = 0;
			all_builded = 0;
			
			
			element_addr = 5'b11111;
			new_entry_addr = 5'b11111;
			
			
			nodeHeads_addr = 0;
			nodeHeads_data = 0;
			nodeHeads_wren = 0;
		
			nodeToElement_addr = 0;
			nodeToElement_data = 0;
			nodeToElement_wren = 0;
			
			numNodes = 0;
			ram_delay = 0;
			data_reset_done = 1;
		end
		
		else begin
			data_reset_done = 0;
		end
		
		if (~ram_reset_done & go_reset_ram) begin
			nodeHeads_data = 0;
			nodeHeads_wren = 1;
			nodeHeads_addr = nodeHeads_addr + 1;
			if (!nodeHeads_addr) begin
				ram_reset_done = 1;
			end
		end
		
		if (~all_builded & ~element_chosen & go_choose_element) begin
			memory_loaded = 0;
			ram_reset_done = 0;
			nodeHeads_wren = 0;
			
			element_addr = element_addr + 1;
			
			if (element_addr == numElements)
				all_builded = 1;
			else
				element_chosen = 1;
		
		end
		
		if (~node_chosen & build_node_A) begin
			element_chosen = 0;
			
			is_node_A = 1;
			nodeHeads_addr = node_A_addr;
			nodeHeads_wren = 0;
			node_chosen = 1;
		end
		
		if (~node_chosen & build_node_B) begin
			memory_loaded = 0;
			
			is_node_A = 0;
			nodeHeads_addr = node_B_addr;
			nodeHeads_wren = 0;
			node_chosen = 1;
		end
		
		if (~list_checked & check_list_exist) begin
			node_chosen = 0;
			ram_delay = ram_delay + 1;
			if (~ram_delay) begin
				new_entry_addr = new_entry_addr + 1;
				list_exists = nodeHeads_out[63];
				list_checked = 1;
			end
		end
		
		if (~new_list_created & create_new_list) begin
			list_checked = 0;
			
			ram_delay = ram_delay + 1;
			if (~ram_delay) begin
				numNodes = numNodes + 1;
			
				nodeToElement_addr = new_entry_addr;
				nodeToElement_data = {1'b1, {18{1'b0}}, is_node_A, other_node_addr, nodeHeads_addr, element_type, float_register_out};
				nodeToElement_wren = 1;
			
				nodeHeads_data = {1'b1, {11{1'b0}}, nodeToElement_addr, nodeToElement_addr, {42{1'b0}}};
				nodeHeads_wren = 1;
			
				new_list_created = 1;
			end
		end
		
		if (~old_entry_read & read_old_entry) begin
			list_checked = 0;
			
			ram_delay = ram_delay + 1;
			if (!ram_delay) begin
				nodeToElement_addr = old_entry_addr;
				nodeToElement_wren = 0;
			
				old_entry_read = 1;
			end
		end
		
		if (~old_entry_updated & update_old_entry) begin
			old_entry_read = 0;
			
			ram_delay = ram_delay + 1;
			
			if (~ram_delay) begin
				nodeHeads_data = nodeHeads_out;
				nodeHeads_data[51:47] = new_entry_addr;
				nodeHeads_wren = 1;
			
				nodeToElement_data = {1'b0, new_entry_addr, nodeToElement_out[57:0]};
				nodeToElement_wren = 1;
			
				old_entry_updated = 1;
			end
		end
		
		if (~new_entry_updated & update_new_entry) begin
			old_entry_updated = 0;
			nodeHeads_wren = 0;
			
			ram_delay = ram_delay + 1;
			if (~ram_delay) begin
				nodeToElement_addr = new_entry_addr;
				nodeToElement_data = {1'b1, {18{1'b0}}, is_node_A, other_node_addr, nodeHeads_addr, element_type, float_register_out};
				nodeToElement_wren = 1;
			
				new_entry_updated = 1;
			end
		end
		
		if (~memory_loaded & ld_memory) begin
			new_list_created = 0;
			new_entry_updated = 0;
			nodeHeads_wren = 0;
			nodeToElement_wren = 0;
			
			memory_loaded = 1;
		end
		
	end
	
	
	
endmodule
	
	
	