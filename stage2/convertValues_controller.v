`timescale 1ns/1ns

module convertValues_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,
		
		input data_reset_done, element_chosen, fp_conversion_done, exponent_multiplied, resistor_inversion_done, memory_loaded, all_done,
		
		output reg go_reset_data, go_choose_element, go_convert_fp, go_multiply_exp, go_invert_resistor, ld_memory,
		
		output reg [3:0] current_state = 4'd0, next_state
	);
	
	localparam PRE_CONVERT = 4'd0,
				  CHOOSE_NEW_ELEMENT = 4'd1,
				  CONVERT_FP = 4'd2,
				  MULTIPLY_EXP = 4'd3,
				  INVERT_RESISTOR = 4'd4,
				  MEMORY_LOAD_WAIT = 4'd5,
				  DONE_CONVERT = 4'd6;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_CONVERT:
				next_state = (data_reset_done & start_process) ? CHOOSE_NEW_ELEMENT : PRE_CONVERT;
			
			CHOOSE_NEW_ELEMENT: begin
				if (all_done)
					next_state = DONE_CONVERT;
				else
					next_state = element_chosen ? CONVERT_FP : CHOOSE_NEW_ELEMENT;
			end
			
			CONVERT_FP:
				next_state = fp_conversion_done ? MULTIPLY_EXP : CONVERT_FP;
				
			MULTIPLY_EXP:
				next_state = exponent_multiplied ? INVERT_RESISTOR : MULTIPLY_EXP;
				
			INVERT_RESISTOR:
				next_state = resistor_inversion_done ? MEMORY_LOAD_WAIT : INVERT_RESISTOR;
				
			MEMORY_LOAD_WAIT:
				next_state = memory_loaded ? CHOOSE_NEW_ELEMENT : MEMORY_LOAD_WAIT;
			
		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_choose_element = 0;
		go_convert_fp = 0;
		go_multiply_exp = 0;
		go_invert_resistor = 0;
		ld_memory = 0;
		end_process = 0;
		
		case (current_state)
			PRE_CONVERT: go_reset_data = 1;
			CHOOSE_NEW_ELEMENT: go_choose_element = 1;
			CONVERT_FP: go_convert_fp = 1;
			MULTIPLY_EXP: go_multiply_exp = 1;
			INVERT_RESISTOR: go_invert_resistor = 1;
			MEMORY_LOAD_WAIT: ld_memory = 1;
			DONE_CONVERT: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset)
			current_state <= PRE_CONVERT;
		else if (!end_process)	
			current_state <= next_state;
	end

	
endmodule