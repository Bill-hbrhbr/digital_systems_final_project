`timescale 1ns/1ns

module calculateVoltage_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,
		
		// Input hanshakes
		input data_reset_done, node_chosen, all_done, node_checked, node_valid, ops_done, memory_loaded,
		
		// Output handshakes
		output reg go_reset_data, go_choose_node, go_check_node, go_do_ops, ld_memory,
		
		output reg [3:0] current_state = 0, next_state
	);
	
	localparam PRE_CALCULATE = 4'd0,
				  CHOOSE_NODE = 4'd1,
				  CHECK_NODE = 4'd2,
				  OPERATIONS = 4'd3,
				  LOAD_MEMORY = 4'd4,
				  DONE_CALCULATE = 4'd15;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_CALCULATE:
				next_state = (data_reset_done & start_process) ? CHOOSE_NODE : PRE_CALCULATE;
			
			CHOOSE_NODE: begin
				if (node_chosen)
					next_state = CHECK_NODE;
				else if (all_done)
					next_state = DONE_CALCULATE;
				else
					next_state = CHOOSE_NODE;
			end
			
			CHECK_NODE: begin
				if (node_checked)
					next_state = node_valid ? OPERATIONS : CHOOSE_NODE;
				else
					next_state = CHECK_NODE;
			end
			
			OPERATIONS:
				next_state = ops_done ? LOAD_MEMORY : OPERATIONS;
				
			LOAD_MEMORY:
				next_state = memory_loaded ? CHOOSE_NODE : LOAD_MEMORY;
				
		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_choose_node = 0;
		go_check_node = 0;
		go_do_ops = 0;
		ld_memory = 0;
		end_process = 0;
		
		case (current_state)
			PRE_CALCULATE: go_reset_data = 1;
			CHOOSE_NODE: go_choose_node = 1;
			CHECK_NODE: go_check_node = 1;
			OPERATIONS: go_do_ops = 1;
			LOAD_MEMORY: ld_memory = 1;
			DONE_CALCULATE: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset) begin
			current_state <= PRE_CALCULATE;
		end
		else if (!end_process) begin 			
			current_state <= next_state;		
		end
	end
	
	
endmodule
