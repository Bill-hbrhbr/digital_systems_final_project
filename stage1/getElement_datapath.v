`timescale 1ns/1ns

module getElement_datapath(
		input clk,
		input [9:0] data_in,
		
		input go_reset_data, go_reset_element, do_display, ld_type, ld_value, ld_exponent, ld_nodes, ld_memory, inc_count,
		
		output reg data_reset_done = 0, element_reset_done, count_increased,
		
		// HEX display
		output reg [6:0] h0, h1, h2, h3, h4, h5,
		
		// element RAM
		output reg [4:0] element_addr,
		output reg [31:0] element_data,
		output reg element_wren,
		
		output reg [4:0] element_index
	);
	
	
	
	reg [1:0] type;
	reg [9:0] value;
	reg [9:0] exponent;
	reg [4:0] node_A, node_B;
	
	wire [6:0] index_h1, index_h0, v3, v2, v1, v0, e3, e2, e1, e0, n5, n4, n1, n0;
	
	BCD7Seg B1(
		.data_in({6'd0, element_index}),
		.h1(index_h1),
		.h0(index_h0)
	);
	
	BCD7Seg B2(
		.data_in(value), 
		.h3(v3), 
		.h2(v2), 
		.h1(v1), 
		.h0(v0)
	);
	
	BCD7Seg B3(
		.data_in({1'b0, exponent[8:0]}), 
		.h3(e3), 
		.h2(e2), 
		.h1(e1), 
		.h0(e0)
	);
	
	BCD7Seg BA(
		.data_in({5'd0, node_A}),
		.h1(n5),
		.h0(n4)
	);
	
	BCD7Seg BB(
		.data_in({5'd0, node_B}),
		.h1(n1),
		.h0(n0)
	);
	
	
	always @(posedge clk) begin: datapath
		/*
		h5 = 7'b1111111;
		h4 = 7'b1111111;
		h3 = 7'b1111111;
		h2 = 7'b1111111;
		h1 = 7'b1111111;
		h0 = 7'b1111111;
		*/
		if (go_reset_data) begin
			element_reset_done = 0;
			
			element_index = 0;
			type = 0;
			value = 0;
			node_A = 0;
			node_B = 0;
			
			element_addr = 0;
			element_data = 0;
			element_wren = 0;
			
			count_increased = 0;
			data_reset_done = 1;
		end 
		else begin
			data_reset_done = 0;
		end
		
		if (go_reset_element) begin
			type = 0;
			value = 0;
			node_A = 0;
			node_B = 0;
			
			element_addr = 0;
			element_data = 0;
			element_wren = 0;
			
			count_increased = 0;
			
			element_reset_done = 1;
		end
		
		if (do_display) begin
			data_reset_done = 0;
			element_reset_done = 0;
			count_increased = 0;
			
			h5 = 7'b1111111;
			h4 = 7'b1111111;
			h3 = 7'b0101011;  // lowercase 'n'
			h2 = 7'b0100011;  // lowercase 'o'
			h1 = index_h1;
			h0 = index_h0;
		end
		
		if (ld_type) begin
			type = data_in[1:0];
			
			h5 = 7'b1000111;  // Uppercase 'L'
			h4 = 7'b0100001;  // lppercase 'd'
			case (type)
				0: begin // Load Voltage Source
					h3 = 7'b1000001; // 'U'
					h2 = 7'b1000000; // 'O'
					h1 = 7'b1000111; // 'L'
					h0 = 7'b0000111; // 't'
				end
				
				1: begin // Load Current Source
					h3 = 7'b0100111; // 'c'
					h2 = 7'b1100011; // 'u'
					h1 = 7'b0101111; // 'r'
					h0 = 7'b0101111; // 'r'
				end
				
				2: begin // Load Resistor
					h3 = 7'b0101111; // 'r'
					h2 = 7'b0000110; // 'E'
					h1 = 7'b0010010; // 'S'
					h0 = 7'b1111001; // 'I'
				end
				
				3: begin // Default
					h3 = 7'b1111111;
					h2 = 7'b1111111;
					h1 = 7'b1111111;
					h0 = 7'b1111111;
				end
			endcase
		end
		
		if (ld_value) begin
			value = data_in;
			h5 = 7'b1111111;
			h4 = 7'b1111111;
			h3 = v3;
			h2 = v2;
			h1 = v1;
			h0 = v0;
		end
		
		if (ld_exponent) begin
			exponent = data_in;
			h5 = 7'b0000110; // 'E'
			h4 = exponent[9] ? 7'b0111111 : 7'b1111111; // Signed
			h3 = e3;
			h2 = e2;
			h1 = e1;
			h0 = e0;
		end
		
		if (ld_nodes) begin
			node_A = data_in[9:5];
			node_B = data_in[4:0];
			h5 = n5;
			h4 = n4;
			h3 = 7'b0001000; // 'A'
			h2 = 7'b0000011; // 'b'
			h1 = n1;
			h0 = n0;
		end
		
		if (ld_memory) begin
			element_addr = element_index;
			element_data = {node_A, node_B, type, exponent, value};
			element_wren = 1;
		end
		
		if (~count_increased & inc_count) begin
			element_wren = 0;
			element_index = element_index + 1;
			count_increased = 1;
		end
		
	end
	

endmodule


