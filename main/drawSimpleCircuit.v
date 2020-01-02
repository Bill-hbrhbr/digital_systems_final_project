module drawSimpleCircuit_control(
		
		input clk, start_process, program_resetn,
		input got_width, sprite_chosen, line_drew, wire_drew, sprite_drew, node_A_drew, node_B_drew, drew_all_elements,
		output reg data_reset, calc_width, draw_line, choose_sprite, draw_wire, draw_sprite, draw_node_A, draw_node_B, end_process,
		output reg [3:0] current_state = 4'b0000, next_state
	);
	
	localparam PRE_DRAW = 4'b0000,
				  CALCULATE_WIDTH = 4'b0001,
				  CHOOSE_SPRITE = 4'b0011,
				  DRAW_WIRE = 4'b0100,
		        DRAW_SPRITE = 4'b0101,
				  DRAW_NODE_A = 4'b0110,
				  DRAW_NODE_B = 4'b0111,
				  DRAW_NODE_LINES = 4'b1000,
				  
				  DONE_DRAW = 4'b1111;
				  
	
	always @(*) begin: state_table
		case (current_state)
			PRE_DRAW:
				next_state = start_process ? CALCULATE_WIDTH : PRE_DRAW;
				
			CALCULATE_WIDTH:
				next_state = got_width ? DRAW_NODE_LINES :  CALCULATE_WIDTH;
			
			DRAW_NODE_LINES:
				next_state = line_drew ? CHOOSE_SPRITE : DRAW_NODE_LINES;
			
			CHOOSE_SPRITE: begin
				if (drew_all_elements)
					next_state = DONE_DRAW;
				else
					next_state = sprite_chosen ? DRAW_WIRE : CHOOSE_SPRITE;
			end
			
			DRAW_WIRE:
				next_state = wire_drew ? DRAW_SPRITE : DRAW_WIRE;
				
			DRAW_SPRITE:
				next_state = sprite_drew ? DRAW_NODE_A : DRAW_SPRITE;
			
			DRAW_NODE_A:
				next_state = node_A_drew ? DRAW_NODE_B : DRAW_NODE_A;
				
			DRAW_NODE_B:
				next_state = node_B_drew ? CHOOSE_SPRITE : DRAW_NODE_B;
			
		endcase
	end
	
	
	always @(*) begin: enable_signals
		data_reset = 0;
		calc_width = 0;
		choose_sprite = 0;
		draw_line = 0;
		draw_wire = 0;
		draw_sprite = 0;
		draw_node_A = 0;
		draw_node_B = 0;
		end_process = 0;
		case (current_state)
			PRE_DRAW: data_reset = 1;
			CALCULATE_WIDTH: calc_width = 1;
			DRAW_NODE_LINES: draw_line = 1;
			CHOOSE_SPRITE: choose_sprite = 1;
			DRAW_WIRE: draw_wire = 1;
			DRAW_SPRITE: draw_sprite = 1;
			DRAW_NODE_A: draw_node_A = 1;
			DRAW_NODE_B: draw_node_B = 1;
			
			DONE_DRAW: end_process = 1;
		endcase
	end
	
	always @(posedge clk) begin: state_FFs
		if (!program_resetn)
			current_state <= PRE_DRAW;
		else if (current_state != DONE_DRAW)			
			current_state <= next_state;
	end
endmodule


