`timescale 1ns/1ns

module chooseRefNode_datapath(
		// FPGA inputs
		input clk,
		input [9:0] data_in,
		
		// Input handshakes
		input go_reset_data, go_display_choose, go_display_refnode, ld_node_index, go_judge_valid, go_display_invalid,
		
		// Output handshakes
		output reg data_reset_done, done_judge, node_index_valid,
		
		// HEX display
		output reg [6:0] h0, h1, h2, h3, h4, h5,
		
		// count
		input [4:0] numNodes,
		output reg [4:0] ground_node
	);
	
	wire [6:0] index_h1, index_h0;

	BCD7Seg Stage4_BCD(
		.data_in({5'd0, ground_node}),
		.h1(index_h1),
		.h0(index_h0)
	);
	
	always @(posedge clk) begin: datapath
		
		if (go_reset_data) begin
			ground_node = 0;
			done_judge = 0;
			node_index_valid = 0;
			
			data_reset_done = 1;
		end 
		else begin
			data_reset_done = 0;
		end
		
		if (go_display_choose) begin
			h5 = 7'b1000110; // 'C'
			h4 = 7'b0001001; // 'H'
			h3 = 7'b1000000; // 'O'
			h2 = 7'b1000000; // 'O'
			h1 = 7'b0010010; // 'S'
			h0 = 7'b0000110; // 'E'
		end
		
		if (go_display_refnode) begin
			h5 = 7'b0000010; // 'G'
			h4 = 7'b0101111; // 'r'
			h3 = 7'b0100011; // 'o'
			h2 = 7'b1100011; // 'u'
			h1 = 7'b0101011; // 'n'
			h0 = 7'b0100001; // 'd'
		end
		
		if (ld_node_index) begin
			ground_node = data_in[4:0];
			h5 = 7'b0101011; // 'n'
			h4 = 7'b1000000; // 'O'
			h3 = 7'b0100001; // 'd'
			h2 = 7'b0000110; // 'E'
			h1 = index_h1;
			h0 = index_h0;
		end
		
		if (~done_judge & go_judge_valid) begin
			node_index_valid = (ground_node < numNodes);
			done_judge = 1;
		end
		
		if (go_display_invalid) begin
			done_judge = 0;
			h5 = 7'b1111001; // 'I'
			h4 = 7'b0101011; // 'n'
			h3 = 7'b1000001; // 'U'
			h2 = 7'b0001000; // 'A'
			h1 = 7'b1000111; // 'L'
			h0 = 7'b0100001; // 'd'
		end
		
	end
	

endmodule


