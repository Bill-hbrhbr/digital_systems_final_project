module main_datapath(
		input run_drawSimpleCircuit,
		input [9:0] sw,
		
		input clk, program_initialize,
		
		// HEX Display
		output reg [6:0] h0, h1, h2, h3, h4, h5,
		
		// RAM: element 32x32
		output reg [4:0] element_addr = 0,
		output reg [31:0] element_data = 0,
		output reg element_wren = 0,
		
		// VGA Display
		output reg [9:0] vga_x = 0,
		output reg [8:0] vga_y = 0,
		output reg vga_in = 1, vga_wren = 0,
		
		// RAM: float_register 32x32
		output reg [4:0] float_register_addr = 0,
		output reg [31:0] float_register_data = 0,
		output reg float_register_wren = 0,
		
		// RAM: nodeHeads
		output reg [4:0] nodeHeads_addr = 0,
		output reg [63:0] nodeHeads_data = 0,
		output reg nodeHeads_wren = 0,
		
		// RAM: nodeToElement
		output reg [4:0] nodeToElement_addr = 0,
		output reg [63:0] nodeToElement_data = 0,
		output reg nodeToElement_wren = 0,
		
		// RAM: refNodes
		output reg [4:0] refNodes_addr = 0,
		output reg [4:0] refNodes_data = 0,
		output reg refNodes_wren = 0,
		
		// RAM: float_matrix
		output reg [11:0] matrix_addr_a = 0, matrix_addr_b = 0, 
		output reg [31:0] matrix_data_a = 0, matrix_data_b = 0,
		output reg matrix_wren_a = 0, matrix_wren_b = 0,
		
		// RAM: nodeVoltage
		output reg [4:0] nodeVoltage_addr = 0,
		output reg [31:0] nodeVoltage_data = 0,
		output reg nodeVoltage_wren = 0,
		
		// RAM: nodeSeq
		output reg [4:0] nodeSeq_addr = 0,
		output reg [4:0] nodeSeq_data = 0,
		output reg nodeSeq_wren = 0,
		
		// RAM: elementSeq
		output reg [4:0] elementSeq_addr = 0,
		output reg [4:0] elementSeq_data = 0,
		output reg elementSeq_wren = 0,
		
		// RAM: processor 1024x48
		output reg [9:0] processor_addr = 0,
		output reg [47:0] processor_data = 0,
		output reg processor_wren = 0,
		
		// RAMs: sprites
		output reg [11:0] vSprite_addr = 0,
		output reg [11:0] cSprite_addr = 0,
		output reg [11:0] rSprite_addr = 0,
		output reg [5:0] dot_addr = 0,
		
		
		// Stage 0: VGA
		input run_clearScreen,
		input [9:0] stage0_vga_x,
		input [8:0] stage0_vga_y,
		input stage0_vga_in,
		input stage0_vga_wren,
		
		
		// Stage 1: element RAM, HEX
		input run_getElement,
		input [4:0] stage1_element_addr,
		input [31:0] stage1_element_data,
		input stage1_element_wren,
		input [6:0] stage1_h0, stage1_h1, stage1_h2, stage1_h3, stage1_h4, stage1_h5,
		
		
		// Stage 2: element RAM
		input run_convertValues,
		input [4:0] stage2_element_addr,
		input stage2_element_wren,
		input [4:0] stage2_float_register_addr,
		input [31:0] stage2_float_register_data,
		input stage2_float_register_wren,
		
		// Stage 3
		input run_buildNodeList,
		input [4:0] stage3_element_addr,
		input stage3_element_wren,
		input [4:0] stage3_float_register_addr,
		input stage3_float_register_wren,
		input [4:0] stage3_nodeHeads_addr,
		input [63:0] stage3_nodeHeads_data,
		input stage3_nodeHeads_wren,
		input [4:0] stage3_nodeToElement_addr,
		input [63:0] stage3_nodeToElement_data,
		input stage3_nodeToElement_wren,
		
		// Stage 4
		input run_chooseRefNode,
		input [6:0] stage4_h5, stage4_h4, stage4_h3, stage4_h2, stage4_h1, stage4_h0,
		
		// Stage 5
		input run_searchSuperNode,
		input [4:0] stage5_nodeHeads_addr,
		input [63:0] stage5_nodeHeads_data,
		input stage5_nodeHeads_wren,
	
		input [4:0] stage5_nodeToElement_addr,
		input [63:0] stage5_nodeToElement_data,
		input stage5_nodeToElement_wren,
	
		input [4:0] stage5_refNodes_addr,
		input [4:0] stage5_refNodes_data,
		input stage5_refNodes_wren,
		
		// Stage 6
		input run_generateEquations,
		input [4:0] stage6_nodeHeads_addr,
		input stage6_nodeHeads_wren,
	
		input [4:0] stage6_nodeToElement_addr,
		input stage6_nodeToElement_wren,
		
		input [11:0] stage6_matrix_addr_a, stage6_matrix_addr_b, 
		input [31:0] stage6_matrix_data_a, stage6_matrix_data_b,
		input stage6_matrix_wren_a, stage6_matrix_wren_b,
		
		// Stage 7
		input run_solveMatrix,
		input [11:0] stage7_matrix_addr_a, stage7_matrix_addr_b, 
		input [31:0] stage7_matrix_data_a, stage7_matrix_data_b,
		input stage7_matrix_wren_a, stage7_matrix_wren_b,
		
		// Stage 8
		input run_calculateVoltage,
		input [4:0] stage8_nodeHeads_addr,
		input stage8_nodeHeads_wren,
	
		input [11:0] stage8_matrix_addr_a,
		input stage8_matrix_wren_a,
	
		input [4:0] stage8_nodeVoltage_addr,
		input [31:0] stage8_nodeVoltage_data,
		input stage8_nodeVoltage_wren,
		
		// Stage 9
		input run_sortSequence,
		input [4:0] stage9_nodeHeads_addr,
		input stage9_nodeHeads_wren,
	
		input [4:0] stage9_nodeSeq_addr,
		input [4:0] stage9_nodeSeq_data,
		input stage9_nodeSeq_wren,
		
		input [4:0] stage9_elementSeq_addr,
		input [4:0] stage9_elementSeq_data,
		input stage9_elementSeq_wren,
		
		// Stage 10
		input run_configureCircuit,
		input [4:0] stage10_nodeSeq_addr,
		input stage10_nodeSeq_wren,
		
		input [4:0] stage10_elementSeq_addr,
		input stage10_elementSeq_wren,
		
		input [9:0] stage10_processor_addr,
		input [47:0] stage10_processor_data,
		input stage10_processor_wren,
		
		input [4:0] stage10_element_addr,
		input stage10_element_wren,
		
		// Stage 11
		input run_drawCircuit,
		input [9:0] stage11_processor_addr,
		input stage11_processor_wren,
	
		input [9:0] stage11_vga_x,
		input [8:0] stage11_vga_y,
		input stage11_vga_in,
		input stage11_vga_wren,
		
		input [11:0] stage11_vSprite_addr,
		input [11:0] stage11_cSprite_addr,
		input [11:0] stage11_rSprite_addr,
		input [5:0] stage11_dot_addr

		/*
		// Stage 3
		input run_drawSimpleCircuit,
		input [4:0] simple_draw_element_addr,
		input [11:0] simple_draw_sprite_addr,
		input [5:0] simple_draw_dot_addr,
		input [9:0] simple_vga_x,
		input [8:0] simple_vga_y,
		input simple_vga_in, simple_vga_write,
		
		
		*/
);
	
	always @(*) begin: datapath
		// VGA
		vga_x = 0;
		vga_y = 0;
		vga_in = 1;
		vga_wren = 0;
		
		// RAM: element 32x32
		element_addr = 0;
		element_data = 0;
		element_wren = 0;
		
		// RAM: float_register 32x32
		float_register_addr = 0;
		float_register_data = 0;
		float_register_wren = 0;
		
		// RAM: nodeHeads 48x32
		nodeHeads_addr = 0;
		nodeHeads_data = 0;
		nodeHeads_wren = 0;
		
		// RAM: nodeToElement 64x32
		nodeToElement_addr = 0;
		nodeToElement_data = 0;
		nodeToElement_wren = 0;
		
		// RAM: refNodes 5x32
		refNodes_addr = 0;
		refNodes_data = 0;
		refNodes_wren = 0;
		
		// RAM: float_matrix 4096x32
		matrix_addr_a = 0;
		matrix_addr_b = 0; 
		matrix_data_a = 0;
		matrix_data_b = 0;
		matrix_wren_a = 0;
		matrix_wren_b = 0;
		
		// RAM: nodeVoltage 32x32
		nodeVoltage_addr = 0;
		nodeVoltage_data = 0;
		nodeVoltage_wren = 0;
		
		// RAM: nodeSeq
		nodeSeq_addr = 0;
		nodeSeq_data = 0;
		nodeSeq_wren = 0;
		
		// RAM: elementSeq
		elementSeq_addr = 0;
		elementSeq_data = 0;
		elementSeq_wren = 0;
		
		// RAM: processor 1024x32
		processor_addr = 0;
		processor_data = 0;
		processor_wren = 0;
		
		// RAMs: sprites
		vSprite_addr = 0;
		cSprite_addr = 0;
		rSprite_addr = 0;
		dot_addr = 0;
		
		// Stage 0
		if (run_clearScreen) begin
			vga_x = stage0_vga_x;
			vga_y = stage0_vga_y;
			vga_in = stage0_vga_in;
			vga_wren = stage0_vga_wren;
		end
		
		// Stage 1
		if (run_getElement) begin
			element_addr = stage1_element_addr;
			element_data = stage1_element_data;
			element_wren = stage1_element_wren;
		end
		
		// Stage 2
		if (run_convertValues) begin
			element_addr = stage2_element_addr;
			element_wren = stage2_element_wren;
			float_register_addr = stage2_float_register_addr;
			float_register_data = stage2_float_register_data;
			float_register_wren = stage2_float_register_wren;		
		end
		
		// Stage 3
		if (run_buildNodeList) begin
			element_addr = stage3_element_addr;
			element_wren = stage3_element_wren;
		
			float_register_addr = stage3_float_register_addr;
			float_register_wren = stage3_float_register_wren;
			
			nodeHeads_addr = stage3_nodeHeads_addr;
			nodeHeads_data = stage3_nodeHeads_data;
			nodeHeads_wren = stage3_nodeHeads_wren;
			
			nodeToElement_addr = stage3_nodeToElement_addr;
			nodeToElement_data = stage3_nodeToElement_data;
			nodeToElement_wren = stage3_nodeToElement_wren;
		end
		
		// Stage 5
		if (run_searchSuperNode) begin
			nodeHeads_addr = stage5_nodeHeads_addr;
			nodeHeads_data = stage5_nodeHeads_data;
			nodeHeads_wren = stage5_nodeHeads_wren;
			
			nodeToElement_addr = stage5_nodeToElement_addr;
			nodeToElement_data = stage5_nodeToElement_data;
			nodeToElement_wren = stage5_nodeToElement_wren;
			
			refNodes_addr = stage5_refNodes_addr;
			refNodes_data = stage5_refNodes_data;
			refNodes_wren = stage5_refNodes_wren;
		end
		
		// Stage 6
		if (run_generateEquations) begin
			nodeHeads_addr = stage6_nodeHeads_addr;
			nodeHeads_wren = stage6_nodeHeads_wren;
			
			nodeToElement_addr = stage6_nodeToElement_addr;
			nodeToElement_wren = stage6_nodeToElement_wren;
			
			//refNodes_addr = stage6_refNodes_addr;
			//refNodes_wren = stage6_refNodes_wren;
	
			matrix_addr_a = stage6_matrix_addr_a;
			matrix_addr_b = stage6_matrix_addr_b; 
			matrix_data_a = stage6_matrix_data_a;
			matrix_data_b = stage6_matrix_data_b;
			matrix_wren_a = stage6_matrix_wren_a;
			matrix_wren_b = stage6_matrix_wren_b;
		end
		
		// Stage 7
		if (run_solveMatrix) begin
			matrix_addr_a = stage7_matrix_addr_a;
			matrix_addr_b = stage7_matrix_addr_b; 
			matrix_data_a = stage7_matrix_data_a;
			matrix_data_b = stage7_matrix_data_b;
			matrix_wren_a = stage7_matrix_wren_a;
			matrix_wren_b = stage7_matrix_wren_b;
		end
		
		// Stage 8
		if (run_calculateVoltage) begin
			nodeHeads_addr = stage8_nodeHeads_addr;
			nodeHeads_wren = stage8_nodeHeads_wren;
			
			matrix_addr_a = stage8_matrix_addr_a;
			matrix_wren_a = stage8_matrix_wren_a;
			//matrix_addr_b = stage8_matrix_addr_b;
			//matrix_wren_b = stage8_matrix_wren_b;

			nodeVoltage_addr = stage8_nodeVoltage_addr;
			nodeVoltage_data = stage8_nodeVoltage_data;
			nodeVoltage_wren = stage8_nodeVoltage_wren;
		end
		
		// Stage 9
		if (run_sortSequence) begin
			nodeHeads_addr = stage9_nodeHeads_addr;
			nodeHeads_wren = stage9_nodeHeads_wren;
			
			nodeSeq_addr = stage9_nodeSeq_addr;
			nodeSeq_data = stage9_nodeSeq_data;
			nodeSeq_wren = stage9_nodeSeq_wren;
		
			elementSeq_addr = stage9_elementSeq_addr;
			elementSeq_data = stage9_elementSeq_data;
			elementSeq_wren = stage9_elementSeq_wren;
		end
		
		// Stage 10
		if (run_configureCircuit) begin
			nodeSeq_addr = stage10_nodeSeq_addr;
			nodeSeq_wren = stage10_nodeSeq_wren;
			
			elementSeq_addr = stage10_elementSeq_addr;
			elementSeq_wren = stage10_elementSeq_wren;
		
			processor_addr = stage10_processor_addr;
			processor_data = stage10_processor_data;
			processor_wren = stage10_processor_wren;
			
			element_addr = stage10_element_addr;
			element_wren = stage10_element_wren;
		end
		 
		// Stage 11
		if (run_drawCircuit) begin
			processor_addr = stage11_processor_addr;
			processor_wren = stage11_processor_wren;
	
			vga_x = stage11_vga_x;
			vga_y = stage11_vga_y;
			vga_in = stage11_vga_in;
			vga_wren = stage11_vga_wren;
			
			vSprite_addr = stage11_vSprite_addr;
			cSprite_addr = stage11_cSprite_addr;
			rSprite_addr = stage11_rSprite_addr;
			dot_addr = stage11_dot_addr;
			
		end
		
		
		/*
		if (run_drawSimpleCircuit) begin
			float_register_addr = sw[4:0];
			float_register_wren = 0;
		end
		*/
		/*
		if (run_drawSimpleCircuit) begin
			element_address = simple_draw_element_addr;
			vSprite_addr = simple_draw_sprite_addr;
			cSprite_addr = simple_draw_sprite_addr;
			rSprite_addr = simple_draw_sprite_addr;
			dot_addr = simple_draw_dot_addr;
			vga_x = simple_vga_x;
			vga_y = simple_vga_y;
			vga_in = simple_vga_in;
			vga_writeEn = simple_vga_write;
		end
		*/
	end
	
	always @(*) begin: hexdata
		h5 = 7'b1111111;
		h4 = 7'b1111111;
		h3 = 7'b1111111;
		h2 = 7'b1111111;
		h1 = 7'b1111111;
		h0 = 7'b1111111;
		
		if (program_initialize) begin
			h5 = 7'b0010010; // 'S'
			h4 = 7'b0000111; // 't'
			h3 = 7'b0001000; // 'A'
			h2 = 7'b0101111; // 'r'
			h1 = 7'b0000111; // 't'
			h0 = 7'b1111111;
		end
		
		if (run_getElement) begin
			h5 = stage1_h5;
			h4 = stage1_h4;
			h3 = stage1_h3;
			h2 = stage1_h2;
			h1 = stage1_h1;
			h0 = stage1_h0;
		end
		
		if (run_chooseRefNode) begin
			h5 = stage4_h5;
			h4 = stage4_h4;
			h3 = stage4_h3;
			h2 = stage4_h2;
			h1 = stage4_h1;
			h0 = stage4_h0;
		end
		
	end

endmodule
