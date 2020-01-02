`timescale 1ns/1ns

module sortSequence_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,

		// Input hanshakes
		input data_reset_done, width_calculated, element_seq_set, node_chosen, all_nodes_set, node_checked, node_valid, node_seq_set,
			
		// Input handshakes
		output reg go_reset_data, go_calculate_width, go_set_element_seq, go_choose_next_node, go_check_node, go_set_node_seq,
		
		output reg [3:0] current_state = 0, next_state
	);
	
	
	localparam PRE_SORT = 4'd0,
				  CALCULATE_WIDTH = 4'd1,
				  SET_ELEMENT_SEQUENCE = 4'd2,
				  CHOOSE_NODE = 4'd3,
				  CHECK_NODE = 4'd4,
				  SET_NODE_SEQUENCE = 4'd5,
				  
				  DONE_SORT = 4'd14,
				  IDLE = 4'd15;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_SORT:
				next_state = (data_reset_done & start_process) ? CALCULATE_WIDTH : PRE_SORT;
			
			CALCULATE_WIDTH:
				next_state = width_calculated ? SET_ELEMENT_SEQUENCE : CALCULATE_WIDTH;
				
			SET_ELEMENT_SEQUENCE:
				next_state = element_seq_set ? CHOOSE_NODE : SET_ELEMENT_SEQUENCE;
			
			CHOOSE_NODE: begin
				if (node_chosen)
					next_state = CHECK_NODE;
				else
					next_state = all_nodes_set ? DONE_SORT : CHOOSE_NODE;
			end
			
			CHECK_NODE: begin
				if (node_checked)
					next_state = node_valid ? SET_NODE_SEQUENCE : CHOOSE_NODE;
				else
					next_state = CHECK_NODE;
			end
			
			SET_NODE_SEQUENCE:
				next_state = node_seq_set ? CHOOSE_NODE : SET_NODE_SEQUENCE;
				
			DONE_SORT:
				next_state = start_process ? DONE_SORT : IDLE;
			
			
		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_calculate_width = 0;
		go_set_element_seq = 0;
		go_choose_next_node = 0;
		go_check_node = 0;
		go_set_node_seq = 0;
		end_process = 0;
		case (current_state)
			PRE_SORT: go_reset_data = 1;
			CALCULATE_WIDTH: go_calculate_width = 1;
			SET_ELEMENT_SEQUENCE: go_set_element_seq = 1;
			CHOOSE_NODE: go_choose_next_node = 1;
			CHECK_NODE: go_check_node = 1;
			SET_NODE_SEQUENCE: go_set_node_seq = 1;
			DONE_SORT: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset)
			current_state <= PRE_SORT;
		else
			current_state <= next_state;		
	end
	
	
endmodule
