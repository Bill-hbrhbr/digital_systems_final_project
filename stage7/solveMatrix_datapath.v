module solveMatrix_datapath(
		input [3:0] dimension,
		input clk,
		
		// Input handshakes
		input data_reset, go_update_row, find_leading_number, read_double_entries, write_double_entries,
		input go_fetch_denominator, go_input_divider, choose_multiply_row, go_fetch_multiplier, go_input_multiplier,
		
		// Output handshakes
		output reg triangular_reached, row_updated, leading_number_found, double_entries_read, double_entries_wrote, rows_swapped,
		output reg denominator_fetched, division_done, multiply_row_chosen, multiplier_fetched, multiplication_done, type_III_elimination_done, 
		output reg row_normalized,
		
		// RAM
		input [31:0] matrix_out_a, matrix_out_b,
		output reg [11:0] matrix_addr_a, matrix_addr_b,
		output reg [31:0] matrix_data_a, matrix_data_b,
		output reg matrix_wren_a, matrix_wren_b,
		
		
		// Float Divider/Multiplier/Adder Ram
		output reg [31:0] divider_a, divider_b, multiplier_a, multiplier_b, subtractor_a, subtractor_b,
		input [31:0] divider_r, multiplier_r, subtractor_r,
		
		output reg [4:0] divider_cd, multiplier_cd, subtractor_cd
	);
	
	
	reg ram_ready;
	reg [3:0] current_row;
	reg [3:0] row_counter, col_counter;
	
	
	wire [3:0] numColumns, numRows;
	assign numRows = dimension;
	assign numColumns = dimension + 1;
	
	always @(posedge clk) begin
		if (data_reset) begin
			matrix_addr_a = 0;
			matrix_addr_b = 0;
			matrix_data_a = 0;
			matrix_data_b = 0;
			matrix_wren_a = 0;
			matrix_wren_b = 0;
			
			current_row = 4'b1111;
			row_counter = 0;
			col_counter = 0;
			
			
			triangular_reached = 0;
			row_updated = 0;
			leading_number_found = 0;
			double_entries_read = 0;
			double_entries_wrote = 0;
			rows_swapped = 0;
			
			denominator_fetched = 0;
			division_done = 0;
			multiply_row_chosen = 0;
			multiplier_fetched = 0;
			multiplication_done = 0;
			type_III_elimination_done = 0;
			
			ram_ready <= 0;
			divider_cd = 0;
		end
		
		if (~triangular_reached & ~row_updated & go_update_row) begin
			type_III_elimination_done = 0;
			
			current_row = current_row + 1;
			if (current_row == dimension) begin
				triangular_reached = 1;
			end 
			
			else begin
				row_counter = current_row;
				// Read the leading number from port a
				matrix_wren_a = 0;
				matrix_addr_a = row_counter * numColumns + current_row; // Leading Number address
				ram_ready <= 0;
				row_updated = 1;
			end
		end
		
		
		if (~leading_number_found & find_leading_number) begin
			row_updated = 0;
			ram_ready <= 1;
			
			if (ram_ready) begin
				
				if (matrix_out_a) begin	
					if (row_counter == current_row) begin
						rows_swapped = 1;
						matrix_addr_b = current_row * numColumns + current_row; // Fetch the leading number
						matrix_wren_b = 0;
						ram_ready <= 0;
					end
					
					else begin
						col_counter = 4'b1111;
			
						matrix_addr_a = (row_counter - 1) * numColumns + current_row - 1;  // Leading Number address - 1
						matrix_addr_b = current_row * numColumns + current_row - 1;  // Original number address - 1
						matrix_wren_a = 0;
						matrix_wren_b = 0;
						matrix_data_a = 0;
						matrix_data_b = 0;
				
						leading_number_found = 1;
					end
				end 
				
				else begin
					row_counter = row_counter + 1;
					matrix_addr_a = matrix_addr_a + numColumns; // Leading number address
				end
		
			end
		end
		
		if (~rows_swapped & ~double_entries_read & read_double_entries) begin
			leading_number_found = 0;
			ram_ready <= 0;
			double_entries_wrote = 0;
			
			matrix_wren_a = 0;
			matrix_wren_b = 0;
			
			col_counter = col_counter + 1;
			if (col_counter + current_row == numColumns) begin
				rows_swapped = 1;
				matrix_addr_b = current_row * numColumns + current_row; // Fetch the leading number
				matrix_wren_b = 0;
				ram_ready <= 0;
			end
			
			else begin
				matrix_addr_a = matrix_addr_a + 1;
				matrix_addr_b = matrix_addr_b + 1;
				double_entries_read = 1;
			end
			
		end
		
		if (~double_entries_wrote & write_double_entries) begin
			double_entries_read = 0;
			
			matrix_data_b = matrix_out_a;
			matrix_data_a = matrix_out_b;
			matrix_wren_a = 1;
			matrix_wren_b = 1;
			
			double_entries_wrote = 1;
		end
		
		// Stage 2
		if (~denominator_fetched & go_fetch_denominator) begin
			rows_swapped = 0;
			
			ram_ready <= 1;

			if (ram_ready) begin
				denominator_fetched = 1;
				divider_b = matrix_out_b;
				
				matrix_addr_a = current_row * numColumns + current_row;
				matrix_wren_a = 0;
				col_counter = current_row - 1;
				ram_ready <= 0;
				divider_cd = 16;
			end
		end
		
		
		if (~division_done & go_input_divider) begin
			denominator_fetched = 0;
			ram_ready <= 1;
			matrix_addr_a = matrix_addr_a + 1;
			if (ram_ready) begin
				divider_a = matrix_out_a;
			end
			
			
			if (divider_cd) begin
				divider_cd = divider_cd - 1;
			end
			else begin
				col_counter = col_counter + 1;
				matrix_addr_b = current_row * numColumns + col_counter;
				matrix_data_b = divider_r;
				matrix_wren_b	= 1;
				
				if (col_counter == numColumns) begin
					division_done = 1;
					matrix_wren_b = 0;
					
					ram_ready <= 0;
					row_counter = 4'b1111;
					
				end
			end
			
		end
		
		
		// Stage 3
		if (~type_III_elimination_done & ~multiply_row_chosen & choose_multiply_row) begin
			division_done = 0;
			multiplication_done = 0;
			
			row_counter = row_counter + 1;
			if (row_counter == current_row)
				row_counter = row_counter + 1;
			
			if (row_counter == dimension) begin
				type_III_elimination_done = 1;
			end
			
			else begin
				multiply_row_chosen = 1;
				matrix_addr_b = row_counter * numColumns + current_row; 
				matrix_wren_b = 0;
				ram_ready <= 0;
			end
		end
		
		
		if (~multiplier_fetched & go_fetch_multiplier) begin
			multiply_row_chosen = 0;
			
			ram_ready <= 1;
			if (ram_ready) begin
				multiplier_fetched = 1;
				multiplier_b = matrix_out_b; // Store the column number into the second multiplying operand
				
				matrix_addr_a = current_row * numColumns;
				matrix_wren_a = 0;
				col_counter = 4'b1111;
				
				matrix_addr_b = row_counter * numColumns;
				matrix_wren_b = 0;
				
				ram_ready <= 0;
				multiplier_cd = 12;
				subtractor_cd = 16;
			end
		end
		
		
		if (~multiplication_done & go_input_multiplier) begin
			multiplier_fetched = 0;
			ram_ready <= 1;
			
			if (ram_ready) begin
				multiplier_a = matrix_out_a;
			end
			
			if (multiplier_cd) begin
				multiplier_cd = multiplier_cd - 1;
				matrix_addr_a = matrix_addr_a + 1;
			end
			
			else begin
				// Load the multiplication result directly into the subtractor
				
				matrix_addr_b = matrix_addr_b + 1;
				subtractor_a = matrix_out_b;
				subtractor_b = multiplier_r;
				
				if (subtractor_cd) begin
					subtractor_cd = subtractor_cd - 1;
					matrix_addr_a = row_counter * numColumns - 1;
					matrix_wren_a = 0;
					col_counter = 4'b1111;
				end
				
				else begin
					matrix_addr_a = matrix_addr_a + 1;
					matrix_data_a = subtractor_r;
					matrix_wren_a = 1;
					
					col_counter = col_counter + 1;
					if (col_counter == numColumns) begin
						multiplication_done = 1;
						matrix_wren_a = 0;
					
						ram_ready <= 0;
					end
				
				end
			end
		end
	end
	
endmodule
