`timescale 1ns/1ns

module configureCircuit_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,

		// Input hanshakes
		input data_reset_done, signals_cleared, dashed_node_line_written, element_chosen, element_info_obtained, all_elements_written,
		input node_A_found, node_B_found, element_wire_written, element_sprite_written, top_node_written, bot_node_written,
		
		// Output handshakes
		output reg go_reset_data, go_clear_signals, write_dashed_node_line, go_choose_element, go_get_element_info, 
		output reg go_search_node_A, go_search_node_B, go_write_element_wire, go_write_element_sprite, go_write_top_node, go_write_bot_node, 
		
		
		output reg [4:0] current_state = 0, next_state
	);
	
	
	localparam PRE_CONFIGURE = 5'd0,
				  LD_DASHED = 5'd1,
				  CHOOSE_ELEMENT = 5'd2,
				  GET_INFO = 5'd3,
				  SEARCH_A = 5'd4,
				  SEARCH_B = 5'd5,
				  LD_ELEMENT_WIRE = 5'd6,
				  LD_ELEMENT_SPRITE = 5'd7,
				  LD_NODE_TOP = 5'd8,
				  LD_NODE_BOT = 5'd9,
				  
				  CLEAR_SIGNALS = 5'd29,
				  DONE_CONFIGURE = 5'd30,
				  IDLE = 5'd31;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_CONFIGURE:
				next_state = (data_reset_done & start_process) ? LD_DASHED : PRE_CONFIGURE;
			
			LD_DASHED:
				next_state = dashed_node_line_written ? CHOOSE_ELEMENT : LD_DASHED;
				
			CHOOSE_ELEMENT: begin
				if (all_elements_written)
					next_state = CLEAR_SIGNALS;
				else
					next_state = element_chosen ? GET_INFO : CHOOSE_ELEMENT;
			end
			
			GET_INFO:
				next_state = element_info_obtained ? SEARCH_A : GET_INFO;
				
			SEARCH_A:
				next_state = node_A_found ? SEARCH_B : SEARCH_A;
				
			SEARCH_B:
				next_state = node_B_found ? LD_ELEMENT_WIRE : SEARCH_B;
				
			LD_ELEMENT_WIRE:
				next_state = element_wire_written ? LD_ELEMENT_SPRITE : LD_ELEMENT_WIRE;
			
			LD_ELEMENT_SPRITE:
				next_state = element_sprite_written ? LD_NODE_TOP : LD_ELEMENT_SPRITE;
				
			LD_NODE_TOP:
				next_state = top_node_written ? LD_NODE_BOT : LD_NODE_TOP;
			
			LD_NODE_BOT:
				next_state = bot_node_written ? CHOOSE_ELEMENT : LD_NODE_BOT;
				
			CLEAR_SIGNALS:
				next_state = signals_cleared ? DONE_CONFIGURE : CLEAR_SIGNALS;
				
			DONE_CONFIGURE:
				next_state = start_process ? DONE_CONFIGURE : IDLE;
			
			IDLE:
				next_state = start_process ? PRE_CONFIGURE : IDLE;
			
		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_clear_signals = 0;
		write_dashed_node_line = 0;
		go_choose_element = 0;
		go_get_element_info = 0;
		go_search_node_A = 0;
		go_search_node_B = 0;
		go_write_element_wire = 0;
		go_write_element_sprite = 0;
		go_write_top_node = 0;
		go_write_bot_node = 0;
		end_process = 0;
		
		case (current_state)
			PRE_CONFIGURE: go_reset_data = 1;
			LD_DASHED: write_dashed_node_line = 1;
			CHOOSE_ELEMENT: go_choose_element = 1;
			GET_INFO: go_get_element_info = 1;
			SEARCH_A: go_search_node_A = 1;
			SEARCH_B: go_search_node_B = 1;
			LD_ELEMENT_WIRE: go_write_element_wire = 1;
			LD_ELEMENT_SPRITE: go_write_element_sprite = 1;
			LD_NODE_TOP: go_write_top_node = 1;
			LD_NODE_BOT: go_write_bot_node = 1;
			CLEAR_SIGNALS: go_clear_signals = 1;
			DONE_CONFIGURE: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset)
			current_state <= PRE_CONFIGURE;
		else
			current_state <= next_state;		
	end
	
	
endmodule
