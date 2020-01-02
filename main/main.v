`timescale 1ns/1ns

module final_project(
		input CLOCK_50,
		input [3:0] KEY,
		input [9:0] SW,
		output [9:0] LEDR,
		output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
		
		
		
		output VGA_CLK,   						//	VGA Clock
		output VGA_HS,							//	VGA H_SYNC
		output VGA_VS,							//	VGA V_SYNC
		output VGA_BLANK_N,						//	VGA BLANK
		output VGA_SYNC_N,						//	VGA SYNC
		output [7:0] VGA_R,   						//	VGA Red[9:0]
		output [7:0] VGA_G,	 						//	VGA Green[9:0]
		output [7:0] VGA_B   						//	VGA Blue[9:0]
	);
	
	
	
	
	localparam screen_width = 10'd640,
	           screen_height = 9'd480,
				  width_offset = 5'd20,
				  height_offset = 3'd5;
				  
	wire [9:0] actual_width;
	assign actual_width = screen_width - 2 * width_offset;
	wire [8:0] actual_height;
	assign actual_height = screen_height - 2 * height_offset;
	
	
	
	/*
	// Main Controller Handshake Signals
	wire clearScreen_done, getElement_done, buildNodeList_done, drawSimpleCircuit_done;
	wire program_initialize, run_getElement, run_drawSimpleCircuit, run_buildNodeList, run_calculateVoltage;
	
	// Stage 0: Clear Screen
	wire [9:0] clear_vga_x;
	wire [8:0] clear_vga_y;
	wire clear_vga_in, clear_vga_write;
	
	// Stage 1: Handshake signals
	wire getElement_fullReset, getElement_singleReset, do_display, ld_type, ld_value, ld_nodes, ld_memory, inc_count, element_reset;
	wire count_increased, getElement_resetDone;
	
	// Stage 1: Element RAM inputs
	wire new_element_info_writeEn;
	wire [3:0] new_element_index;
	wire [23:0] new_element_input;
	wire [6:0] getElement_h0, getElement_h1, getElement_h2, getElement_h3, getElement_h4, getElement_h5;
	
	
	
	// Stage 3: Handshake signals
	wire got_width, draw_line, sprite_chosen, wire_drew, sprite_drew, simple_drew_all_elements;
	wire draw_simple_data_reset, calc_width, line_drew, choose_sprite, draw_wire, draw_sprite;
	
	// Stage 3: RAM inputs
	wire [4:0] simple_draw_element_addr;
	wire [11:0] simple_draw_sprite_addr;
	wire [9:0] simple_draw_dot_addr;
		
	wire [9:0] simple_vga_x;
	wire [8:0] simple_vga_y;
	wire simple_vga_in, simple_vga_write;
	

	*/
	
	
	
	/* Sprites: voltage source, current source, resistor, node point*/
	
	
	// name: vSprite
	// 1-bit wide, 4096 words (44x93+4)
	// stores the sprite of the voltage source
	wire [11:0] vSprite_addr;
	wire vSprite_out;

	vSprite S1(
		.address(vSprite_addr),
		.clock(CLOCK_50),
		.q(vSprite_out)
	);
	
	// name: cSprite
	// 1-bit wide, 4096 words (44x93+4)
	// stores the sprite of the current source
	wire [11:0] cSprite_addr;
	wire cSprite_out;
	
	cSprite S2(
		.address(cSprite_addr),
		.clock(CLOCK_50),
		.q(cSprite_out)
	);
	
	// name: rSprite
	// 1-bit wide, 4096 words (44x93+4)
	// stores the sprite of the resistor source
	wire [11:0] rSprite_addr;
	wire rSprite_out;
	
	rSprite S3(
		.address(rSprite_addr),
		.clock(CLOCK_50),
		.q(rSprite_out)
	);
	
	// name: dot
	// 1-bit wide, 64 words (6x10+4)
	// stores the sprite of the node intersection dot
	wire [5:0] dot_addr;
	wire dot_out;
	
	dot S4(
		.address(dot_addr),
		.clock(CLOCK_50),
		.q(dot_out)
	);
	
	
	
	// name: element
	// 32-bit wide, 32 words (max 32 elements)
	// bit [31:27]: node A number
	// bit [26:22]: node B number
	/* bit [21:20]: element type
		00 - independent voltage source
		01 - independent current source
		10 - resistor
		11 - undefined
	*/
	// bit [19:10]: element exponent
	// bit [9:0]: element value
	
	wire [4:0] element_addr;
	wire [31:0] element_data;
	wire element_wren;
	wire [31:0] element_out;
	
	element M1(
		.address(element_addr),
		.clock(CLOCK_50),
		.data(element_data),
		.wren(element_wren),
		.q(element_out)
	);
	
	
	// name: float_register
	// 32-bit wide, 32 words, each word a single floating point number
	// bit [31:0]: the floating point number
	// Resistor values are stored as their reciprocals versions, aka conductance
	
	wire [4:0] float_register_addr;
	wire [31:0] float_register_data;
	wire float_register_wren;
	wire [31:0] float_register_out;
	
	float_register M2(
		.address(float_register_addr),
		.clock(CLOCK_50),
		.data(float_register_data),
		.wren(float_register_wren),
		.q(float_register_out)
	);
	
	/*
	always @(*) begin
		case (SW[6:5])
			0: LEDR = float_register_out[7:0];
			1: LEDR = float_register_out[15:8];
			2: LEDR = float_register_out[23:16];
			3: LEDR = float_register_out[31:24];
		endcase
	end
	*/
	
	
	// name: nodeHeads
	// 64-bit wide, 32 words
	// bit [63]: 0-not builded, 1-builded
	// bit [62]: 0-ref node not set, 1-ref node set
	
	// bit [61:50]: unused
	
	// bit [51:47]: current `nodeToElement` address for searching/traversing
	// bit [46:42]: address of the first connected element in  `nodeToElement`
	// bit [41:37]: index of the corresponding node row in the system of linear equations
	// bit [36:32]: address of the reference node in `nodeHeads`
	
	/* bit [31:0]: voltage value difference with respect to the ref node
			value is in floating-point format
			value is 0 if the ref node is itself
			value of the current node - value of the 
	*/
	
	
	wire [4:0] nodeHeads_addr;
	wire [63:0] nodeHeads_data;
	wire nodeHeads_wren;
	wire [63:0] nodeHeads_out;
	
	nodeHeads M3(
		.address(nodeHeads_addr),
		.clock(CLOCK_50),
		.data(nodeHeads_data),
		.wren(nodeHeads_wren),
		.q(nodeHeads_out)
	);
	
	
	// name: nodeToElement
	// 64-bit wide, 32 words
	// bit [63]: 0-is not end of the list; 1-is the end of the list
	// bit [62:58]: address of the next element
	
	// bit [57:45]: unused
	
	// bit [44]: the current node is the node 0-A/1-B of this element 
	// bit [43:39]: address of the other node of the element
	// bit [38:34]: address of the current node
	/* bit [33:32]: element type
		00 - independent voltage source
		01 - independent current source
		10 - resistor
		11 - undefined
	*/ 
	// bit [31:0]: element value in floating point
	
	
	wire [4:0] nodeToElement_addr;
	wire [63:0] nodeToElement_data;
	wire nodeToElement_wren;
	wire [63:0] nodeToElement_out;
	
	nodeToElement M4(
		.address(nodeToElement_addr),
		.clock(CLOCK_50),
		.data(nodeToElement_data),
		.wren(nodeToElement_wren),
		.q(nodeToElement_out)
	);
	
	
	
	// name: refNodes
	// 5-bit wide, 32 words
	// bit [4:0]: address of the reference nodes
	
	wire [4:0] refNodes_addr;
	wire [4:0] refNodes_data;
	wire refNodes_wren;
	wire [4:0] refNodes_out;
	
	refNodes M5(
		.address(refNodes_addr),
		.clock(CLOCK_50),
		.data(refNodes_data),
		.wren(refNodes_wren),
		.q(refNodes_out)
	);
	
	
	// 4096 numbers
	// Largest: 11x12 Augmented matrix: 11 rows, 12 cols
	// Last row for storing temporary numbers
	// Two port 32-bit wide
	// 0 <= x <= dim (with constant vector)
	// 0 <= y <= dim - 1
	
	wire [11:0] matrix_addr_a, matrix_addr_b; 
	wire [31:0] matrix_data_a, matrix_data_b;
	wire [31:0] matrix_out_a, matrix_out_b;
	wire matrix_wren_a, matrix_wren_b;
	
	float_matrix M6(
		.clock(CLOCK_50),
		.address_a(matrix_addr_a),
		.address_b(matrix_addr_b),
		.data_a(matrix_data_a),
		.data_b(matrix_data_b),
		.wren_a(matrix_wren_a),
		.wren_b(matrix_wren_b),
		.q_a(matrix_out_a),
		.q_b(matrix_out_b)
	);
	
	
	// name: nodeVoltage
	// 32-bit wide, 32 words
	// For storing the final values of the voltage nodes
	// bit [19:10]: exponent
	// bit [9:0]: the integer number
	
	wire [4:0] nodeVoltage_addr;
	wire [31:0] nodeVoltage_data;
	wire nodeVoltage_wren;
	wire [31:0] nodeVoltage_out;
	
	nodeVoltage M7(
		.address(nodeVoltage_addr),
		.clock(CLOCK_50),
		.data(nodeVoltage_data),
		.wren(nodeVoltage_wren),
		.q(nodeVoltage_out)
	);
	
	// name: nodeSeq
	// 5-bit wide, 32 words
	// For storing the sequence that the node lines are drawn (from bottom to top)
	wire [4:0] nodeSeq_addr;
	wire [4:0] nodeSeq_data;
	wire nodeSeq_wren;
	wire [4:0] nodeSeq_out;
	
	nodeSeq M8(
		.address(nodeSeq_addr),
		.clock(CLOCK_50),
		.data(nodeSeq_data),
		.wren(nodeSeq_wren),
		.q(nodeSeq_out)
	);
	
	// name: elementSeq
	// 5-bit wide, 32 words
	// For storing the sequence that the elements are drawn (from left to right)
	wire [4:0] elementSeq_addr;
	wire [4:0] elementSeq_data;
	wire elementSeq_wren;
	wire [4:0] elementSeq_out;
	
	elementSeq M9(
		.address(elementSeq_addr),
		.clock(CLOCK_50),
		.data(elementSeq_data),
		.wren(elementSeq_wren),
		.q(elementSeq_out)
	);
	
	// name: draw_processor
	// Handle: filled node lines, dashed node lines, straight wires, vSprite, cSprite, rSprite, dot, 
	// mouse normal sprite, mouse select sprite, mouser grab sprite, digits, decimal point, 'E', `V`, `A`, `ohm`
	// 47-bit, 1024 words
	// bit [47]: 1-do this command; 0-skip this command
	// bit [46:38]: the type of stuff being drawed
	// bit [37:29]: height of the shape
	// bit [28:19]: width of the shape
	// bit [18:10]: topmost position
	// bit [9:0]: leftmost position
	
	wire [9:0] processor_addr;
	wire [47:0] processor_data;
	wire processor_wren;
	wire [47:0] processor_out;
	
	draw_processor My_CPU(
		.address(processor_addr),
		.clock(CLOCK_50),
		.data(processor_data),
		.wren(processor_wren),
		.q(processor_out)
	);
	
	
	wire [9:0] vga_x;
	wire [8:0] vga_y;
	wire vga_in, vga_wren;
	
	
	wire [3:0] cs, ns;
	wire [3:0] cs5, ns5;
	assign LEDR[3:0] = cs;
	wire [3:0] cs9, ns9;
	wire [4:0] cs10, ns10;
	wire [3:0] cs11, ns11;
	/*
	wire [3:0] cs2, ns2;
	wire [3:0] cs3, ns3;
	wire [3:0] cs4, ns4;
	
	wire [3:0] cs6, ns6;
	wire [3:0] cs7, ns7;
	wire [3:0] cs8, ns8;
	*/
	
	wire [4:0] numElements, numNodes, numRefNodes;
	
	wire [4:0] ground_node; // Address of the grounded node
	wire [53:0] node_vga_pos; // Vertical positions of nodelines
	wire [9:0] numCommands; // Number of commands that the drawer processes
	
	assign LEDR[9:4] = numCommands[5:0];
	
	/*
	wire [31:0] int_to_fp_data, int_to_fp_out, multiplier_data_a, multiplier_data_b, multiplier_out;
	wire [31:0] divider_data_a, divider_data_b, divider_out;
	wire [31:0] adder_data_a, adder_data_b, adder_out, subtractor_data_a, subtractor_data_b, subtractor_out;
	*/
	
	/*
	wire [31:0] fp_to_int_data, fp_to_int_out, multiplier_data_a, multiplier_data_b, multiplier_out;
	wire [31:0] adder_data_a, adder_data_b, adder_out;
	*/

	// Input handshakes
	wire go_reset_data, go_calculate_width, go_set_element_seq, go_choose_next_node, go_check_node, go_set_node_seq;
		
	// Output hanshakes
	wire data_reset_done, width_calculated, element_seq_set, node_chosen, all_nodes_set, node_checked, node_valid, node_seq_set;
	
	// KEY[0] to reset the whole program
	// KEY[1] to start loading element values
	main_logic MAIN_MODULE(
		// Input hanshakes
		.data_reset_done(data_reset_done),
		.width_calculated(width_calculated),
		.element_seq_set(element_seq_set),
		.node_chosen(node_chosen),
		.all_nodes_set(all_nodes_set),
		.node_checked(node_checked),
		.node_valid(node_valid),
		.node_seq_set(node_seq_set),
		
		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_calculate_width(go_calculate_width),
		.go_set_element_seq(go_set_element_seq),
		.go_choose_next_node(go_choose_next_node),
		.go_check_node(go_check_node),
		.go_set_node_seq(go_set_node_seq),

		.cs(cs),
		.ns(ns),
		.cs5(cs5),
		.ns5(ns5),
		.cs9(cs9),
		.ns9(ns9),
		.cs10(cs10),
		.ns10(ns10),
		.cs11(cs11),
		.ns11(ns11),
		/*
		.cs1(cs1),
		.ns1(ns1),
		.cs2(cs2),
		.ns2(ns2),
		.cs3(cs3),
		.ns3(ns3),
		.cs4(cs4),
		.ns4(ns4),
		.cs5(cs5),
		.ns5(ns5),
		.cs6(cs6),
		.ns6(ns6),
		.cs7(cs7),
		.ns7(ns7),
		.cs8(cs8),
		.ns8(ns8),
		*/
		
		.numElements(numElements),
		.numNodes(numNodes),
		.numRefNodes(numRefNodes),
		.ground_node(ground_node),
		.node_vga_pos(node_vga_pos),
		.numCommands(numCommands),
		
		// FPGA inputs
		.clk(CLOCK_50),
		.key(KEY),
		.sw(SW),
		
		// HEX Display
		.h0(HEX0),
		.h1(HEX1),
		.h2(HEX2),
		.h3(HEX3),
		.h4(HEX4),
		.h5(HEX5),
		
		// VGA Display
		.vga_x(vga_x),
		.vga_y(vga_y),
		.vga_in(vga_in),
		.vga_wren(vga_wren),
		
		// RAM: element
		.element_addr(element_addr),
		.element_data(element_data),
		.element_wren(element_wren),
		.element_out(element_out),
		
		// RAM: float_register
		.float_register_addr(float_register_addr),
		.float_register_data(float_register_data),
		.float_register_wren(float_register_wren),
		.float_register_out(float_register_out),
		
		// RAM: nodeHeads
		.nodeHeads_addr(nodeHeads_addr),
		.nodeHeads_data(nodeHeads_data),
		.nodeHeads_wren(nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// RAM: nodeToElement
		.nodeToElement_addr(nodeToElement_addr),
		.nodeToElement_data(nodeToElement_data),
		.nodeToElement_wren(nodeToElement_wren),
		.nodeToElement_out(nodeToElement_out),
		
		// RAM: refNodes
		.refNodes_addr(refNodes_addr),
		.refNodes_data(refNodes_data),
		.refNodes_wren(refNodes_wren),
		.refNodes_out(refNodes_out),
		
		// RAM: float_matrix
		.matrix_addr_a(matrix_addr_a),
		.matrix_addr_b(matrix_addr_b),
		.matrix_data_a(matrix_data_a),
		.matrix_data_b(matrix_data_b),
		.matrix_wren_a(matrix_wren_a),
		.matrix_wren_b(matrix_wren_b),
		.matrix_out_a(matrix_out_a),
		.matrix_out_b(matrix_out_b),
		
		// RAM: nodeVoltage
		.nodeVoltage_addr(nodeVoltage_addr),
		.nodeVoltage_data(nodeVoltage_data),
		.nodeVoltage_wren(nodeVoltage_wren),
		.nodeVoltage_out(nodeVoltage_out),
		
		// RAM: nodeSeq
		.nodeSeq_addr(nodeSeq_addr),
		.nodeSeq_data(nodeSeq_data),
		.nodeSeq_wren(nodeSeq_wren),
		.nodeSeq_out(nodeSeq_out),
		
		// RAM: elementSeq
		.elementSeq_addr(elementSeq_addr),
		.elementSeq_data(elementSeq_data),
		.elementSeq_wren(elementSeq_wren),
		.elementSeq_out(elementSeq_out),
		
		// RAM: draw_processor
		.processor_addr(processor_addr),
		.processor_data(processor_data),
		.processor_wren(processor_wren),
		.processor_out(processor_out),
		
		// ROM: vSprite
		.vSprite_addr(vSprite_addr),
		.vSprite_out(vSprite_out),
		
		// ROM: cSprite
		.cSprite_addr(cSprite_addr),
		.cSprite_out(cSprite_out),
		
		// ROM: rSprite
		.rSprite_addr(rSprite_addr),
		.rSprite_out(rSprite_out),
		
		// ROM: dot
		.dot_addr(dot_addr),
		.dot_out(dot_out)
		
	);

	
	nodeAddresstoPosTranslator T1(
		.numNodes(numNodes),
		.node_vga_pos(node_vga_pos)
	);
	
	
	
	/*
	wire [3:0] numElements;
	assign numElements = new_element_index;
	*/
	/*
	wire [53:0] node_vga_pos;
	nodeAddresstoPosTranslator(numNodes, node_vga_pos);
	*/
	
	/*
	
	drawSimpleCircuit_control C3(
		.clk(CLOCK_50),
		.program_resetn(KEY[0]),
		.start_process(run_drawSimpleCircuit), 
		.end_process(drawSimpleCircuit_done),
		
		.got_width(got_width),
		.line_drew(line_drew),
		.sprite_chosen(sprite_chosen),
		.wire_drew(wire_drew),
		.sprite_drew(sprite_drew),
		.node_A_drew(node_A_drew),
		.node_B_drew(node_B_drew),
		.drew_all_elements(simple_drew_all_elements),
		
		
		.data_reset(draw_simple_data_reset), 
		.calc_width(calc_width),
		.draw_line(draw_line),
		.choose_sprite(choose_sprite),
		.draw_wire(draw_wire), 
		.draw_sprite(draw_sprite),
		.draw_node_A(draw_node_A),
		.draw_node_B(draw_node_B),
	);
	
	
	drawSimpleCircuit_datapath D3(
		.clk(CLOCK_50),
		.data_reset(draw_simple_data_reset), 
		.calc_width(calc_width),
		.draw_line(draw_line),
		.choose_sprite(choose_sprite),
		.draw_wire(draw_wire), 
		.draw_sprite(draw_sprite),
		.draw_node_A(draw_node_A),
		.draw_node_B(draw_node_B),
		
		.numElements(4), 
		.numNodes(3),
		
		.screenWidth(actual_width),
		
		// outputs
		.got_width(got_width),
		.line_drew(line_drew),
		.sprite_chosen(sprite_chosen),
		.wire_drew(wire_drew),
		.sprite_drew(sprite_drew),
		.node_A_drew(node_A_drew),
		.node_B_drew(node_B_drew),
		.drew_all_elements(simple_drew_all_elements),
		
		
		// inputs into memory
		.element_index(simple_draw_element_addr),
		.sprite_address(simple_draw_sprite_addr),
		.dot_address(simple_draw_dot_addr),
		.vga_x(simple_vga_x),
		.vga_y(simple_vga_y),
		.vga_in(simple_vga_in), 
		.vga_write(simple_vga_write),
		
		
		// outputs from memory
		.element_data(element_mem_out),
		.vSprite_out(vSprite_out),
		.cSprite_out(cSprite_out),
		.rSprite_out(rSprite_out),
		.dot_out(dot_out),
	);
	
	*/
	
	/* Stage 2 Control Path
	   KEY[0] to reset the whole program
	*/
	
	



	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(vga_in),
			.x(vga_x),
			.y(vga_y),
			.plot(vga_wren),
			// Signals for the DAC to drive the monitor.
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.MONOCHROME = "TRUE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "white_640x480.mif";
	
endmodule
