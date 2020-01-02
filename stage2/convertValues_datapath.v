`timescale 1ns/1ns

module convertValues_datapath(
		// FPGA inputs
		input clk,
		
		// Input handshakes
		input go_reset_data, go_choose_element, go_convert_fp, go_multiply_exp, go_invert_resistor, ld_memory,
		
		// Output hanshakes
		output reg data_reset_done = 0, element_chosen, fp_conversion_done, exponent_multiplied, resistor_inversion_done, memory_loaded, all_done,
		
		// element RAM
		output reg [4:0] element_addr,
		output element_wren,
		input [31:0] element_out,
		
		// float_register RAM
		output [4:0] float_register_addr,
		output reg [31:0] float_register_data,
		output reg float_register_wren,
		
		// int_to_fp ALTFP_CONVERT
		output [31:0] int_to_fp_data,
		input [31:0] int_to_fp_out,
		
		// multiplier ALTFP_MULT
		output reg [31:0] multiplier_data_a,
		output [31:0] multiplier_data_b,
		input [31:0] multiplier_out,
		
		// multiplier ALTFP_DIV
		output [31:0] divider_data_a,
		output reg [31:0] divider_data_b,
		input [31:0] divider_out,
		
		input [4:0] numElements
		
	);

	
	reg [3:0] int_to_fp_cd;
	reg [3:0] multiplier_cd;
	reg [4:0] divider_cd;
	reg [1:0] mem_cd;
	
	wire [1:0] type;
	wire [8:0] exponent;
	wire sign;
	reg [8:0] exp_counter;
	
	assign element_wren = 0;
	
	assign type = element_out[21:20];
	assign exponent = element_out[18:10];
	assign sign = element_out[19];
	assign multiplier_data_b = sign ? 32'b00111101110011001100110011001101 : 32'b01000001001000000000000000000000;  // either 0.1 or 10
	assign divider_data_a = 32'b00111111100000000000000000000000; // floating point 1
	
	assign int_to_fp_data = {{22{1'b0}}, element_out[9:0]};
	assign float_register_addr = element_addr;
	
	always @(posedge clk) begin: datapath
		
		if (go_reset_data) begin
			element_chosen = 0;
			fp_conversion_done = 0;
			exponent_multiplied = 0;
			resistor_inversion_done = 0;
			memory_loaded = 0;
			all_done = 0;
			
			element_addr = 5'b11111;
			
			float_register_data = 0;
			float_register_wren = 0;
			
			multiplier_data_a = 0;
			divider_data_b = 32'b00111111100000000000000000000000; // floating-point 1
			
			int_to_fp_cd = 0;
			multiplier_cd = 0;
			divider_cd = 0;
			mem_cd = 0;
			exp_counter = 0;
			
			data_reset_done = 1;
		end
		
		else begin
			data_reset_done = 0;
		end
		
		if (~all_done & ~element_chosen & go_choose_element) begin
			memory_loaded = 0;
			
			element_addr = element_addr + 1;
			
			if (element_addr == numElements)
				all_done = 1;
			else
				element_chosen = 1;
		
		end
		
		if (~fp_conversion_done & go_convert_fp) begin
			element_chosen = 0;
			int_to_fp_cd = int_to_fp_cd - 1;
			if (!int_to_fp_cd) begin
				multiplier_data_a = int_to_fp_out;
				fp_conversion_done = 1;
				exp_counter = 0;
			end
		end
		
		if (~exponent_multiplied & go_multiply_exp) begin
			fp_conversion_done = 0;
			
			if (exp_counter == exponent) begin
				divider_data_b = multiplier_data_a;
				multiplier_cd = 0;
				exponent_multiplied = 1;
			end
			else begin
				multiplier_cd = multiplier_cd - 1;
				if (!multiplier_cd) begin
					exp_counter = exp_counter + 1;
					multiplier_data_a = multiplier_out;
				end
			end
		end
		
		if (~resistor_inversion_done & go_invert_resistor) begin
			exponent_multiplied = 0;
			if (type != 2'b10) begin
				float_register_data = divider_data_b;
				float_register_wren = 1;
				divider_cd = 0;
				resistor_inversion_done = 1;
			end
			
			divider_cd = divider_cd - 1;
			if (!divider_cd) begin
				float_register_data = divider_out;
				float_register_wren = 1;
				resistor_inversion_done = 1;
			end
		end
			
		if (~memory_loaded & ld_memory) begin
			resistor_inversion_done = 0;
			mem_cd = mem_cd - 1;
			if (!mem_cd) begin
				float_register_wren = 0;
				memory_loaded = 1;
			end
		end
		
	end
	
	
	
endmodule
	
	
	