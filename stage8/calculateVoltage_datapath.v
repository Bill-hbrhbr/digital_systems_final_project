`timescale 1ns/1ns

module calculateVoltage_datapath(
		// FPGA inputs
		input clk,
		
		// Input handshakes
		input go_reset_data, go_choose_node, go_check_node, go_do_ops, ld_memory,
		
		// Output hanshakes
		output reg data_reset_done, node_chosen, all_done, node_checked, node_valid, ops_done, memory_loaded,
	
		// nodeHeads RAM
		output reg [4:0] nodeHeads_addr,
		output nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// float_matrix RAM
		output [11:0] matrix_addr_a, 
		output matrix_wren_a,
		input [31:0] matrix_out_a,
		
		// nodeVoltage RAM
		output [4:0] nodeVoltage_addr,
		output reg [31:0] nodeVoltage_data,
		output reg nodeVoltage_wren,
		input [31:0] nodeVoltage_out,
		
		// adder
		output [31:0] adder_data_a,
		output [31:0] adder_data_b,
		input [31:0] adder_out,
		
		// multiplier
		output [31:0] multiplier_data_a,
		output [31:0] multiplier_data_b,
		input [31:0] multiplier_out,
		
		// fp_to_int
		output [31:0] fp_to_int_data,
		input [31:0] fp_to_int_out,
		
		// Misc
		input [4:0] numNodes,
		input [4:0] numRefNodes
		
	);
	
	reg [4:0] nodeLoopIndex;
	wire [4:0] numColumns;
	assign numColumns = numRefNodes + 1;
	
	assign adder_data_a = nodeHeads_out[31:0];
	assign adder_data_b = matrix_out_a;
	assign multiplier_data_a = adder_out;
	//assign multiplier_data_b = 32'b01010011011010001101010010100101; // 1e12
	
	
	localparam EXPAND = 32'b01000100011110100000000000000000, // 1e3
	           REDUCE = 32'b00111010100000110001001001101111, // 1e-3
				  IDENTITY = 32'b00111111100000000000000000000000; //1e0
	
	assign multiplier_data_b = EXPAND;
	
	assign fp_to_int_data = multiplier_out;
	
	reg ram_delay;
	reg [5:0] op_cd;
	
	assign nodeHeads_wren = 0;
	assign nodeVoltage_addr = nodeHeads_addr;
	assign matrix_addr_a = (nodeHeads_out[41:37] + 1) * numColumns - 1;
	assign matrix_wren_a = 0;
	
	//wire six, five, four, three;
	
	always @(posedge clk) begin
		if (go_reset_data) begin
			node_chosen = 0;
			all_done = 0;
			node_checked = 0;
			node_valid = 0;
			ops_done = 0;
			memory_loaded = 0;
			
			nodeHeads_addr = 0;
			nodeLoopIndex = 0;
			
			nodeVoltage_data = 0;
			nodeVoltage_wren = 0;
			
			op_cd = 0;
			ram_delay <= 0;
			data_reset_done = 1;
		end
		else begin
			data_reset_done = 0;
		end
		
		if (~all_done & ~node_chosen & go_choose_node) begin
			memory_loaded = 0;
			node_checked = 0;
			
			nodeHeads_addr = nodeLoopIndex;
			nodeLoopIndex = nodeLoopIndex + 1;
			if (!nodeLoopIndex) begin
				all_done = 1;
			end
			
			ram_delay <= 0;
			node_chosen = 1;
			
		end
		
		if (~node_checked & go_check_node) begin
			node_chosen = 0;
			ram_delay <= 1;
			
			if (ram_delay) begin
				node_valid = nodeHeads_out[63];
				ram_delay <= 0;
				node_checked = 1;
			end
			
		end
		
		if (~ops_done & go_do_ops) begin
			node_checked = 0;
			
			op_cd = op_cd + 1;
			if (!op_cd) begin
				nodeVoltage_data = fp_to_int_out;
				nodeVoltage_wren = 1;
				ops_done = 1;
			end
			
		end
		
		if (~memory_loaded & ld_memory) begin
			ops_done = 0;
			nodeVoltage_wren = 0;
			memory_loaded = 1;
		end
	
	end
	
	
	
	
endmodule
