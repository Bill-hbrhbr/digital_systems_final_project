`timescale 1ns/1ns

module generateEquations_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,
		
		// Input hanshakes
		input data_reset_done, matrix_initialized, loop_done, node_chosen, node_valid, status_checked, type_checked, self_data_got, other_data_got,
		input is_voltage, is_current, is_resistor, voltage_done, current_done, resistor_done,
		input compute_1_done, compute_2_done, compute_3_done, compute_4_done, next_element_got, end_of_list,
		
		// Output handshakes
		output reg go_reset_data, go_initialize_matrix, go_choose_node, go_check_node_status, go_check_element_type, go_voltage, go_current, go_resistor,
		output reg go_get_self_data, go_get_other_data, go_compute_1, go_compute_2, go_compute_3, go_compute_4, go_get_next_element,
		
		output reg [3:0] current_state, next_state
	);
	
	localparam PRE_GENERATE = 4'd0,
				  INITIALIZE_MATRIX = 4'd1,
				  CHOOSE_NODE = 4'd2,
				  CHECK_STATUS = 4'd3,
				  CHECK_TYPE = 4'd4,
				  VOLTAGE = 4'd5,
				  CURRENT = 4'd6,
				  GET_SELF = 4'd7,
				  GET_OTHER = 4'd8,
				  COMPUTE_1 = 4'd9,
				  COMPUTE_2 = 4'd10,
				  COMPUTE_3 = 4'd11,
				  COMPUTE_4 = 4'd12,
				  RESISTOR = 4'd13,
				  NEXT_ELEMENT = 4'd14,
				  DONE_GENERATE = 4'd15;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_GENERATE:
				next_state = (data_reset_done & start_process) ? INITIALIZE_MATRIX : PRE_GENERATE;
				
			INITIALIZE_MATRIX:
				next_state = matrix_initialized ? CHOOSE_NODE : INITIALIZE_MATRIX;
			
			CHOOSE_NODE:
				next_state = node_chosen ? CHECK_STATUS : (loop_done ? DONE_GENERATE: CHOOSE_NODE);
				
			CHECK_STATUS:
				next_state = status_checked ? (node_valid ? CHECK_TYPE : CHOOSE_NODE) : CHECK_STATUS;
			
			CHECK_TYPE: begin
				if (type_checked) begin
					if (is_voltage)
						next_state = VOLTAGE;
					
					else if (is_current)
						next_state = CURRENT;
						
					else if (is_resistor)
						next_state = GET_SELF;
						
					else
						next_state = CHECK_TYPE;
				end
				else begin
					next_state = CHECK_TYPE;
				end
			end
			
			VOLTAGE:
				next_state = voltage_done ? NEXT_ELEMENT : VOLTAGE;
				
			CURRENT:
				next_state = current_done ? NEXT_ELEMENT : CURRENT;
				
			GET_SELF:
				next_state = self_data_got ? GET_OTHER : GET_SELF;
				
			GET_OTHER:
				next_state = other_data_got ? COMPUTE_1 : GET_OTHER;
				
			COMPUTE_1:
				next_state = compute_1_done ? COMPUTE_2 : COMPUTE_1;
				
			COMPUTE_2:
				next_state = compute_2_done ? COMPUTE_3 : COMPUTE_2;
				
			COMPUTE_3:
				next_state = compute_3_done ? COMPUTE_4 : COMPUTE_3;
				
			COMPUTE_4:
				next_state = compute_4_done ? RESISTOR : COMPUTE_4;
			
			RESISTOR:
				next_state = resistor_done ? NEXT_ELEMENT : RESISTOR;
				
			NEXT_ELEMENT:
				next_state = end_of_list ? CHOOSE_NODE : (next_element_got ? CHECK_TYPE : NEXT_ELEMENT);
				
		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_initialize_matrix = 0;
		go_choose_node = 0;
		go_check_node_status = 0;
		go_check_element_type = 0;
		go_voltage = 0;
		go_current = 0;
		go_resistor = 0;
		
		go_get_self_data = 0;
		go_get_other_data = 0; 
		go_compute_1 = 0;
		go_compute_2 = 0;
		go_compute_3 = 0;
		go_compute_4 = 0;
		go_get_next_element = 0;
		
		end_process = 0;
		
		case (current_state)
			PRE_GENERATE: go_reset_data = 1;
			INITIALIZE_MATRIX: go_initialize_matrix = 1;
			CHOOSE_NODE: go_choose_node = 1;
			CHECK_STATUS: go_check_node_status = 1;
			CHECK_TYPE: go_check_element_type = 1;
			VOLTAGE: go_voltage = 1;
			CURRENT: go_current = 1;
			GET_SELF: go_get_self_data = 1;
			GET_OTHER: go_get_other_data = 1;
			COMPUTE_1: go_compute_1 = 1;
			COMPUTE_2: go_compute_2 = 1;
			COMPUTE_3: go_compute_3 = 1;
			COMPUTE_4: go_compute_4 = 1;
			RESISTOR: go_resistor = 1;
			NEXT_ELEMENT: go_get_next_element = 1;
			DONE_GENERATE: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset) begin
			current_state <= PRE_GENERATE;
		end
		else if (!end_process) begin 			
			current_state <= next_state;		
		end
	end
	
	
endmodule
