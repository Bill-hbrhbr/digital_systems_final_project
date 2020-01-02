`timescale 1ns/1ns

module sortSequence_datapath(
		// FPGA inputs
		input clk,

		// Input handshakes
		input go_reset_data, go_calculate_width, go_set_element_seq, go_choose_next_node, go_check_node, go_set_node_seq,
		
		// Output hanshakes
		output reg data_reset_done, width_calculated, element_seq_set, node_chosen, all_nodes_set, node_checked, node_valid, node_seq_set,
		
		// RAM: nodeHeads 64x32
		output reg [4:0] nodeHeads_addr,
		output nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// RAM: nodeSeq 5x32
		output reg [4:0] nodeSeq_addr,
		output reg [4:0] nodeSeq_data,
		output reg nodeSeq_wren,
		input [4:0] nodeSeq_out,

		// RAM: elementSeq 5x32
		output reg [4:0] elementSeq_addr,
		output reg [4:0] elementSeq_data,
		output reg elementSeq_wren,
		input [4:0] elementSeq_out,
		
		// Misc
		input [4:0] numNodes,
		input [4:0] numElements,
		output reg [9:0] block_width

	);
	
	localparam screen_width = 10'd600;
	assign nodeHeads_wren = 0;
	reg [9:0] width_counter;
	reg ram_delay;
	
	always @(posedge clk) begin: datapath
		if (go_reset_data) begin
			width_calculated = 0;
			element_seq_set = 0;
			node_chosen = 0;
			all_nodes_set = 0;
			node_checked = 0;
			node_valid = 0;
			node_seq_set = 0;
			
			
			block_width = 0;
			width_counter = 0;
			
			nodeHeads_addr = 5'b11111;
			
			nodeSeq_addr = 5'b11111;
			nodeSeq_data = 0;
			nodeSeq_wren = 0;
			
			elementSeq_addr = 5'b11111;
			elementSeq_data = 0;
			elementSeq_wren = 0;
			
			ram_delay = 0;
			data_reset_done = 1;
		end
		else begin
			data_reset_done = 0;
		end
		
		if (~width_calculated & go_calculate_width) begin
			block_width = block_width + 1;
			width_counter = width_counter + numElements;
			if (width_counter > screen_width) begin
				width_calculated = 1;
			end
		end
		
		if (~element_seq_set & go_set_element_seq) begin
			width_calculated = 0;
			
			elementSeq_addr = elementSeq_addr + 1;
			elementSeq_data = elementSeq_addr;
			elementSeq_wren = 1;
			if (elementSeq_addr == numElements) begin
				elementSeq_wren = 0;
				element_seq_set = 1;
			end
		end
		
		if (~all_nodes_set & ~node_chosen & go_choose_next_node) begin
			element_seq_set = 0;
			node_checked = 0;
			
			node_seq_set = 0;
			nodeSeq_wren = 0;
			
			nodeHeads_addr = nodeHeads_addr + 1;
			if (&nodeHeads_addr) begin
				all_nodes_set = 1;
			end
			node_chosen = 1;
		end
		
		if (~node_checked & go_check_node) begin
			node_chosen = 0;
			
			ram_delay = ram_delay + 1;
			if (!ram_delay) begin
				node_valid = nodeHeads_out[63];
				node_checked = 1;
			end
		end
		
		if (~node_seq_set & go_set_node_seq) begin
			node_checked = 0;
			
			nodeSeq_addr = nodeSeq_addr + 1;
			nodeSeq_wren = 1;
			nodeSeq_data = nodeHeads_addr;

			node_seq_set = 1;
		end
		
	end
	
	
endmodule
