`timescale 1ns/1ns

module getElement_controller(
		input clk, program_reset, input_reset, input_over, go,
		input start_process, output reg end_process,
		
		input data_reset_done, element_reset_done, count_increased,
		
		output reg go_reset_data, go_reset_element, do_display, ld_type, ld_value, ld_exponent, ld_nodes, ld_memory, inc_count,
		
		output reg [3:0] current_state = 4'd0, next_state
	);
	
	localparam PRE_LOAD = 4'd0,
				  DISPLAY_ELEMENT_NUM = 4'd1,
				  DISPLAY_WAIT = 4'd2,
		        TYPE_LOAD = 4'd3,
				  TYPE_WAIT = 4'd4,
				  VALUE_LOAD = 4'd5,
				  VALUE_WAIT = 4'd6,
				  EXPONENT_LOAD = 4'd7,
				  EXPONENT_WAIT = 4'd8,
				  NODE_AB_LOAD = 4'd9,
				  NODE_AB_WAIT = 4'd10,
				  MEMORY_LOAD = 4'd11,
				  NEW_ELEMENT = 4'd12,
				  ELEMENT_RESET = 4'd13,
				  DONE_LOAD = 4'd14;
	
	
	
	always @(*) begin: state_table
		case (current_state)
			PRE_LOAD:
				next_state = (data_reset_done & start_process) ? DISPLAY_ELEMENT_NUM : PRE_LOAD;
				
			ELEMENT_RESET:
				next_state = element_reset_done ? DISPLAY_ELEMENT_NUM : ELEMENT_RESET;
			
			DISPLAY_ELEMENT_NUM: begin
				if (input_over)
					next_state = DONE_LOAD;
				else
					next_state = go ? DISPLAY_WAIT : DISPLAY_ELEMENT_NUM;
			end
			
			DISPLAY_WAIT:
				next_state = go ? DISPLAY_WAIT : TYPE_LOAD;
			
			TYPE_LOAD:
				next_state = go ? TYPE_WAIT : TYPE_LOAD;
			
			TYPE_WAIT:
				next_state = go ? TYPE_WAIT : VALUE_LOAD;
			
			VALUE_LOAD:
				next_state = go ? VALUE_WAIT : VALUE_LOAD;
			
			VALUE_WAIT:
				next_state = go ? VALUE_WAIT : EXPONENT_LOAD;
				
			EXPONENT_LOAD:
				next_state = go ? EXPONENT_WAIT : EXPONENT_LOAD;
				
			EXPONENT_WAIT:
				next_state = go ? EXPONENT_WAIT : NODE_AB_LOAD;
			
			NODE_AB_LOAD:
				next_state = go ? NODE_AB_WAIT : NODE_AB_LOAD;
			
			NODE_AB_WAIT:
				next_state = go ? NODE_AB_WAIT : MEMORY_LOAD;
			
			MEMORY_LOAD:
				next_state = NEW_ELEMENT;
				
			NEW_ELEMENT:
				next_state = count_increased ? DISPLAY_ELEMENT_NUM : NEW_ELEMENT;
				
		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_reset_element = 0;
		do_display = 0;
		ld_type = 0;
		ld_value = 0;
		ld_exponent = 0;
		ld_nodes = 0;
		ld_memory = 0;
		inc_count = 0;
		end_process = 0;
		
		case (current_state)
			PRE_LOAD: go_reset_data = 1;
			ELEMENT_RESET: go_reset_element = 1;
			DISPLAY_ELEMENT_NUM: do_display = 1;
			TYPE_LOAD: ld_type = 1;
			VALUE_LOAD: ld_value = 1;
			EXPONENT_LOAD: ld_exponent = 1;
			NODE_AB_LOAD: ld_nodes = 1;
			MEMORY_LOAD: ld_memory = 1;
			NEW_ELEMENT: inc_count = 1;
			DONE_LOAD: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset) begin
			current_state <= PRE_LOAD;
		end
		else if (!end_process) begin 			
			if (input_reset)
				current_state <= ELEMENT_RESET;
			else
				current_state <= next_state;		
		end
		else begin
			current_state <= current_state;
		end
	end

	
endmodule
