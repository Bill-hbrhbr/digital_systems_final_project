module main_logic(
		// Input handshakes
		output go_reset_data, go_calculate_width, go_set_element_seq, go_choose_next_node, go_check_node, go_set_node_seq,
		
		// Output hanshakes
		output data_reset_done, width_calculated, element_seq_set, node_chosen, all_nodes_set, node_checked, node_valid, node_seq_set,
		
		
		output [3:0] cs, ns,
		output [3:0] cs5, ns5,
		output [3:0] cs9, ns9,
		output [4:0] cs10, ns10,
		output [3:0] cs11, ns11,
/*
		output [3:0] cs2, ns2,
		output [3:0] cs3, ns3,
		output [3:0] cs4, ns4,
		
		output [3:0] cs6, ns6,
		output [3:0] cs7, ns7,
		output [3:0] cs8, ns8,
*/	
		output [4:0] numElements,
		output [4:0] numNodes,
		output [4:0] numRefNodes,
		output [4:0] ground_node,
		output [9:0] block_width,
		input [53:0] node_vga_pos,
		output [9:0] numCommands,

		input clk,
		input [3:0] key,
		input [9:0] sw,
		
		// Hex Display
		output [6:0] h0, h1, h2, h3, h4, h5,

		// VGA Display
		output [9:0] vga_x,
		output [8:0] vga_y,
		output vga_in, vga_wren,
		
		// RAM: element 32x32
		output [4:0] element_addr,
		output [31:0] element_data,
		output element_wren,
		input [31:0] element_out,
	
		// RAM: float_register 32x32
		output [4:0] float_register_addr,
		output [31:0] float_register_data,
		output float_register_wren,
		input [31:0] float_register_out,
		
		// RAM: nodeHeads 64x32
		output [4:0] nodeHeads_addr,
		output [63:0] nodeHeads_data,
		output nodeHeads_wren,
		input [63:0] nodeHeads_out,
		
		// RAM: nodeToElement 64x32
		output [4:0] nodeToElement_addr,
		output [63:0] nodeToElement_data,
		output nodeToElement_wren,
		input [63:0] nodeToElement_out,
		
		// RAM: refNodes 5x32
		output [4:0] refNodes_addr,
		output [4:0] refNodes_data,
		output refNodes_wren,
		input [4:0] refNodes_out,
		
		// RAM: float_matrix 4096x32
		output [11:0] matrix_addr_a, matrix_addr_b, 
		output [31:0] matrix_data_a, matrix_data_b,
		output matrix_wren_a, matrix_wren_b,
		input [31:0] matrix_out_a, matrix_out_b,
		
		// RAM: nodeVoltage 32x32
		output [4:0] nodeVoltage_addr,
		output [31:0] nodeVoltage_data,
		output nodeVoltage_wren,
		input [31:0] nodeVoltage_out,
		
		// RAM: nodeSeq
		output [4:0] nodeSeq_addr,
		output [4:0] nodeSeq_data,
		output nodeSeq_wren,
		input [4:0] nodeSeq_out,
		
		// RAM: elementSeq
		output [4:0] elementSeq_addr,
		output [4:0] elementSeq_data,
		output elementSeq_wren,
		input [4:0] elementSeq_out,
		
		// RAM: processor 1024x48
		output [9:0] processor_addr,
		output [47:0] processor_data,
		output processor_wren,
		input [47:0] processor_out,
		
		// ROMs: circuit element sprites
		output [11:0] vSprite_addr,
		output [11:0] cSprite_addr,
		output [11:0] rSprite_addr,
		output [5:0] dot_addr,
		input vSprite_out,
		input cSprite_out,
		input rSprite_out,
		input dot_out
		
		
	);

	// Run Signals (Data)
	wire program_initialize, run_clearScreen, run_getElement, run_convertValues, run_buildNodeList, run_chooseRefNode;
	wire run_searchSuperNode, run_generateEquations, run_solveMatrix, run_calculateVoltage;
	
	// Done Signals (Data)
	wire clearScreen_done, getElement_done, valueConversion_done, buildNodeList_done, chooseRefNode_done;
	wire searchSuperNode_done, generateEquations_done, solveMatrix_done, calculateVoltage_done;
	
	// Run Signals (Visual)
	wire run_sortSequence, run_configureCircuit, run_drawCircuit;
	
	// Done Signals (Visual)
	wire sortSequence_done, configureCircuit_done, drawCircuit_done;
	
	// Stage 0
	wire [9:0] stage0_vga_x;
	wire [8:0] stage0_vga_y;
	wire stage0_vga_in, stage0_vga_wren;
	
	// Stage 1
	wire [6:0] stage1_h5, stage1_h4, stage1_h3, stage1_h2, stage1_h1, stage1_h0;
	
	wire [4:0] stage1_element_addr;
	wire [31:0] stage1_element_data;
	wire stage1_element_wren;
	
	// Stage 2
	wire [4:0] stage2_element_addr;
	wire stage2_element_wren;
	
	wire [4:0] stage2_float_register_addr;
	wire [31:0] stage2_float_register_data;
	wire stage2_float_register_wren;
	
	// Stage 3
	wire [4:0] stage3_element_addr;
	wire stage3_element_wren;
	
	wire [4:0] stage3_float_register_addr;
	wire stage3_float_register_wren;
	
	wire [4:0] stage3_nodeHeads_addr;
	wire [63:0] stage3_nodeHeads_data;
	wire stage3_nodeHeads_wren;
	
	wire [4:0] stage3_nodeToElement_addr;
	wire [63:0] stage3_nodeToElement_data;
	wire stage3_nodeToElement_wren;
	
	// Stage 4
	wire [6:0] stage4_h5, stage4_h4, stage4_h3, stage4_h2, stage4_h1, stage4_h0;
	
	
	// Stage 5
	wire [4:0] stage5_nodeHeads_addr;
	wire [63:0] stage5_nodeHeads_data;
	wire stage5_nodeHeads_wren;
	
	wire [4:0] stage5_nodeToElement_addr;
	wire [63:0] stage5_nodeToElement_data;
	wire stage5_nodeToElement_wren;
	
	wire [4:0] stage5_refNodes_addr;
	wire [4:0] stage5_refNodes_data;
	wire stage5_refNodes_wren;
	
	// Stage 6
	wire [4:0] stage6_nodeHeads_addr;
	wire stage6_nodeHeads_wren;
	
	wire [4:0] stage6_nodeToElement_addr;
	wire stage6_nodeToElement_wren;
	
	wire [11:0] stage6_matrix_addr_a, stage6_matrix_addr_b; 
	wire [31:0] stage6_matrix_data_a, stage6_matrix_data_b;
	wire stage6_matrix_wren_a, stage6_matrix_wren_b;
	
	
	// Stage 7
	wire [11:0] stage7_matrix_addr_a, stage7_matrix_addr_b; 
	wire [31:0] stage7_matrix_data_a, stage7_matrix_data_b;
	wire stage7_matrix_wren_a, stage7_matrix_wren_b;
	
	// Stage 8
	wire [4:0] stage8_nodeHeads_addr;
	wire stage8_nodeHeads_wren;
	
	wire [11:0] stage8_matrix_addr_a;
	wire stage8_matrix_wren_a;
	
	wire [4:0] stage8_nodeVoltage_addr;
	wire [31:0] stage8_nodeVoltage_data;
	wire stage8_nodeVoltage_wren;
	
	// Stage 9
	// RAM: nodeHeads
	wire [4:0] stage9_nodeHeads_addr;
	wire stage9_nodeHeads_wren;
	
	// RAM: nodeSeq
	wire [4:0] stage9_nodeSeq_addr;
	wire [4:0] stage9_nodeSeq_data;
	wire stage9_nodeSeq_wren;
		
	// RAM: elementSeq
	wire [4:0] stage9_elementSeq_addr;
	wire [4:0] stage9_elementSeq_data;
	wire stage9_elementSeq_wren;
	
	// Stage 10: Configure Circuit
	// RAM: nodeSeq
	wire [4:0] stage10_nodeSeq_addr;
	wire stage10_nodeSeq_wren;
		
	// RAM: elementSeq
	wire [4:0] stage10_elementSeq_addr;
	wire stage10_elementSeq_wren;
	
	// RAM: processor
	wire [9:0] stage10_processor_addr;
	wire [47:0] stage10_processor_data;
	wire stage10_processor_wren;
	
	// RAM: element
	wire [4:0] stage10_element_addr;
	wire stage10_element_wren;
	
	// Stage 11: Draw Circuit
	wire [9:0] stage11_processor_addr;
	wire stage11_processor_wren;
	
	wire [9:0] stage11_vga_x;
	wire [8:0] stage11_vga_y;
	wire stage11_vga_in;
	wire stage11_vga_wren;
	
	wire [11:0] stage11_vSprite_addr;
	wire [11:0] stage11_cSprite_addr;
	wire [11:0] stage11_rSprite_addr;
	wire [5:0] stage11_dot_addr;
	

	main_controller Ctrl_0(
		.current_state(cs),
		.next_state(ns),
		
		.clk(clk),
		.program_reset(~key[0]),    // ~KEY[0]
		.press_start(~key[1]),        // ~KEY[1]
		
		// Input handshakes (stages)
		.clearScreen_done(clearScreen_done),
		.getElement_done(getElement_done),
		.valueConversion_done(valueConversion_done),
		.buildNodeList_done(buildNodeList_done),
		.chooseRefNode_done(chooseRefNode_done),
		.searchSuperNode_done(searchSuperNode_done),
		.generateEquations_done(generateEquations_done),
		.solveMatrix_done(solveMatrix_done),
		.calculateVoltage_done(calculateVoltage_done),
		
		.sortSequence_done(sortSequence_done),
		.configureCircuit_done(configureCircuit_done),
		.drawCircuit_done(drawCircuit_done),
		
		
		// Output handshakes (stages)
		.run_clearScreen(run_clearScreen),
		.run_getElement(run_getElement),
		.run_convertValues(run_convertValues),
		.run_buildNodeList(run_buildNodeList),
		.run_chooseRefNode(run_chooseRefNode),
		.run_searchSuperNode(run_searchSuperNode),
		.run_generateEquations(run_generateEquations),
		.run_solveMatrix(run_solveMatrix),
		.run_calculateVoltage(run_calculateVoltage),
		
		.run_sortSequence(run_sortSequence),
		.run_configureCircuit(run_configureCircuit),
		.run_drawCircuit(run_drawCircuit),
		
		
		// Output handshakes (main datapath)
		.program_initialize(program_initialize)
		
		
	);

	
	main_datapath Data_0(
		.run_drawSimpleCircuit(run_drawSimpleCircuit),
		.sw(sw),
		
		.clk(clk),
		.program_initialize(program_initialize),
		
		// HEX Display
		.h0(h0),
		.h1(h1),
		.h2(h2),
		.h3(h3),
		.h4(h4),
		.h5(h5),
		
		// VGA Display
		.vga_x(vga_x),
		.vga_y(vga_y),
		.vga_in(vga_in),
		.vga_wren(vga_wren),
		
		// RAM: element
		.element_addr(element_addr),
		.element_data(element_data),
		.element_wren(element_wren),
		
		// RAM: float_register
		.float_register_addr(float_register_addr),
		.float_register_data(float_register_data),
		.float_register_wren(float_register_wren),
		
		// RAM: nodeHeads
		.nodeHeads_addr(nodeHeads_addr),
		.nodeHeads_data(nodeHeads_data),
		.nodeHeads_wren(nodeHeads_wren),
		
		// RAM: nodeToElement
		.nodeToElement_addr(nodeToElement_addr),
		.nodeToElement_data(nodeToElement_data),
		.nodeToElement_wren(nodeToElement_wren),
		
		// RAM: refNodes
		.refNodes_addr(refNodes_addr),
		.refNodes_data(refNodes_data),
		.refNodes_wren(refNodes_wren),
		
		// RAM: float_matrix
		.matrix_addr_a(matrix_addr_a),
		.matrix_addr_b(matrix_addr_b),
		.matrix_data_a(matrix_data_a),
		.matrix_data_b(matrix_data_b),
		.matrix_wren_a(matrix_wren_a),
		.matrix_wren_b(matrix_wren_b),
		
		// RAM: nodeVoltage
		.nodeVoltage_addr(nodeVoltage_addr),
		.nodeVoltage_data(nodeVoltage_data),
		.nodeVoltage_wren(nodeVoltage_wren),
		
		// RAM: nodeSeq
		.nodeSeq_addr(nodeSeq_addr),
		.nodeSeq_data(nodeSeq_data),
		.nodeSeq_wren(nodeSeq_wren),
		
		// RAM: elementSeq
		.elementSeq_addr(elementSeq_addr),
		.elementSeq_data(elementSeq_data),
		.elementSeq_wren(elementSeq_wren),
		
		// RAM: processor
		.processor_addr(processor_addr),
		.processor_data(processor_data),
		.processor_wren(processor_wren),
		
		// RAMs: sprites
		.vSprite_addr(vSprite_addr),
		.cSprite_addr(cSprite_addr),
		.rSprite_addr(rSprite_addr),
		.dot_addr(dot_addr),
		
		
		
		// Stage 0
		.run_clearScreen(run_clearScreen),
		.stage0_vga_x(stage0_vga_x),
		.stage0_vga_y(stage0_vga_y),
		.stage0_vga_in(stage0_vga_in),
		.stage0_vga_wren(stage0_vga_wren),
		
		
		// Stage 1
		.run_getElement(run_getElement),
		.stage1_element_addr(stage1_element_addr),
		.stage1_element_data(stage1_element_data),
		.stage1_element_wren(stage1_element_wren),
		.stage1_h0(stage1_h0),
		.stage1_h1(stage1_h1),
		.stage1_h2(stage1_h2),
		.stage1_h3(stage1_h3),
		.stage1_h4(stage1_h4),
		.stage1_h5(stage1_h5),
		
		// Stage 2
		.run_convertValues(run_convertValues),
		.stage2_element_addr(stage2_element_addr),
		.stage2_element_wren(stage2_element_wren),
		.stage2_float_register_addr(stage2_float_register_addr),
		.stage2_float_register_data(stage2_float_register_data),
		.stage2_float_register_wren(stage2_float_register_wren),
		
		
		// Stage 3
		.run_buildNodeList(run_buildNodeList),
		.stage3_element_addr(stage3_element_addr),
		.stage3_element_wren(stage3_element_wren),
		
		.stage3_float_register_addr(stage3_float_register_addr),
		.stage3_float_register_wren(stage3_float_register_wren),
		
		.stage3_nodeHeads_addr(stage3_nodeHeads_addr),
		.stage3_nodeHeads_data(stage3_nodeHeads_data),
		.stage3_nodeHeads_wren(stage3_nodeHeads_wren),
		
		.stage3_nodeToElement_addr(stage3_nodeToElement_addr),
		.stage3_nodeToElement_data(stage3_nodeToElement_data),
		.stage3_nodeToElement_wren(stage3_nodeToElement_wren),
		
		// Stage 4
		.run_chooseRefNode(run_chooseRefNode),
		.stage4_h0(stage4_h0),
		.stage4_h1(stage4_h1),
		.stage4_h2(stage4_h2),
		.stage4_h3(stage4_h3),
		.stage4_h4(stage4_h4),
		.stage4_h5(stage4_h5),
		
		// Stage 5
		.run_searchSuperNode(run_searchSuperNode),
		.stage5_nodeHeads_addr(stage5_nodeHeads_addr),
		.stage5_nodeHeads_data(stage5_nodeHeads_data),
		.stage5_nodeHeads_wren(stage5_nodeHeads_wren),
		
		.stage5_nodeToElement_addr(stage5_nodeToElement_addr),
		.stage5_nodeToElement_data(stage5_nodeToElement_data),
		.stage5_nodeToElement_wren(stage5_nodeToElement_wren),
		
		.stage5_refNodes_addr(stage5_refNodes_addr),
		.stage5_refNodes_data(stage5_refNodes_data),
		.stage5_refNodes_wren(stage5_refNodes_wren),
		
		// Stage 6
		.run_generateEquations(run_generateEquations),
		.stage6_nodeHeads_addr(stage6_nodeHeads_addr),
		.stage6_nodeHeads_wren(stage6_nodeHeads_wren),
		
		.stage6_nodeToElement_addr(stage6_nodeToElement_addr),
		.stage6_nodeToElement_wren(stage6_nodeToElement_wren),
		
		.stage6_matrix_addr_a(stage6_matrix_addr_a),
		.stage6_matrix_addr_b(stage6_matrix_addr_b),
		.stage6_matrix_data_a(stage6_matrix_data_a),
		.stage6_matrix_data_b(stage6_matrix_data_b),
		.stage6_matrix_wren_a(stage6_matrix_wren_a),
		.stage6_matrix_wren_b(stage6_matrix_wren_b),
		
		// Stage 7
		.run_solveMatrix(run_solveMatrix),
		.stage7_matrix_addr_a(stage7_matrix_addr_a),
		.stage7_matrix_addr_b(stage7_matrix_addr_b),
		.stage7_matrix_data_a(stage7_matrix_data_a),
		.stage7_matrix_data_b(stage7_matrix_data_b),
		.stage7_matrix_wren_a(stage7_matrix_wren_a),
		.stage7_matrix_wren_b(stage7_matrix_wren_b),
		
		// Stage 8
		.run_calculateVoltage(run_calculateVoltage),
		.stage8_nodeHeads_addr(stage8_nodeHeads_addr),
		.stage8_nodeHeads_wren(stage8_nodeHeads_wren),
	
		.stage8_matrix_addr_a(stage8_matrix_addr_a),
		.stage8_matrix_wren_a(stage8_matrix_wren_a),
	
		.stage8_nodeVoltage_addr(stage8_nodeVoltage_addr),
		.stage8_nodeVoltage_data(stage8_nodeVoltage_data),
		.stage8_nodeVoltage_wren(stage8_nodeVoltage_wren),
		
		
		// Stage 9
		// RAM: nodeHeads
		.run_sortSequence(run_sortSequence),
		.stage9_nodeHeads_addr(stage9_nodeHeads_addr),
		.stage9_nodeHeads_wren(stage9_nodeHeads_wren),
		
		// RAM: nodeSeq
		.stage9_nodeSeq_addr(stage9_nodeSeq_addr),
		.stage9_nodeSeq_data(stage9_nodeSeq_data),
		.stage9_nodeSeq_wren(stage9_nodeSeq_wren),

		// RAM: elementSeq
		.stage9_elementSeq_addr(stage9_elementSeq_addr),
		.stage9_elementSeq_data(stage9_elementSeq_data),
		.stage9_elementSeq_wren(stage9_elementSeq_wren),
		
		// Stage 10
		.run_configureCircuit(run_configureCircuit),
		.stage10_nodeSeq_addr(stage10_nodeSeq_addr),
		.stage10_nodeSeq_wren(stage10_nodeSeq_wren),
		
		.stage10_elementSeq_addr(stage10_elementSeq_addr),
		.stage10_elementSeq_wren(stage10_elementSeq_wren),
		
		.stage10_processor_addr(stage10_processor_addr),
		.stage10_processor_data(stage10_processor_data),
		.stage10_processor_wren(stage10_processor_wren),
		
		.stage10_element_addr(stage10_element_addr),
		.stage10_element_wren(stage10_element_wren),
		
		// Stage 11
		.run_drawCircuit(run_drawCircuit),
		.stage11_processor_addr(stage11_processor_addr),
		.stage11_processor_wren(stage11_processor_wren),
		
		.stage11_vga_x(stage11_vga_x),
		.stage11_vga_y(stage11_vga_y),
		.stage11_vga_in(stage11_vga_in),
		.stage11_vga_wren(stage11_vga_wren),
		
		.stage11_vSprite_addr(stage11_vSprite_addr),
		.stage11_cSprite_addr(stage11_cSprite_addr),
		.stage11_rSprite_addr(stage11_rSprite_addr),
		.stage11_dot_addr(stage11_dot_addr)
		
	
	);
	
	
	
	
	/* Stage 0:
		Clear Screen
	*/
	
	clearScreen STAGE_0(
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_clearScreen),
		.end_process(clearScreen_done),
		
		// VGA Display
		.vga_x(stage0_vga_x),
		.vga_y(stage0_vga_y),
		.vga_in(stage0_vga_in),
		.vga_wren(stage0_vga_wren)
	);
	
	
	/* Stage 1:
	   KEY[0] to reset the whole program
	   KEY[1] to reset the current element input
	   KEY[2] to advance to the next stage: building the node linked list / draw simple circuits
	   KEY[3] to confirm input values
	*/
	getElement_main STAGE_1(
		.cs(cs1),
		.ns(ns1),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		.input_reset(~key[1]),
		.input_over(~key[2]),
		.go(~key[3]),
		.data_in(sw[9:0]),
		
		// Handshakes
		.start_process(run_getElement),
		.end_process(getElement_done),
	
		// Hex Display
		.h0(stage1_h0),
		.h1(stage1_h1),
		.h2(stage1_h2),
		.h3(stage1_h3),
		.h4(stage1_h4),
		.h5(stage1_h5),
		
		// element RAM
		.element_addr(stage1_element_addr),
		.element_data(stage1_element_data),
		.element_wren(stage1_element_wren),
		
		.numElements(numElements)
	);
	
	convertValues_main STAGE_2(
		.cs(cs2),
		.ns(ns2),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_convertValues),
		.end_process(valueConversion_done),
		
		// element RAM
		.element_addr(stage2_element_addr),
		.element_wren(stage2_element_wren),
		.element_out(element_out),
		
		// float_register RAM
		.float_register_addr(stage2_float_register_addr),
		.float_register_data(stage2_float_register_data),
		.float_register_wren(stage2_float_register_wren),
		
		.numElements(numElements)
		
	);
	
	buildNodeList_main STAGE_3(
		.cs(cs3),
		.ns(ns3),
		
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_buildNodeList),
		.end_process(buildNodeList_done),
		
		// element RAM
		.element_addr(stage3_element_addr),
		.element_wren(stage3_element_wren),
		.element_out(element_out),
		
		// float_register RAM
		.float_register_addr(stage3_float_register_addr),
		.float_register_wren(stage3_float_register_wren),
		.float_register_out(float_register_out),
		
		// nodeHeads RAM
		.nodeHeads_addr(stage3_nodeHeads_addr),
		.nodeHeads_data(stage3_nodeHeads_data),
		.nodeHeads_wren(stage3_nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// nodeToElement RAM
		.nodeToElement_addr(stage3_nodeToElement_addr),
		.nodeToElement_data(stage3_nodeToElement_data),
		.nodeToElement_wren(stage3_nodeToElement_wren),
		.nodeToElement_out(nodeToElement_out),
		
		.numElements(numElements),
		.numNodes(numNodes)
	);
	
	chooseRefNode_main STAGE_4(
		.cs(cs4),
		.ns(ns4),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		.input_over(~key[2]),
		.go(~key[3]),
		.data_in(sw[9:0]),
		
		// Handshakes
		.start_process(run_chooseRefNode),
		.end_process(chooseRefNode_done),
	
		// Hex Display
		.h0(stage4_h0),
		.h1(stage4_h1),
		.h2(stage4_h2),
		.h3(stage4_h3),
		.h4(stage4_h4),
		.h5(stage4_h5),
		
		.numNodes(numNodes),
		.ground_node(ground_node)
	);
	
	
	searchSuperNode_main STAGE_5(
		.cs(cs5),
		.ns(ns5),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_searchSuperNode),
		.end_process(searchSuperNode_done),
		
		// nodeHeads RAM
		.nodeHeads_addr(stage5_nodeHeads_addr),
		.nodeHeads_data(stage5_nodeHeads_data),
		.nodeHeads_wren(stage5_nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// nodeToElement RAM
		.nodeToElement_addr(stage5_nodeToElement_addr),
		.nodeToElement_data(stage5_nodeToElement_data),
		.nodeToElement_wren(stage5_nodeToElement_wren),
		.nodeToElement_out(nodeToElement_out),
		
		// refNodes RAM
		.refNodes_addr(stage5_refNodes_addr),
		.refNodes_data(stage5_refNodes_data),
		.refNodes_wren(stage5_refNodes_wren),
		.refNodes_out(refNodes_out),
		
		
		.numElements(numElements),
		.numNodes(numNodes),
		.ground_node(ground_node),
		.numRefNodes(numRefNodes)
	);
	
	
	generateEquations_main STAGE_6(
		.cs(cs6),
		.ns(ns6),
		  
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_generateEquations),
		.end_process(generateEquations_done),
		
		// nodeHeads RAM
		.nodeHeads_addr(stage6_nodeHeads_addr),
		.nodeHeads_wren(stage6_nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// nodeToElement RAM
		.nodeToElement_addr(stage6_nodeToElement_addr),
		.nodeToElement_wren(stage6_nodeToElement_wren),
		.nodeToElement_out(nodeToElement_out),
		
		// float_matrix RAM
		.matrix_addr_a(stage6_matrix_addr_a),
		.matrix_addr_b(stage6_matrix_addr_b),
		.matrix_data_a(stage6_matrix_data_a),
		.matrix_data_b(stage6_matrix_data_b),
		.matrix_wren_a(stage6_matrix_wren_a),
		.matrix_wren_b(stage6_matrix_wren_b),
		.matrix_out_a(matrix_out_a),
		.matrix_out_b(matrix_out_b),
		
		// Misc
		.numElements(numElements),
		.numNodes(numNodes),
		.ground_node(ground_node),
		.numRefNodes(numRefNodes)
	);
	
	
	solveMatrix_main STAGE_7(
		.cs(cs7),
		.ns(ns7),
		  
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_solveMatrix),
		.end_process(solveMatrix_done),
		
		// float_matrix RAM
		.matrix_addr_a(stage7_matrix_addr_a),
		.matrix_addr_b(stage7_matrix_addr_b),
		.matrix_data_a(stage7_matrix_data_a),
		.matrix_data_b(stage7_matrix_data_b),
		.matrix_wren_a(stage7_matrix_wren_a),
		.matrix_wren_b(stage7_matrix_wren_b),
		.matrix_out_a(matrix_out_a),
		.matrix_out_b(matrix_out_b),
		
		// Misc
		.dimension(numRefNodes[3:0])
	);
	
	calculateVoltage_main STAGE_8(
		.cs(cs8),
		.ns(ns8),
		  
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_calculateVoltage),
		.end_process(calculateVoltage_done),
		
		// nodeHeads RAM
		.nodeHeads_addr(stage8_nodeHeads_addr),
		.nodeHeads_wren(stage8_nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// float_matrix RAM
		.matrix_addr_a(stage8_matrix_addr_a),
		.matrix_wren_a(stage8_matrix_wren_a),
		.matrix_out_a(matrix_out_a),
		
		// nodeVoltage RAM
		.nodeVoltage_addr(stage8_nodeVoltage_addr),
		.nodeVoltage_data(stage8_nodeVoltage_data),
		.nodeVoltage_wren(stage8_nodeVoltage_wren),
		.nodeVoltage_out(nodeVoltage_out),
		
		// Misc
		.numNodes(numNodes),
		.numRefNodes(numRefNodes)
	);
	
	
	sortSequence_main STAGE_9(
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
		
		.cs(cs9),
		.ns(ns9),
		  
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_sortSequence),
		.end_process(sortSequence_done),
		
		// RAM: nodeHeads
		.nodeHeads_addr(stage9_nodeHeads_addr),
		.nodeHeads_wren(stage9_nodeHeads_wren),
		.nodeHeads_out(nodeHeads_out),
		
		// RAM: nodeSeq
		.nodeSeq_addr(stage9_nodeSeq_addr),
		.nodeSeq_data(stage9_nodeSeq_data),
		.nodeSeq_wren(stage9_nodeSeq_wren),
		.nodeSeq_out(nodeSeq_out),
		
		// RAM: elementSeq
		.elementSeq_addr(stage9_elementSeq_addr),
		.elementSeq_data(stage9_elementSeq_data),
		.elementSeq_wren(stage9_elementSeq_wren),
		.elementSeq_out(elementSeq_out),
		
		// Misc
		.numNodes(numNodes),
		.numElements(numElements),
		.block_width(block_width)
	);
	
	
	configureCircuit_main STAGE_10(
		.cs(cs10),
		.ns(ns10),
		  
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_configureCircuit),
		.end_process(configureCircuit_done),
		
		/*
		// nodeVoltage RAM
		.nodeVoltage_addr(stage10_nodeVoltage_addr),
		.nodeVoltage_wren(stage10_nodeVoltage_wren),
		.nodeVoltage_out(nodeVoltage_out),
		*/
		
		// RAM: nodeSeq
		.nodeSeq_addr(stage10_nodeSeq_addr),
		.nodeSeq_wren(stage10_nodeSeq_wren),
		.nodeSeq_out(nodeSeq_out),
		
		// RAM: elementSeq
		.elementSeq_addr(stage10_elementSeq_addr),
		.elementSeq_wren(stage10_elementSeq_wren),
		.elementSeq_out(elementSeq_out),
		
		// processor RAM
		.processor_addr(stage10_processor_addr),
		.processor_data(stage10_processor_data),
		.processor_wren(stage10_processor_wren),
		.processor_out(processor_out),
		
		// element RAM
		.element_addr(stage10_element_addr),
		.element_wren(stage10_element_wren),
		.element_out(element_out),
		
		// Misc
		.numNodes(numNodes),
		.numElements(numElements),
		.block_width(block_width),
		.node_vga_pos(node_vga_pos),
		.numCommands(numCommands)
	);
	
	
	drawCircuit_main STAGE_11(
		.cs(cs11),
		.ns(ns11),
		  
		// FPGA inputs
		.clk(clk),
		.program_reset(~key[0]),
		
		// Handshakes
		.start_process(run_drawCircuit),
		.end_process(drawCircuit_done),
		
		// VGA
		.vga_x(stage11_vga_x),
		.vga_y(stage11_vga_y),
		.vga_in(stage11_vga_in),
		.vga_wren(stage11_vga_wren),
		
		// RAM: processor 1024x48
		.processor_addr(stage11_processor_addr),
		.processor_wren(stage11_processor_wren),
		.processor_out(processor_out),
		
		// ROM: vSprite
		.vSprite_addr(stage11_vSprite_addr),
		.vSprite_out(vSprite_out),
		
		// ROM: cSprite
		.cSprite_addr(stage11_cSprite_addr),
		.cSprite_out(cSprite_out),
		
		// ROM: rSprite
		.rSprite_addr(stage11_rSprite_addr),
		.rSprite_out(rSprite_out),
		
		// ROM: dot
		.dot_addr(stage11_dot_addr),
		.dot_out(dot_out),
		
		// Misc
		.numCommands(numCommands)
	);
	
	
	
endmodule
