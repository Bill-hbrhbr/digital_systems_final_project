`timescale 1ns/1ns

module convertValues_main(
		output [3:0] cs, ns,
		output [31:0] int_to_fp_data, int_to_fp_out, multiplier_data_a, multiplier_data_b, multiplier_out,
		output [31:0] divider_data_a, divider_data_b, divider_out,
		
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// element RAM
		output [4:0] element_addr,
		//output [31:0] element_data,
		output element_wren,
		input [31:0] element_out,
		
		
		// float_register RAM
		output [4:0] float_register_addr,
		output [31:0] float_register_data,
		output float_register_wren,
		//input [31:0] float_register_out
		
		input [4:0] numElements
		
		
	);
	
	
	wire data_reset_done, element_chosen, fp_conversion_done, exponent_multiplied, resistor_inversion_done, all_done;
	wire go_reset_data, go_choose_element, go_convert_fp, go_multiply_exp, go_invert_resistor;
	
	convertValues_controller Ctrl_2(
		.current_state(cs),
		.next_state(ns),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(program_reset),  // ~KEY[0]
		
		// Initial and Final
		.start_process(start_process),    // run_convertValues
		.end_process(end_process),        // valueConversion_done
		
		// Input handshakes
		.data_reset_done(data_reset_done),
		.element_chosen(element_chosen),
		.fp_conversion_done(fp_conversion_done),
		.exponent_multiplied(exponent_multiplied),
		.resistor_inversion_done(resistor_inversion_done),
		.memory_loaded(memory_loaded),
		.all_done(all_done),
		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_choose_element(go_choose_element),
		.go_convert_fp(go_convert_fp),
		.go_multiply_exp(go_multiply_exp),
		.go_invert_resistor(go_invert_resistor),
		.ld_memory(ld_memory)
	);
	
	convertValues_datapath Data_2(
		// FPGA inputs
		.clk(clk),
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_choose_element(go_choose_element),
		.go_convert_fp(go_convert_fp),
		.go_multiply_exp(go_multiply_exp),
		.go_invert_resistor(go_invert_resistor),
		.ld_memory(ld_memory),
		
		// Output hanshakes
		.data_reset_done(data_reset_done),
		.element_chosen(element_chosen),
		.fp_conversion_done(fp_conversion_done),
		.exponent_multiplied(exponent_multiplied),
		.resistor_inversion_done(resistor_inversion_done),
		.memory_loaded(memory_loaded),
		.all_done(all_done),
		
		// element RAM
		.element_addr(element_addr),
		.element_wren(element_wren),
		.element_out(element_out),
		
		// float_register RAM
		.float_register_addr(float_register_addr),
		.float_register_data(float_register_data),
		.float_register_wren(float_register_wren),
		//.float_register_out(float_register_out),
		
		// int_to_fp ALTFP_CONVERT
		.int_to_fp_data(int_to_fp_data),
		.int_to_fp_out(int_to_fp_out),
		
		// multiplier ALTFP_MULT
		.multiplier_data_a(multiplier_data_a),
		.multiplier_data_b(multiplier_data_b),
		.multiplier_out(multiplier_out),
		
		// divider ALTFP_DIV
		.divider_data_a(divider_data_a),
		.divider_data_b(divider_data_b),
		.divider_out(divider_out),
		
		.numElements(numElements)
		
	);
	
	int_to_fp Stage2_convert(
		.clock(clk),
		.dataa(int_to_fp_data),
		.result(int_to_fp_out)
	);
	
	
	multiplier Stage2_multiply(
		.clock(clk),
		.dataa(multiplier_data_a),
		.datab(multiplier_data_b),
		.result(multiplier_out)
	);
	
	divider Stage2_divide(
		.clock(clk),
		.dataa(divider_data_a),
		.datab(divider_data_b),
		.result(divider_out)
	);
	
endmodule

	
	
	