`timescale 1ns/1ns

module solveMatrix_main(
		output [3:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// RAM: float_matrix 4096x32
		output [11:0] matrix_addr_a, matrix_addr_b, 
		output [31:0] matrix_data_a, matrix_data_b,
		output matrix_wren_a, matrix_wren_b,
		input [31:0] matrix_out_a, matrix_out_b,
		
		input [3:0] dimension
	);
	
	wire triangular_reached, row_updated, leading_number_found, double_entries_read, double_entries_wrote, rows_swapped;
	wire denominator_fetched, division_done, multiply_row_chosen, multiplier_fetched, multiplication_done, type_III_elimination_done;
		
	wire data_reset, go_update_row, find_leading_number, read_double_entries, write_double_entries;
	wire go_fetch_denominator, go_input_divider, choose_multiply_row, go_fetch_multiplier, go_input_multiplier;
	
	wire [31:0] divider_a, divider_b, divider_r;
	wire [31:0] multiplier_a, multiplier_b, multiplier_r;
	wire [31:0] subtractor_a, subtractor_b, subtractor_r;
	wire [4:0] divider_cd, multiplier_cd, subtractor_cd;
	
	solveMatrix_controller Ctrl_7(
		.current_state(cs),
		.next_state(ns),
		
		.clk(clk),
		.program_reset(program_reset), 
		.start_process(start_process),
		.end_process(end_process),
		
		
		// Input handshakes
		.triangular_reached(triangular_reached),
		.row_updated(row_updated),
		.leading_number_found(leading_number_found),
		.double_entries_read(double_entries_read),
		.double_entries_wrote(double_entries_wrote),
		.rows_swapped(rows_swapped),
		
		.denominator_fetched(denominator_fetched),
		.division_done(division_done),
		.multiply_row_chosen(multiply_row_chosen),
		.multiplier_fetched(multiplier_fetched),
		.multiplication_done(multiplication_done),
		.type_III_elimination_done(type_III_elimination_done),
		
		
		// Output handshakes
		.data_reset(data_reset),
		.go_update_row(go_update_row),
		.find_leading_number(find_leading_number),
		.read_double_entries(read_double_entries),
		.write_double_entries(write_double_entries),
		
		.go_fetch_denominator(go_fetch_denominator),
		.go_input_divider(go_input_divider),
		.choose_multiply_row(choose_multiply_row),
		.go_fetch_multiplier(go_fetch_multiplier),
		.go_input_multiplier(go_input_multiplier)
		
		
	);
	

	solveMatrix_datapath Data_7(
		.dimension(dimension),
		.clk(clk),
		
		// Input handshakes
		.data_reset(data_reset),
		.go_update_row(go_update_row),
		.find_leading_number(find_leading_number),
		.read_double_entries(read_double_entries),
		.write_double_entries(write_double_entries),
		
		.go_fetch_denominator(go_fetch_denominator),
		.go_input_divider(go_input_divider),
		.choose_multiply_row(choose_multiply_row),
		.go_fetch_multiplier(go_fetch_multiplier),
		.go_input_multiplier(go_input_multiplier),
		
		
		// Output handshakes
		.triangular_reached(triangular_reached),
		.row_updated(row_updated),
		.leading_number_found(leading_number_found),
		.double_entries_read(double_entries_read),
		.double_entries_wrote(double_entries_wrote),
		.rows_swapped(rows_swapped),
		
		.denominator_fetched(denominator_fetched),
		.division_done(division_done),
		.multiply_row_chosen(multiply_row_chosen),
		.multiplier_fetched(multiplier_fetched),
		.multiplication_done(multiplication_done),
		.type_III_elimination_done(type_III_elimination_done),
		
		
		// Matrix Ram
		.matrix_addr_a(matrix_addr_a), 
		.matrix_addr_b(matrix_addr_b),
		.matrix_data_a(matrix_data_a),
		.matrix_data_b(matrix_data_b),
		.matrix_wren_a(matrix_wren_a),
		.matrix_wren_b(matrix_wren_b),
		.matrix_out_a(matrix_out_a),
		.matrix_out_b(matrix_out_b),
		
		// Divider
		.divider_a(divider_a),
		.divider_b(divider_b),
		.divider_r(divider_r),
		.divider_cd(divider_cd),
		
		// Multiplier
		.multiplier_a(multiplier_a),
		.multiplier_b(multiplier_b),
		.multiplier_r(multiplier_r),
		.multiplier_cd(multiplier_cd),
		
		// Subtractor
		.subtractor_a(subtractor_a),
		.subtractor_b(subtractor_b),
		.subtractor_r(subtractor_r),
		.subtractor_cd(subtractor_cd)
		
	);
	

	divider Stage7_divide(
		.clock(clk),
		.dataa(divider_a),
		.datab(divider_b),
		.result(divider_r)
	);
	
	multiplier Stage7_multiply(
		.clock(clk),
		.dataa(multiplier_a),
		.datab(multiplier_b),
		.result(multiplier_r)
	);
	
	subtractor Stage7_subtractor(
		.clock(clk),
		.dataa(subtractor_a),
		.datab(subtractor_b),
		.result(subtractor_r)
	);
	
endmodule