module drawSimpleCircuit_datapath(
		input clk, data_reset, calc_width, draw_line, choose_sprite, draw_wire, draw_sprite, draw_node_A, draw_node_B,
		input [10:0] screenWidth,
		input [4:0] numElements, numNodes,
		input [23:0] element_data,
		input vSprite_out, cSprite_out, rSprite_out, dot_out,
		
		output reg got_width, line_drew, sprite_chosen, wire_drew, sprite_drew, node_A_drew, node_B_drew, drew_all_elements,
		
		output reg [4:0] element_index,
		
		output [11:0] sprite_address,
		output [5:0] dot_address,
		output reg [9:0] vga_x,
		output reg [8:0] vga_y,
		output reg vga_in, vga_write
	);
	
	reg [9:0] width_counter;
	reg [9:0] block_width;
	
	reg [9:0] x_counter;
	reg [8:0] y_counter;
	reg [1:0] delay_counter;
	
	
	wire [53:0] node_vga_pos;
	wire [8:0] nodeA_pos, nodeB_pos;
	wire [8:0] top_pos, bot_pos, sprite_top, sprite_bot;
	wire [9:0] horizontal_pos;
	wire [1:0] element_type;
	
	assign horizontal_pos = element_index * block_width + block_width[9:1];
	assign top_pos = (nodeA_pos < nodeB_pos) ? nodeA_pos : nodeB_pos;
	assign bot_pos = (nodeA_pos > nodeB_pos) ? nodeA_pos : nodeB_pos;
	assign sprite_top = ((top_pos + bot_pos) >> 1) - 46;
	assign sprite_bot = sprite_top + 93;
	
	assign element_type = element_data[11:10];
	
	nodeAddresstoPosTranslator N1(
		.numNodes(numNodes),
		.nodeA(element_data[23:19]),
		.nodeB(element_data[18:14]),
		
		.node_vga_pos(node_vga_pos),
		.nodeA_pos(nodeA_pos),
		.nodeB_pos(nodeB_pos)
	);
	
	
	assign sprite_address = y_counter * 44 + x_counter;
	assign dot_address = y_counter * 6 + x_counter;
	
	always @(posedge clk) begin: datapath
	
		if (data_reset) begin
			vga_x = 0;
			vga_y = 0;
			vga_in = 1;
			vga_write = 0;
			
			block_width = 0;
			width_counter = 0;
			element_index = 5'b11111;
			
			x_counter = 0;
			y_counter = 0;
			delay_counter = 0;
			
			got_width = 0;
			line_drew = 0;
			sprite_chosen = 0;
			wire_drew = 0;
			sprite_drew = 0;
			node_A_drew = 0;
			node_B_drew = 0;
			drew_all_elements = 0;
		end
		
		if (~got_width & calc_width) begin
			block_width = block_width + 1;
			width_counter = width_counter + numElements;
			if (width_counter > screenWidth) begin
				got_width = 1;
				x_counter = 0;
				y_counter = 0;
				vga_in = 0;
			end
		end
		
		if (~line_drew & draw_line) begin
			vga_write = 1;
			vga_x = x_counter + block_width[9:1];
			case (y_counter >> 1)
				5: vga_y = node_vga_pos[8:0];
				4: vga_y = node_vga_pos[17:9];
				3: vga_y = node_vga_pos[26:18];
				2: vga_y = node_vga_pos[35:27];
				1: vga_y = node_vga_pos[44:36];
				0: vga_y = node_vga_pos[53:45];
				default: vga_y = {8{1'b0}};
			endcase
			
			if (y_counter[0])
				vga_y = vga_y + 1;
			
			x_counter = x_counter + 1;
			if (x_counter == screenWidth - block_width) begin
				x_counter = 0;
				y_counter = y_counter + 1;
			end
			
			if (y_counter == {numNodes, 1'b0}) begin
				y_counter = 0;
				line_drew = 1;
			end
			
		end
		
		
		if (~drew_all_elements & ~sprite_chosen & choose_sprite) begin
			node_B_drew = 0;
			
			element_index = element_index + 1;
			if (element_index == numElements) begin
				drew_all_elements = 1;
			end
			else begin
				sprite_chosen = 1;
				x_counter = 0;
				y_counter = 0;
			end
		end
			
		if (~wire_drew & draw_wire) begin
			sprite_chosen = 0;
			
			vga_write = 1;
			vga_in = 0;
			vga_x = horizontal_pos + x_counter;
			vga_y = top_pos + y_counter;
			
			if (vga_y == bot_pos) begin
				x_counter = 0;
				y_counter = 0;
				delay_counter = 0;
				vga_write = 0;
				wire_drew = 1;
			end
			else begin
				x_counter = x_counter + 1;
				if (x_counter == 2) begin
					x_counter = 0;
					y_counter = y_counter + 1;
				end
			end
		
		end
		
		if (~sprite_drew & draw_sprite) begin
			wire_drew = 0;
			vga_x = horizontal_pos - 21 + x_counter;
			vga_y = sprite_top + y_counter;
			vga_write = 1;
			case (element_type)
				0: vga_in = vSprite_out;
				1: vga_in = cSprite_out;
				2: vga_in = rSprite_out;
				3: vga_in = 1;
			endcase
			
			delay_counter = delay_counter + 1;
			if (delay_counter == 0) begin
				x_counter = x_counter + 1;
				if (x_counter == 44) begin
					x_counter = 0;
					y_counter = y_counter + 1;
				end
			
				if (y_counter == 93) begin
					y_counter = 0;
					sprite_drew = 1;
				end
			end
			
		end
		
		if (~node_A_drew & draw_node_A) begin
			sprite_drew = 0;
			vga_x = horizontal_pos - 2 + x_counter;
			vga_y = top_pos - 4 + y_counter;
			vga_write = 1;
			vga_in = dot_out;
			
			delay_counter = delay_counter + 1;
			if (delay_counter == 0) begin
				x_counter = x_counter + 1;
				if (x_counter == 6) begin
					x_counter = 0;
					y_counter = y_counter + 1;
				end
			
				if (y_counter == 10) begin
					y_counter = 0;
					node_A_drew = 1;
				end
			end
		end
		
		if (~node_B_drew & draw_node_B) begin
			node_A_drew = 0;
			vga_x = horizontal_pos - 2 + x_counter;
			vga_y = bot_pos - 4 + y_counter;
			vga_write = 1;
			vga_in = dot_out;
			
			delay_counter = delay_counter + 1;
			if (delay_counter == 0) begin
				x_counter = x_counter + 1;
				if (x_counter == 6) begin
					x_counter = 0;
					y_counter = y_counter + 1;
				end
			
				if (y_counter == 10) begin
					y_counter = 0;
					node_B_drew = 1;
				end
			end
		end
			
	end

endmodule
	
			
				
	
	
	