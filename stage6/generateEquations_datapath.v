module generateEquations_datapath(
		// FPGA inputs
		input clk,
		
		// Input handshakes
		input go_reset_data, go_initialize_matrix, go_choose_node, go_check_node_status, go_check_element_type, go_voltage, go_current, go_resistor,
		input go_get_self_data, go_get_other_data, go_compute_1, go_compute_2, go_compute_3, go_compute_4, go_get_next_element,
		
		// Output hanshakes
		output reg data_reset_done, matrix_initialized, loop_done, node_chosen, status_checked, node_valid, type_checked, self_data_got, other_data_got,
		output reg is_voltage, is_current, is_resistor, voltage_done, current_done, resistor_done,
		output reg compute_1_done, compute_2_done, compute_3_done, compute_4_done, next_element_got, end_of_list,
	
		// nodeHeads RAM
		output reg [4:0] nodeHeads_addr,
		output nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// nodeToElement RAM
		output [4:0] nodeToElement_addr,
		output nodeToElement_wren,
		input [63:0] nodeToElement_out,
		
		// float_matrix RAM
		output reg [11:0] matrix_addr_a, matrix_addr_b, 
		output reg [31:0] matrix_data_a, matrix_data_b,
		output reg matrix_wren_a, matrix_wren_b,
		input [31:0] matrix_out_a, matrix_out_b,
		
		// adder
		output reg [31:0] adder_data_a,
		output reg [31:0] adder_data_b,
		input [31:0] adder_out,
		
		// subtractor
		output reg [31:0] subtractor_data_a,
		output reg [31:0] subtractor_data_b,
		input [31:0] subtractor_out,
		
		// multiplier
		output reg [31:0] multiplier_data_a,
		output [31:0] multiplier_data_b,
		input [31:0] multiplier_out,
		
		// Misc
		input [4:0] numElements,
		input [4:0] numNodes,
		input [4:0] ground_node,
		input [4:0] numRefNodes
		
	);
	
	assign nodeHeads_wren = 0;
	assign nodeToElement_wren = 0;
	
	// Matrix Dimensions
	wire [4:0] numColumns, numRows;
	assign numColumns = numRefNodes + 1;
	assign numRows = numRefNodes;
	
	// Initialization counters
	reg [4:0] x_counter, y_counter;
	reg [11:0] pos_counter;
	
	// Countdown timer for add_sub circuits
	reg [3:0] add_sub_cd;
	
	// Countdown timer for multiplier circuits
	reg [3:0] multiply_cd;
	
	// The address of the current element in the nodeToElement list
	reg [4:0] curr_search_addr;
	assign nodeToElement_addr = curr_search_addr;	
	
	// The address of the next element in the nodeToElement list
	wire [4:0] next_search_addr;
	assign next_search_addr = nodeToElement_out[62:58];
	
	// The type of the current element
	wire [1:0] element_type;
	assign element_type = nodeToElement_out[33:32];
	
	// The value of the current element
	wire [31:0] element_value;
	assign element_value = nodeToElement_out[31:0];
	assign multiplier_data_b = element_value;
	
	// The voltage difference of the current node
	wire [31:0] volt_diff;
	assign volt_diff = nodeHeads_out[31:0];
	
	reg [31:0] self_volt_diff, other_volt_diff;
	
	// The equation index of the current node
	wire [4:0] eqn_index;
	assign eqn_index = nodeHeads_out[41:37];
	
	reg [4:0] self_eqn_index, other_eqn_index;
	
	// VOLT_DIFF / RESISTANCE
	reg [31:0] self_curr_offset, other_curr_offset;
	
	// Propogation delay control
	reg ram_delay;
	
	always @(posedge clk) begin: datapath
		
		if (go_reset_data) begin
			matrix_initialized = 0;
			node_chosen = 0;
			loop_done = 0;
			status_checked = 0;
			node_valid = 0;
			type_checked = 0;
			self_data_got = 0;
			other_data_got = 0;
			compute_1_done = 0;
			compute_2_done = 0;
			compute_3_done = 0;
			compute_4_done = 0;
			next_element_got = 0;
			end_of_list = 0;
			
			is_voltage = 0;
			is_current = 0;
			is_resistor = 0;
			voltage_done = 0;
			current_done = 0;
			resistor_done = 0;
			
			/******************/
			curr_search_addr = 0;
			self_volt_diff = 0;
			other_volt_diff = 0;
			self_eqn_index = 0;
			other_eqn_index = 0;
			self_curr_offset = 0;
			other_curr_offset = 0;
			
			// RAMS
			nodeHeads_addr = 0;
			
			// Matrix
			matrix_addr_a = 0;
			matrix_addr_b = 0;
			matrix_data_a = 0;
			matrix_data_b = 0;
			matrix_wren_a = 0;
			matrix_wren_b = 0;
			
			// Counter signals
			x_counter = 0;
			y_counter = 0;
			pos_counter = 0;
			add_sub_cd = 0;
			multiply_cd = 0;
			ram_delay <= 0;
			
			data_reset_done = 1;
		end
		else begin
			data_reset_done = 0;
		end
		
		if (~matrix_initialized & go_initialize_matrix) begin
			matrix_addr_a = pos_counter;
			matrix_data_a = pos_counter ? 0 : 32'b00111111100000000000000000000000;
			matrix_wren_a = 1;
			
			if (x_counter == numColumns) begin
				x_counter = 0;
				y_counter = y_counter + 1;
			end
			
			if (y_counter == numRows) begin
				y_counter = 0;
				matrix_wren_a = 0;
				matrix_initialized = 1;
			end
			
			pos_counter = pos_counter + 1;
			x_counter = x_counter + 1;
		end
		
		if (~loop_done & ~node_chosen & go_choose_node) begin
			matrix_initialized = 0;
			x_counter = 0;
			y_counter = 0;
			pos_counter = 0;
			
			status_checked = 0;
			end_of_list = 0;
			
			nodeHeads_addr = nodeHeads_addr + 1;
			node_chosen = 1;
			
			if (!nodeHeads_addr) begin
				loop_done = 1;
			end
				
		end
		
		// CHECK_NODE_STATUS
		if (~status_checked & go_check_node_status) begin
			node_chosen = 0;
			
			ram_delay <= ram_delay + 1;
			if (&ram_delay) begin
				node_valid = nodeHeads_out[63] & (|eqn_index); // Skip all nodes related to the ground node
				curr_search_addr = nodeHeads_out[46:42];
				
				status_checked = 1;
				ram_delay <= 0;
			end
		end
		
		// CHECK_ELEMENT_TYPE
		if (~type_checked & go_check_element_type) begin
			status_checked = 0;
			next_element_got = 0;
			
			ram_delay <= ram_delay + 1;
			if (&ram_delay) begin
				if (element_type == 2'b00) begin
					is_voltage = 1;
				end
					
				else if (element_type == 2'b01) begin
					is_current = 1;
					matrix_addr_a = numColumns * (eqn_index + 1) - 1; // The position of the constant vector
					matrix_wren_a = 0;
				end
				
				else if (element_type == 2'b10) begin
					is_resistor = 1;
				end
				
				type_checked = 1;
				ram_delay <= 0;
			end
		end
		
		if (~voltage_done & go_voltage) begin
			type_checked = 0;
			is_voltage = 0;
			voltage_done = 1;
		end
		
		if (~current_done & go_current) begin
			type_checked = 0;
			is_current = 0;
			ram_delay <= ram_delay + 1;
			
			if (&ram_delay) begin
				adder_data_a = matrix_out_a;
				adder_data_b = element_value;
				subtractor_data_a = matrix_out_a;
				subtractor_data_b = element_value;
			
				add_sub_cd = add_sub_cd + 1;
				if (!add_sub_cd) begin
					matrix_data_a = nodeToElement_out[44] ? adder_out : subtractor_out;
					matrix_wren_a = 1;
					current_done = 1;
					ram_delay <= 0;
				end
			end
			
		end
		
		if (~self_data_got & go_get_self_data) begin
			type_checked = 0;
			is_resistor = 0;
			
			self_volt_diff = volt_diff;
			self_eqn_index = eqn_index;
			
			matrix_addr_a = self_eqn_index * (numColumns + 1); // Self's coefficient position
			matrix_wren_a = 0;
			
			nodeHeads_addr = nodeToElement_out[43:39];
			
			self_data_got = 1;
		end
		
		if (~other_data_got & go_get_other_data) begin
			self_data_got = 0;
			ram_delay <= ram_delay + 1;
			
			if (&ram_delay) begin
				other_volt_diff = volt_diff;
				other_eqn_index = eqn_index;
				
				matrix_addr_b = self_eqn_index * numColumns + other_eqn_index; // The other node's coefficient position
				matrix_wren_b = 0;
				
				nodeHeads_addr = nodeToElement_out[38:34];
				
				other_data_got = 1;
				ram_delay <= 0;
			end
		end
		
		if (~compute_1_done & go_compute_1) begin
			other_data_got = 0;
			ram_delay <= ram_delay + 1;
			
			//pipeline
			multiplier_data_a = self_volt_diff;
			
			if (&ram_delay) begin
				// The results for pure conductance addition
				adder_data_a = matrix_out_a;
				adder_data_b = element_value;
				subtractor_data_a = matrix_out_b;
				subtractor_data_b = element_value;
				
				add_sub_cd = add_sub_cd + 1;
				if (!add_sub_cd) begin
					self_curr_offset = multiplier_out;
					multiplier_data_a = other_volt_diff;
					
					if (matrix_addr_a != matrix_addr_b) begin
						matrix_data_a = adder_out;
						matrix_wren_a = 1;
						matrix_data_b = subtractor_out;
						matrix_wren_b = 1;
					end
					
					ram_delay <= 0;
					compute_1_done = 1;
				end
			end
		
		end
		
		if (~compute_2_done & go_compute_2) begin
			compute_1_done = 0;
			matrix_wren_a = 0;
			matrix_wren_b = 0;
			matrix_addr_a = numColumns * (self_eqn_index + 1) - 1; // The position of the constant vector
			
			multiply_cd = multiply_cd + 1;
			if (!multiply_cd) begin
				other_curr_offset = multiplier_out;
				compute_2_done = 1;
			end
			
		end
		
		if (~compute_3_done & go_compute_3) begin
			compute_2_done = 0;
			subtractor_data_a = matrix_out_a;
			subtractor_data_b = self_curr_offset;
			
			add_sub_cd = add_sub_cd + 1;
			if (!add_sub_cd) begin
				adder_data_a = subtractor_out;
				adder_data_b = other_curr_offset;
				compute_3_done = 1;
			end
		end
		
		if (~compute_4_done & go_compute_4) begin
			compute_3_done = 0;
			add_sub_cd = add_sub_cd + 1;
			if (!add_sub_cd) begin
				matrix_data_a = adder_out;
				matrix_wren_a = 1;
				compute_4_done = 1;
			end
		end
		
		if (~resistor_done & go_resistor) begin
			compute_4_done = 0;
			matrix_wren_a = 0;
			resistor_done = 1;
		end
		
		if (~end_of_list & ~next_element_got & go_get_next_element) begin
			voltage_done = 0;
			current_done = 0;
			resistor_done = 0;
			
			if (nodeToElement_out[63]) begin
				end_of_list = 1;
			end
			
			else begin
				curr_search_addr = next_search_addr;
				next_element_got = 1;
			end
			
		end
		
		
	end
	
endmodule
