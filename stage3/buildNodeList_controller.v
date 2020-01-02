`timescale 1ns/1ns

module buildNodeList_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,
		
		// Input hanshakes
		input data_reset_done, ram_reset_done, element_chosen, node_chosen, is_node_A, list_checked, list_exists, 
		input new_list_created, old_entry_read, old_entry_updated, new_entry_updated, memory_loaded, all_builded,
		
		// Output handshakes
		output reg go_reset_data, go_reset_ram, go_choose_element, build_node_A, build_node_B, check_list_exist, 
		output reg create_new_list, read_old_entry, update_old_entry, update_new_entry, ld_memory,
		
		
		output reg [3:0] current_state, next_state
	);
	
	localparam PRE_BUILD = 4'd0,
				  RESET_RAM = 4'd1,
				  CHOOSE_NEW_ELEMENT = 4'd2,
				  BUILD_A = 4'd3,
				  BUILD_B = 4'd4,
				  CHECK_LIST = 4'd5,
				  READ_OLD = 4'd6,
				  UPDATE_OLD = 4'd7,
				  UPDATE_NEW = 4'd8,
				  NEW_LIST = 4'd9,
				  MEMORY_WAIT = 4'd10,
				  DONE_BUILD = 4'd11;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_BUILD:
				next_state = (data_reset_done & start_process) ? RESET_RAM : PRE_BUILD;
				
			RESET_RAM:
				next_state = ram_reset_done ? CHOOSE_NEW_ELEMENT : RESET_RAM;
			
			CHOOSE_NEW_ELEMENT: begin
				if (all_builded)
					next_state = DONE_BUILD;
				else
					next_state = element_chosen ? BUILD_A : CHOOSE_NEW_ELEMENT;
			end
			
			BUILD_A:
				next_state = (node_chosen & is_node_A) ? CHECK_LIST : BUILD_A;
				
			BUILD_B:
				next_state = (node_chosen & ~is_node_A) ? CHECK_LIST : BUILD_B;
			
			CHECK_LIST:
				next_state = list_checked ? (list_exists ? READ_OLD : NEW_LIST) : CHECK_LIST;
				
			READ_OLD:
				next_state = old_entry_read ? UPDATE_OLD : READ_OLD;
				
			UPDATE_OLD:
				next_state = old_entry_updated ? UPDATE_NEW : UPDATE_OLD;
				
			UPDATE_NEW:
				next_state = new_entry_updated ? MEMORY_WAIT : UPDATE_NEW;
			
			NEW_LIST:
				next_state = new_list_created ? MEMORY_WAIT : NEW_LIST;
			
			
			MEMORY_WAIT: begin
				if (memory_loaded)
					next_state = is_node_A ? BUILD_B : CHOOSE_NEW_ELEMENT;
			end
			

		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_reset_ram = 0;
		go_choose_element = 0;
		build_node_A = 0;
		build_node_B = 0;
		check_list_exist = 0;
		create_new_list = 0;
		read_old_entry = 0;
		update_old_entry = 0;
		update_new_entry = 0;
		ld_memory = 0;
		end_process = 0;
		
		case (current_state)
			PRE_BUILD: go_reset_data = 1;
			RESET_RAM: go_reset_ram = 1;
			CHOOSE_NEW_ELEMENT: go_choose_element = 1;
			BUILD_A: build_node_A = 1;
			BUILD_B: build_node_B = 1;
			CHECK_LIST: check_list_exist = 1;
			NEW_LIST: create_new_list = 1;
			READ_OLD: read_old_entry = 1;
			UPDATE_OLD: update_old_entry = 1;
			UPDATE_NEW: update_new_entry = 1;
			MEMORY_WAIT: ld_memory = 1;
			DONE_BUILD: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset) begin
			current_state <= PRE_BUILD;
		end
		else if (!end_process) begin 			
			current_state <= next_state;		
		end
	end

	
endmodule

