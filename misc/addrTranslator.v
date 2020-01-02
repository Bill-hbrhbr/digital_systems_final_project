module nodeAddresstoPosTranslator(
		input [4:0] numNodes,
		//input [4:0] nodeA, nodeB,
		output reg [53:0] node_vga_pos
		//output reg [8:0] nodeA_pos, nodeB_pos
	);
	
	always @(*) begin
		case (numNodes)
			2: node_vga_pos = {9'd475, 9'd5, {9{1'b0}}, {9{1'b0}}, {9{1'b0}}, {9{1'b0}}};
			3: node_vga_pos = {9'd475, 9'd240, 9'd5, {9{1'b0}}, {9{1'b0}}, {9{1'b0}}};
			4: node_vga_pos = {9'd475, 9'd318, 9'd162, 9'd5, {9{1'b0}}, {9{1'b0}}};
			5: node_vga_pos = {9'd475, 9'd358, 9'd240, 9'd122, 9'd5, {9{1'b0}}};
			6: node_vga_pos = {9'd473, 9'd380, 9'd287, 9'd194, 9'd101, 9'd8};
			default node_vga_pos = 0;
		endcase
	end
	/*
	always @(*) begin
		case (nodeA)
			5: nodeA_pos = node_vga_pos[8:0];
			4: nodeA_pos = node_vga_pos[17:9];
			3: nodeA_pos = node_vga_pos[26:18];
			2: nodeA_pos = node_vga_pos[35:27];
			1: nodeA_pos = node_vga_pos[44:36];
			0: nodeA_pos = node_vga_pos[53:45];
			default: nodeA_pos = {8{1'b0}};
		endcase
		
		case (nodeB)
			5: nodeB_pos = node_vga_pos[8:0];
			4: nodeB_pos = node_vga_pos[17:9];
			3: nodeB_pos = node_vga_pos[26:18];
			2: nodeB_pos = node_vga_pos[35:27];
			1: nodeB_pos = node_vga_pos[44:36];
			0: nodeB_pos = node_vga_pos[53:45];
			default: nodeB_pos = {8{1'b1}};
		endcase
	end
	*/
endmodule
