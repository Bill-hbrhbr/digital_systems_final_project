`timescale 1ns/1ns

module chooseRefNode_controller(
		input clk, program_reset, input_over, go,
		input start_process, output reg end_process,
		
		input data_reset_done, done_judge, node_index_valid,
		
		output reg go_reset_data, go_display_choose, go_display_refnode, ld_node_index, go_judge_valid, go_display_invalid,
		
		output reg [3:0] current_state = 4'd0, next_state
	);
	
	localparam PRE_CHOOSE = 4'd0,
				  DISPLAY_CHOOSE = 4'd1,
				  DISPLAY_CHOOSE_WAIT = 4'd2,
				  DISPLAY_REF_NODE = 4'd3,
				  DISPLAY_REF_NODE_WAIT = 4'd4,
		        NUMBER_LOAD = 4'd5,
				  NUMBER_LOAD_WAIT = 4'd6,
				  JUDGE_NUMBER_VALID = 4'd7,
				  DISPLAY_INVALID = 4'd8,
				  DISPLAY_INVALID_WAIT = 4'd9,
				  DONE_CHOOSE = 4'd10;
	

	always @(*) begin: state_table
		case (current_state)
			PRE_CHOOSE:
				next_state = (data_reset_done & start_process) ? DISPLAY_CHOOSE : PRE_CHOOSE;
				
			DISPLAY_CHOOSE:
				next_state = go ? DISPLAY_CHOOSE_WAIT : DISPLAY_CHOOSE;
				
			DISPLAY_CHOOSE_WAIT:
				next_state = go ? DISPLAY_CHOOSE_WAIT : DISPLAY_REF_NODE;
				
			DISPLAY_REF_NODE:
				next_state = go ? DISPLAY_REF_NODE_WAIT : DISPLAY_REF_NODE;
				
			DISPLAY_REF_NODE_WAIT:
				next_state = go ? DISPLAY_REF_NODE_WAIT : NUMBER_LOAD;
			
			NUMBER_LOAD:
				next_state = input_over ? NUMBER_LOAD_WAIT : NUMBER_LOAD;
				
			NUMBER_LOAD_WAIT:
				next_state = input_over ? NUMBER_LOAD_WAIT : JUDGE_NUMBER_VALID;
			
			JUDGE_NUMBER_VALID: begin
				if (done_judge)
					next_state = node_index_valid ? DONE_CHOOSE : DISPLAY_INVALID;
			end
			
			DISPLAY_INVALID:
				next_state = go ? DISPLAY_INVALID_WAIT : DISPLAY_INVALID;
				
			DISPLAY_INVALID_WAIT:
				next_state = go ? DISPLAY_INVALID_WAIT : DISPLAY_CHOOSE;
		
		endcase
		
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_display_choose = 0;
		go_display_refnode = 0;
		ld_node_index = 0;
		go_judge_valid = 0;
		go_display_invalid = 0;
		end_process = 0;
		
		case (current_state)
			PRE_CHOOSE: go_reset_data = 1;
			DISPLAY_CHOOSE: go_display_choose = 1;
			DISPLAY_REF_NODE: go_display_refnode = 1;
			NUMBER_LOAD: ld_node_index = 1;
			JUDGE_NUMBER_VALID: go_judge_valid = 1;
			DISPLAY_INVALID: go_display_invalid = 1;
			DONE_CHOOSE: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset)
			current_state <= PRE_CHOOSE;
		else if (!end_process) 			
			current_state <= next_state;		
	end

	
endmodule
