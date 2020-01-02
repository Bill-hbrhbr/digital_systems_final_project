`timescale 1ns/1ns

module searchSuperNode_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,
		
		// Input hanshakes
		input data_reset_done, loop_done, next_node_reached, node_checked, node_valid, reference_node_registered,
		input is_voltage, type_checked, current_element_addr_stored, voltage_difference_updated, new_node_search_began,
		input next_element_reached, end_of_list_reached, whole_dfs_done, backtrace_done, backtrace_curr_search_addr_done,
		
		// Output handshakes
		output reg go_reset_data, go_to_next_node, go_check_node_status, go_register_reference_node, go_check_element_type,
		output reg  go_store_element_addr, go_update_voltage_difference, begin_search_new_node, 
		output reg go_to_next_element, go_backtrace_dfs, go_backtrace_curr_search_addr,
		
		
		output reg [3:0] current_state, next_state
	);
	
	localparam PRE_SEARCH = 4'd0,
				  LOOP_NEXT_NODE = 4'd1,
				  CHECK_NODE_STATUS = 4'd2,
				  REGISTER_REF_NODE = 4'd3,
				  CHECK_ELEMENT_TYPE = 4'd4,
				  STORE_OLD_ADDRESS = 4'd5,
				  UPDATE_VOLTAGE = 4'd6,
				  SWITCH_NODE = 4'd7,
				  CHECK_NEXT_ELEMENT = 4'd8,
				  BACKTRACE_DFS = 4'd9,
				  BACKTRACE_CURR_SEARCH_ADDR = 4'd10,
				  DONE_SEARCH = 4'd11;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_SEARCH:
				next_state = (data_reset_done & start_process) ? LOOP_NEXT_NODE : PRE_SEARCH;
			
			LOOP_NEXT_NODE: begin
				if (loop_done)
					next_state = DONE_SEARCH;
				else
					next_state = next_node_reached ? CHECK_NODE_STATUS : LOOP_NEXT_NODE;
			end
			
			CHECK_NODE_STATUS: begin
				if (node_checked)
					next_state = node_valid ? REGISTER_REF_NODE : LOOP_NEXT_NODE;
				else
					next_state = CHECK_NODE_STATUS;
			end
			
			REGISTER_REF_NODE:
				next_state = reference_node_registered ? CHECK_ELEMENT_TYPE : REGISTER_REF_NODE;
			
			CHECK_ELEMENT_TYPE: begin
				if (type_checked)
					next_state = is_voltage ? STORE_OLD_ADDRESS: CHECK_NEXT_ELEMENT;
				else
					next_state = CHECK_ELEMENT_TYPE;
			end
			
			// Path 1
			STORE_OLD_ADDRESS:
				next_state = current_element_addr_stored ? UPDATE_VOLTAGE : STORE_OLD_ADDRESS;
				
			UPDATE_VOLTAGE:
				next_state = voltage_difference_updated ? SWITCH_NODE : UPDATE_VOLTAGE;
				
			SWITCH_NODE:
				next_state = new_node_search_began ? CHECK_ELEMENT_TYPE : SWITCH_NODE;
				
			// Path2
			CHECK_NEXT_ELEMENT: begin
				if (end_of_list_reached)
					next_state = BACKTRACE_DFS;
				else
					next_state = next_element_reached ? CHECK_ELEMENT_TYPE : CHECK_NEXT_ELEMENT;
			end
			
			BACKTRACE_DFS: begin
				if (whole_dfs_done)
					next_state = LOOP_NEXT_NODE;
				else
					next_state = backtrace_done ? BACKTRACE_CURR_SEARCH_ADDR : BACKTRACE_DFS;
			end
				
			BACKTRACE_CURR_SEARCH_ADDR:
				next_state = backtrace_curr_search_addr_done ? CHECK_NEXT_ELEMENT : BACKTRACE_CURR_SEARCH_ADDR;
			

		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_to_next_node = 0; 
		go_check_node_status = 0;  
		go_register_reference_node = 0;  
		go_check_element_type = 0; 
		go_store_element_addr = 0;  
		go_update_voltage_difference = 0;  
		begin_search_new_node = 0; 
		go_to_next_element = 0; 
		go_backtrace_dfs = 0; 
		go_backtrace_curr_search_addr = 0; 
		
		end_process = 0;
		
		case (current_state)
			PRE_SEARCH: go_reset_data = 1;
			LOOP_NEXT_NODE: go_to_next_node = 1;
			CHECK_NODE_STATUS: go_check_node_status = 1;
			REGISTER_REF_NODE: go_register_reference_node = 1;
			CHECK_ELEMENT_TYPE: go_check_element_type = 1;
			STORE_OLD_ADDRESS: go_store_element_addr = 1;
			UPDATE_VOLTAGE: go_update_voltage_difference = 1;
			SWITCH_NODE: begin_search_new_node = 1;
			CHECK_NEXT_ELEMENT: go_to_next_element = 1;
			BACKTRACE_DFS: go_backtrace_dfs = 1;
			BACKTRACE_CURR_SEARCH_ADDR: go_backtrace_curr_search_addr = 1;
			DONE_SEARCH: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset) begin
			current_state <= PRE_SEARCH;
		end
		else if (!end_process) begin 			
			current_state <= next_state;		
		end
	end
	
	
endmodule
