module main_controller(
		input clk, program_reset, press_start,
		
		input clearScreen_done, getElement_done, valueConversion_done, buildNodeList_done, chooseRefNode_done, searchSuperNode_done,
		input generateEquations_done, solveMatrix_done, calculateVoltage_done, 
		
		input sortSequence_done, configureCircuit_done, drawCircuit_done,
		
		output reg program_initialize, run_clearScreen, run_getElement, run_convertValues, run_buildNodeList, run_chooseRefNode, run_searchSuperNode,
		output reg run_generateEquations, run_solveMatrix, run_calculateVoltage, 
		
		output reg run_sortSequence, run_configureCircuit, run_drawCircuit,
		
		output reg [3:0] current_state = 4'd0, next_state
	);
	
	localparam PROGRAM_START = 4'd0,
				  PROGRAM_START_WAIT = 4'd1,
				  GET_ELEMENT = 4'd2,
				  CONVERT_VALUES = 4'd3,
				  BUILD_NODE_LIST = 4'd4,
				  CHOOSE_REFERENCE_NODE = 4'd5,
				  SEARCH_SUPER_NODE = 4'd6,
				  GENERATE_EQUATIONS = 4'd7,
				  SOLVE_MATRIX = 4'd8,
				  CALCULATE_VOLTAGE = 4'd9,
				  SORT_SEQUENCE = 4'd10,
				  CONFIGURE_CIRCUIT = 4'd11,
				  DRAW_CIRCUIT = 4'd12,
				  IDLE = 4'd15;
				  
				  
				  
	always @(*) begin: state_table
		case (current_state)
			PROGRAM_START:
				//next_state = (press_start & clearScreen_done) ? PROGRAM_START_WAIT : PROGRAM_START;
				next_state = press_start ? PROGRAM_START_WAIT : PROGRAM_START;
				
			PROGRAM_START_WAIT:
				next_state = press_start ? PROGRAM_START_WAIT : GET_ELEMENT;
			
			
			// Stage 1
			GET_ELEMENT:
				next_state = getElement_done ? CONVERT_VALUES : GET_ELEMENT;
			
			// Stage 2
			CONVERT_VALUES:
				next_state = valueConversion_done ? BUILD_NODE_LIST : CONVERT_VALUES;
			
			// Stage 3
			BUILD_NODE_LIST:
				next_state = buildNodeList_done ? CHOOSE_REFERENCE_NODE : BUILD_NODE_LIST;
			
			// Stage 4
			CHOOSE_REFERENCE_NODE:
				next_state = chooseRefNode_done ? SEARCH_SUPER_NODE : CHOOSE_REFERENCE_NODE;
			
			// Stage 5
			SEARCH_SUPER_NODE:
				next_state = searchSuperNode_done ? GENERATE_EQUATIONS : SEARCH_SUPER_NODE;
			
			// Stage 6
			GENERATE_EQUATIONS:
				next_state = generateEquations_done ? SOLVE_MATRIX : GENERATE_EQUATIONS;
			
			// Stage 7
			SOLVE_MATRIX:
				next_state = solveMatrix_done ? CALCULATE_VOLTAGE : SOLVE_MATRIX;
			
			// Stage 8
			CALCULATE_VOLTAGE:
				next_state = calculateVoltage_done ? SORT_SEQUENCE : CALCULATE_VOLTAGE;
				
			// Stage 9
			SORT_SEQUENCE:
				next_state = sortSequence_done ? CONFIGURE_CIRCUIT : SORT_SEQUENCE;
			
			// Stage 10
			CONFIGURE_CIRCUIT:
				next_state = configureCircuit_done ? DRAW_CIRCUIT :  CONFIGURE_CIRCUIT;
			
			// Stage 11
			DRAW_CIRCUIT:
				next_state = drawCircuit_done ? IDLE : DRAW_CIRCUIT;
			
			
		endcase
	end
	
	always @(*) begin: enable_signals
		program_initialize = 0;
		run_clearScreen = 0;
		run_getElement = 0;
		run_convertValues = 0;
		run_buildNodeList = 0;
		run_chooseRefNode = 0;
		run_searchSuperNode = 0;
		run_generateEquations = 0;
		run_solveMatrix = 0;
		run_calculateVoltage = 0;
		
		run_sortSequence = 0;
		run_configureCircuit = 0;
		run_drawCircuit = 0;
		
		case (current_state)
			PROGRAM_START: begin
				program_initialize = 1;
				run_clearScreen = 1;
			end
			GET_ELEMENT: run_getElement = 1;
			CONVERT_VALUES: run_convertValues = 1;
			BUILD_NODE_LIST: run_buildNodeList = 1;
			CHOOSE_REFERENCE_NODE: run_chooseRefNode = 1;
			SEARCH_SUPER_NODE: run_searchSuperNode = 1;
			GENERATE_EQUATIONS: run_generateEquations = 1;
			SOLVE_MATRIX: run_solveMatrix = 1;
			CALCULATE_VOLTAGE: run_calculateVoltage = 1;
			
			SORT_SEQUENCE: run_sortSequence = 1;
			CONFIGURE_CIRCUIT: run_configureCircuit = 1;
			DRAW_CIRCUIT: run_drawCircuit = 1;
			
			
		endcase
	end
	
	always @(posedge clk) begin: state_FFs
		if (program_reset)
			current_state <= PROGRAM_START;
		else 
			current_state <= next_state;
	end
	
endmodule
