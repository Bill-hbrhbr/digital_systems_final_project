`timescale 1ns/1ns

module configureCircuit_datapath(
		/*
		output [4:0] nodeA, nodeB,
		output reg [8:0] nodeA_pos, nodeB_pos,
		output [8:0] top_node_pos, bot_node_pos, top_bot_diff,
		output [9:0] centerX,
		output [8:0] centerY,
		output [9:0] element_left_pos,
		output [8:0] element_top_pos,
		*/
		
		// FPGA inputs
		input clk,

		// Input handshakes
		input go_reset_data, go_clear_signals, write_dashed_node_line, go_choose_element, go_get_element_info, 
		input go_search_node_A, go_search_node_B, go_write_element_wire, go_write_element_sprite, go_write_top_node, go_write_bot_node, 
		
		// Output hanshakes
		output reg data_reset_done, signals_cleared, dashed_node_line_written, element_chosen, element_info_obtained, all_elements_written,
		output reg node_A_found, node_B_found, element_wire_written, element_sprite_written, top_node_written, bot_node_written,
		
		// RAM: nodeSeq 32x5
		output reg [4:0] nodeSeq_addr,
		output nodeSeq_wren,
		input [4:0] nodeSeq_out,
		
		// RAM: elementSeq 32x5
		output reg [4:0] elementSeq_addr,
		output elementSeq_wren,
		input [4:0] elementSeq_out,
		
		// RAM: processor 1024x48
		output reg [9:0] processor_addr,
		output reg [47:0] processor_data,
		output reg processor_wren,
		input [47:0] processor_out,
		
		// RAM: element 32x32
		output reg [4:0] element_addr,
		output element_wren,
		input [31:0] element_out,
		
		// Misc
		input [4:0] numNodes,
		input [4:0] numElements,
		input [9:0] block_width,
		input [53:0] node_vga_pos,
		output reg [9:0] numCommands

	);
	reg [1:0] ram_delay;
	reg [4:0] dashed_counter;
	//reg [4:0] element_seq_counter;
	
	assign nodeSeq_wren = 0;
	assign elementSeq_wren = 0;
	assign element_wren = 0;
	
	wire [1:0] element_type;
	assign element_type = element_out[21:20];
	
	wire [4:0] nodeA_index;
	wire [4:0] nodeB_index;
	
	assign nodeA_index = element_out[31:27];
	assign nodeB_index = element_out[26:22];
	reg [4:0] nodeA_pos;
	reg [4:0] nodeB_pos;
	reg [8:0] nodeA_vga_pos;
	reg [8:0] nodeB_vga_pos;
	
	always @(*) begin
		case (nodeA_pos)
			5: nodeA_vga_pos = node_vga_pos[8:0];
			4: nodeA_vga_pos = node_vga_pos[17:9];
			3: nodeA_vga_pos = node_vga_pos[26:18];
			2: nodeA_vga_pos = node_vga_pos[35:27];
			1: nodeA_vga_pos = node_vga_pos[44:36];
			0: nodeA_vga_pos = node_vga_pos[53:45];
			default: nodeA_vga_pos = {8{1'b0}};
		endcase
		
		case (nodeB_pos)
			5: nodeB_vga_pos = node_vga_pos[8:0];
			4: nodeB_vga_pos = node_vga_pos[17:9];
			3: nodeB_vga_pos = node_vga_pos[26:18];
			2: nodeB_vga_pos = node_vga_pos[35:27];
			1: nodeB_vga_pos = node_vga_pos[44:36];
			0: nodeB_vga_pos = node_vga_pos[53:45];
			default: nodeB_vga_pos = {8{1'b1}};
		endcase
	end
	
	// name: draw_processor
	// Handle: filled node lines, dashed node lines, straight wires, vSprite, cSprite, rSprite, dot, 
	// mouse normal sprite, mouse select sprite, mouser grab sprite, digits, decimal point, 'E', `V`, `A`, `ohm`
	// 47-bit, 1024 words
	// bit [47]: 1-do this command; 0-skip this command
	// bit [46:38]: 9 bits total, the type of stuff being drawed
	// bit [37:29]: 9 bits total, height of the shape
	// bit [28:19]: 10 bits total, width of the shape
	// bit [18:10]: 9 bits total, topmost position
	// bit [9:0]: 10 bits total, leftmost position
	
	
	wire [8:0] top_node_pos, bot_node_pos;
	assign top_node_pos = (nodeA_pos > nodeB_pos) ? nodeA_vga_pos : nodeB_vga_pos;
	assign bot_node_pos = (nodeA_pos > nodeB_pos) ? nodeB_vga_pos : nodeA_vga_pos;
	
	wire [8:0] top_bot_diff;
	assign top_bot_diff = bot_node_pos - top_node_pos;
	
	wire [9:0] centerX;
	wire [8:0] centerY;
	wire [9:0] element_left_pos;
	wire [8:0] element_top_pos;
	
	assign centerX = elementSeq_addr * block_width + (block_width >> 1);
	assign centerY = (top_node_pos >> 1) + (bot_node_pos >> 1); // Separate because of overflow
	assign element_left_pos = centerX - 21;
	assign element_top_pos = centerY - 46;

	// Top left position for the node dot sprite
	wire [8:0] top_dot_top, bot_dot_top;
	wire [9:0] dot_left;
	
	assign top_dot_top = top_node_pos - 4;
	assign bot_dot_top = bot_node_pos - 4;
	assign dot_left = centerX - 2;
	
	
	always @(posedge clk) begin: datapath
	
		if (go_reset_data) begin
			numCommands = 0;
			
			// Search for Noda A/B's position
			nodeA_pos = 0;
			nodeB_pos = 0;
			node_A_found = 0;
			node_B_found = 0;
			
			
			// RAM: nodeSeq 32x5
			nodeSeq_addr = 0;
		
			// RAM: elementSeq 32x5
			elementSeq_addr = 5'b11111;
			
			// RAMs
			processor_addr = 0;
			processor_data = 0;
			processor_wren = 0;
		
			element_addr = 0;
			
			// Counters
			//element_seq_counter = 5'b11111;
			dashed_counter = 0;
			ram_delay = 0;
			
			// handshakes
			dashed_node_line_written = 0;
			element_chosen = 0;
			element_info_obtained = 0;
			element_wire_written = 0;
			element_sprite_written = 0;
			top_node_written = 0;
			bot_node_written = 0;
			all_elements_written = 0;

			signals_cleared = 0;
			data_reset_done = 1;
		end
		
		else begin
			data_reset_done = 0;
		end
		
		if (~dashed_node_line_written & write_dashed_node_line) begin
			signals_cleared = 0;
			
			processor_addr = numCommands;
			processor_wren = 1;
			processor_data = {1'b1, 9'd0, 9'd2, 10'd620, 9'd0, 10'd10}; // 00000-dashed node lines
			case (dashed_counter)
				0: processor_data[18:10] = node_vga_pos[53:45];
				1: processor_data[18:10] = node_vga_pos[44:36];
				2: processor_data[18:10] = node_vga_pos[35:27];
				3: processor_data[18:10] = node_vga_pos[26:18];
				4: processor_data[18:10] = node_vga_pos[17:9];
				5: processor_data[18:10] = node_vga_pos[8:0];
				default: processor_data[18:10] = 0;
			endcase
			
			
			dashed_counter = dashed_counter + 1;
			if (dashed_counter == numNodes) begin
				dashed_counter = 0;
				dashed_node_line_written = 1;
			end
			
			numCommands = numCommands + 1;
		end
		
		if (~all_elements_written & ~element_chosen & go_choose_element) begin
			bot_node_written = 0;
			
			elementSeq_addr = elementSeq_addr + 1;
			
			if (elementSeq_addr == numElements)
				all_elements_written = 1;
			else
				element_chosen = 1;
		end
		
		if (~element_info_obtained & go_get_element_info) begin
			element_chosen = 0;
			
			ram_delay = ram_delay + 1;
			if (!ram_delay) begin
				element_addr = elementSeq_out;
				element_info_obtained = 1;
				
				nodeSeq_addr = 0;
				ram_delay = 2'b10;
			end
		end
		
		if (~node_A_found & go_search_node_A) begin
			element_info_obtained = 0;
			
			ram_delay = ram_delay - 1;
			if (!ram_delay) begin
				if (nodeSeq_out == nodeA_index) begin
					nodeA_pos = nodeSeq_addr;
					node_A_found = 1;
					
					nodeSeq_addr = 0;
					ram_delay = 2'b10;
				end
			end
			else if (&ram_delay) begin
				nodeSeq_addr = nodeSeq_addr + 1;
			end
		end
		
		if (~node_B_found & go_search_node_B) begin
			node_A_found = 0;
			
			ram_delay = ram_delay - 1;
			if (!ram_delay) begin
				if (nodeSeq_out == nodeB_index) begin
					nodeB_pos = nodeSeq_addr;
					node_B_found = 1;
				end
			end
			else if (&ram_delay) begin
				nodeSeq_addr = nodeSeq_addr + 1;
			end
		end
		
		
		if (~element_wire_written & go_write_element_wire) begin
			node_B_found = 0;
			ram_delay = ram_delay + 1;
			if (!ram_delay) begin
				processor_addr = numCommands;
				processor_wren = 1;
				processor_data = {1'b1, 9'd1, top_bot_diff, 10'd2, top_node_pos, centerX};
			
				element_wire_written = 1;
				numCommands = numCommands + 1;
			end
		end
		
		
		if (~element_sprite_written & go_write_element_sprite) begin
			element_wire_written = 0;
			
			processor_addr = numCommands;
			processor_wren = 1;
			processor_data = {1'b1, 9'd0, 9'd93, 10'd44, element_top_pos, element_left_pos};
			case (element_type)
				0: processor_data[46:38] = 9'd2;
				1: processor_data[46:38] = 9'd3;
				2: processor_data[46:38] = 9'd4;
				default: processor_data[46:38] = 9'd4;
			endcase
			
			element_sprite_written = 1;
			numCommands = numCommands + 1;
		end
		
		if (~top_node_written & go_write_top_node) begin
			element_sprite_written = 0;
			
			processor_addr = numCommands;
			processor_wren = 1;
			
			//processor_data = {1'b1, 9'd5, 9'd10, 10'd6, top_node_pos - 4, centerX - 2};
			processor_data = {1'b1, 9'd5, 9'd10, 10'd6, top_dot_top, dot_left};
			
			top_node_written = 1;
			numCommands = numCommands + 1;
		end
		
		if (~bot_node_written & go_write_bot_node) begin
			top_node_written = 0;
			
			processor_addr = numCommands;
			processor_wren = 1;
			//processor_data = {1'b1, 9'd5, 9'd10, 10'd6, bot_node_pos - 4, centerX - 2};
			processor_data = {1'b1, 9'd5, 9'd10, 10'd6, bot_dot_top, dot_left};
			
			bot_node_written = 1;
			numCommands = numCommands + 1;
		end
		
		if (~signals_cleared & go_clear_signals) begin
			processor_wren = 0;
			
			dashed_node_line_written = 0;
			element_wire_written = 0;
			element_sprite_written = 0;
			top_node_written = 0;
			bot_node_written = 0;
			all_elements_written = 0;
			
			signals_cleared = 1;
		end
		
		
	end
	
	
endmodule
