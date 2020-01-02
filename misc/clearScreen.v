`timescale 1ns/1ns

module clearScreen(
		input clk, program_reset,
		input start_process, 
		output reg end_process,
		
		output reg [9:0] vga_x,
		output reg [8:0] vga_y,
		output reg vga_in, 
		output reg vga_wren
	);
	
	always @(posedge clk) begin
		vga_in = 1;
		
		if (program_reset) begin
			end_process = 0;
			vga_wren = 0;
			vga_x = 0;
			vga_y = 0;
		end
		
		if (~end_process & start_process) begin
			vga_wren = 1;
			vga_x = vga_x + 1;
			if (vga_x == 640) begin
				vga_x = 0;
				vga_y = vga_y + 1;
			end
			
			if (vga_y == 480) begin
				vga_y = 0;
				vga_wren = 0;
				end_process = 1;
			end
		end
		
	end
endmodule
