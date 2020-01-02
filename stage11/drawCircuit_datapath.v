`timescale 1ns/1ns

module drawCircuit_datapath(
		// FPGA inputs
		input clk,
		// Input handshakes
		input go_reset_data, go_read_processor, go_clear_signal, go_draw_command,
		
		// Output hanshakes
		output reg data_reset_done, finished_all, command_read, signals_cleared,
		output reg done_draw_command,
		
		// RAM: processor 1024x48
		output reg [9:0] processor_addr,
		output processor_wren,
		input [47:0] processor_out,
		
		// VGA
		output reg [9:0] vga_x,
		output reg [8:0] vga_y,
		output reg vga_in, vga_wren,
		
		// Circuit Element Sprites
		output reg [11:0] vSprite_addr, cSprite_addr, rSprite_addr, 
		input vSprite_out, cSprite_out, rSprite_out,
		
		output reg [5:0] dot_addr,
		input dot_out,
		
		// Misc
		input [9:0] numCommands

	);
	
	assign processor_wren = 0;
	
	wire go;
	wire [8:0] go_code;
	wire [9:0] left, width;
	wire [8:0] top, height;
	
	assign go = processor_out[47];
	assign go_code = processor_out[46:38];
	assign left = processor_out[9:0];
	assign top = processor_out[18:10];
	assign width = processor_out[28:19];
	assign height = processor_out[37:29];
	
	reg [9:0] x_counter, y_counter;
	reg [1:0] ram_delay = 0;
	// name: draw_processor
	// Handle: filled node lines, dashed node lines, straight wires, vSprite, cSprite, rSprite, dot, 
	// mouse normal sprite, mouse select sprite, mouser grab sprite, digits, decimal point, 'E', `V`, `A`, `ohm`
	// 47-bit, 1024 words
	// bit [47]: 1-do this command; 0-skip this command
	// bit [46:38]: 9-bit, the type of stuff being drawed
	// bit [37:29]: 9-bit, height of the shape
	// bit [28:19]: 10-bit, width of the shape
	// bit [18:10]: 9-bit, topmost position
	// bit [9:0]: 10-bit, leftmost position
	
	always @(posedge clk) begin: datapath
		if (go_reset_data) begin
			command_read = 0;
			finished_all = 0;
			signals_cleared = 0;
			
			done_draw_command = 0;
			
			processor_addr = {10{1'b1}};
			vga_x = 0;
			vga_y = 0;
			vga_in = 0;
			vga_wren = 0;
			
			vSprite_addr = 0;
			cSprite_addr = 0;
			rSprite_addr = 0;
			dot_addr = 0;
			
			x_counter = 0;
			y_counter = 0;
			ram_delay = 0;
			data_reset_done = 1;
		end
		else begin
			data_reset_done = 0;
		end
		
		if (~finished_all & ~command_read & go_read_processor) begin
			signals_cleared = 0;
			
			processor_addr = processor_addr + 1;
			if (processor_addr == numCommands) begin
				finished_all = 1;
			end
			else begin
				command_read = 1;
			end
		end
		
		if (go_draw_command & ~go) begin
			command_read = 0;
			done_draw_command = 1;
		end
		
		// Draw dashed lines
		if (~done_draw_command & go_draw_command & (go_code == 9'd0)) begin
			command_read = 0;
			
			vga_x = left + x_counter;
			vga_y = top + y_counter;
			vga_in = vga_x[3];
			vga_wren = 1;
			
			x_counter = x_counter + 1;
			if (x_counter == width) begin
				x_counter = 0;
				y_counter = y_counter + 1;
			end
			
			if (y_counter == height) begin
				y_counter = 0;
				done_draw_command = 1;
			end
		end
		
		// Straight wire
		if (~done_draw_command & go_draw_command & go_code == 9'd1) begin
			command_read = 0;
			
			vga_x = left + x_counter;
			vga_y = top + y_counter;
			vga_in = 0;
			vga_wren = 1;
			
			x_counter = x_counter + 1;
			if (x_counter == width) begin
				x_counter = 0;
				y_counter = y_counter + 1;
			end
			
			if (y_counter == height) begin
				y_counter = 0;
				done_draw_command = 1;
			end
		end
		
		
		// Draw sprites
		// Draw vSprite, cSprite, rSprite
		if (~done_draw_command & go_draw_command & (go_code == 9'd2 | go_code == 9'd3 | go_code == 9'd4)) begin
			command_read = 0;
			
			case (go_code)
				2: begin
					vSprite_addr = y_counter * width + x_counter;
					vga_in = vSprite_out;
				end
				
				3: begin
					cSprite_addr = y_counter * width + x_counter;
					vga_in = cSprite_out;
				end
				
				4: begin
					rSprite_addr = y_counter * width + x_counter;
					vga_in = rSprite_out;
				end
				
				default: begin
					vSprite_addr = 0;
					cSprite_addr = 0;
					rSprite_addr = 0;
					dot_addr = 0;
					vga_in = 1;
				end
			endcase
			
			vga_x = left + x_counter;
			vga_y = top + y_counter;
			vga_wren = 0;
			
			ram_delay = ram_delay + 1;
			if (&ram_delay) begin
				vga_wren = 1;
			end
			else if (!ram_delay) begin
				x_counter = x_counter + 1;
				if (x_counter == width) begin
					x_counter = 0;
					y_counter = y_counter + 1;
				end
			
				if (y_counter == height) begin
					y_counter = 0;
					done_draw_command = 1;
				end
			end
		end
		
		// Node dot sprite
		if (~done_draw_command & go_draw_command & go_code == 9'd5) begin
			command_read = 0;
			
			dot_addr = y_counter * width + x_counter;
			vga_x = left + x_counter;
			vga_y = top + y_counter;
			vga_in = 0;
			vga_wren = 0;
			
			ram_delay = ram_delay + 1;
			if (&ram_delay) begin
				vga_wren = ~dot_out;
			end
			else if (!ram_delay) begin
				x_counter = x_counter + 1;
				if (x_counter == width) begin
					x_counter = 0;
					y_counter = y_counter + 1;
				end
			
				if (y_counter == height) begin
					y_counter = 0;
					done_draw_command = 1;
				end
			end
		end
		
		
		if (~signals_cleared & go_clear_signal) begin
			done_draw_command = 0;
			
			vga_wren = 0;
			signals_cleared = 1;
		end
		
	end
	
	
endmodule
