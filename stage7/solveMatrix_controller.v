`timescale 1ns/1ns

module solveMatrix_controller(
		input clk, program_reset, 
		input start_process,
		output reg end_process,
		
		input triangular_reached, row_updated, leading_number_found, double_entries_read, double_entries_wrote, rows_swapped,
		input denominator_fetched, division_done, multiply_row_chosen, multiplier_fetched, multiplication_done, type_III_elimination_done,
		
		output reg data_reset, go_update_row, find_leading_number, read_double_entries, write_double_entries,
		output reg go_fetch_denominator, go_input_divider, choose_multiply_row, go_fetch_multiplier, go_input_multiplier,
		
		output reg [3:0] current_state = 0, next_state
	);

	
	localparam PRE_SOLVE = 4'd0,
				  SOLVE_NEW_ROW = 4'd1,
				  FIND_LEADING_NUM = 4'd2, 
				  READ_TWO_ENTRIES = 4'd3,
				  SWAP_TWO_ENTRIES = 4'd4,
				  FETCH_LEADING_NUMBER = 4'd5,
				  INPUT_DIVIDE_ROW = 4'd6,
				  CHOOSE_NEW_ROW_TYPE_III = 4'd7,
				  FETCH_MULTIPLY_NUMBER = 4'd8,
				  INPUT_MULTIPLY_ROW = 4'd9,
				  DONE_SOLVE = 4'd10;
	
	
	always @(*) begin: state_table
		case (current_state)
			PRE_SOLVE:
				next_state = start_process ? SOLVE_NEW_ROW : PRE_SOLVE;
				
			SOLVE_NEW_ROW:
				next_state = triangular_reached ? DONE_SOLVE : (row_updated ? FIND_LEADING_NUM : SOLVE_NEW_ROW);
			
			FIND_LEADING_NUM: begin
				if (rows_swapped)
					next_state = FETCH_LEADING_NUMBER;
				else
					next_state = leading_number_found ? READ_TWO_ENTRIES : FIND_LEADING_NUM;
			end
			
			READ_TWO_ENTRIES: begin
				if (rows_swapped)
					next_state = FETCH_LEADING_NUMBER;
				else
					next_state = double_entries_read ? SWAP_TWO_ENTRIES : READ_TWO_ENTRIES;
			end
			
			SWAP_TWO_ENTRIES:
				next_state = double_entries_wrote ? READ_TWO_ENTRIES : SWAP_TWO_ENTRIES;
			
			// Normalize the current row
			FETCH_LEADING_NUMBER:
				next_state = denominator_fetched ? INPUT_DIVIDE_ROW : FETCH_LEADING_NUMBER;
				
			INPUT_DIVIDE_ROW:
				next_state = division_done ? CHOOSE_NEW_ROW_TYPE_III : INPUT_DIVIDE_ROW;
				
			CHOOSE_NEW_ROW_TYPE_III: begin
				if (type_III_elimination_done)
					next_state = SOLVE_NEW_ROW;
				else
					next_state = multiply_row_chosen ? FETCH_MULTIPLY_NUMBER : CHOOSE_NEW_ROW_TYPE_III;
			end
			
			FETCH_MULTIPLY_NUMBER:
				next_state = multiplier_fetched ? INPUT_MULTIPLY_ROW : FETCH_MULTIPLY_NUMBER;
				
			INPUT_MULTIPLY_ROW:
				next_state = multiplication_done ? CHOOSE_NEW_ROW_TYPE_III : INPUT_MULTIPLY_ROW;
			
		endcase
	end
	
	
	always @(*) begin: enable_signals
		data_reset = 0;
		go_update_row = 0;
		find_leading_number = 0;
		read_double_entries = 0;
		write_double_entries = 0;
		go_fetch_denominator = 0;
		go_input_divider = 0;
		choose_multiply_row = 0;
		go_fetch_multiplier = 0;
		go_input_multiplier = 0;
		end_process = 0;
		case (current_state)
			PRE_SOLVE: data_reset = 1;
			SOLVE_NEW_ROW: go_update_row = 1;
			FIND_LEADING_NUM: find_leading_number = 1;
			READ_TWO_ENTRIES: read_double_entries = 1;
			SWAP_TWO_ENTRIES: write_double_entries = 1;
			FETCH_LEADING_NUMBER: go_fetch_denominator = 1;
			INPUT_DIVIDE_ROW: go_input_divider = 1;
			CHOOSE_NEW_ROW_TYPE_III: choose_multiply_row = 1;
			FETCH_MULTIPLY_NUMBER: go_fetch_multiplier = 1;
			INPUT_MULTIPLY_ROW: go_input_multiplier = 1;
			DONE_SOLVE: end_process = 1;
		endcase
	end
	
	always @(posedge clk) begin: state_FFs
		if (program_reset)
			current_state <= PRE_SOLVE;
		else if (current_state != DONE_SOLVE)			
			current_state <= next_state;
	end
	

endmodule
