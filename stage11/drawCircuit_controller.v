`timescale 1ns/1ns

module drawCircuit_controller(
		input clk, program_reset,
		input start_process, 
		output reg end_process,
		
		// Input handshakes
		input data_reset_done, finished_all, command_read, signals_cleared,
		input done_draw_command,
		
		// Output hanshakes
		output reg go_reset_data, go_read_processor, go_clear_signal, go_draw_command,
		
		output reg [3:0] current_state = 0, next_state
	);
	
	localparam PRE_DRAW = 4'd0,
				  READ_PROCESSOR = 4'd1,
				  DRAW_COMMAND = 4'd2,
				  CLEAR_SIGNALS = 4'd3,
				  DONE_DRAW = 4'd14,
				  IDLE = 4'd15;
	
	always @(*) begin: state_table
		case (current_state)
			PRE_DRAW:
				next_state = (data_reset_done & start_process) ? READ_PROCESSOR : PRE_DRAW;
			
			READ_PROCESSOR: begin
				if (finished_all)
					next_state = DONE_DRAW;
				else
					next_state = command_read ? DRAW_COMMAND : READ_PROCESSOR;
			end
			
			DRAW_COMMAND:
				next_state = done_draw_command ? CLEAR_SIGNALS : DRAW_COMMAND;
			
			CLEAR_SIGNALS:
				next_state = signals_cleared ? READ_PROCESSOR : CLEAR_SIGNALS;
				
			DONE_DRAW:
				next_state = start_process ? DONE_DRAW : IDLE;
			
			IDLE:
				next_state = start_process ? PRE_DRAW : IDLE;
			
		endcase
	end
	
	always @(*) begin: enable_signals
		go_reset_data = 0;
		go_read_processor = 0;
		go_draw_command = 0;
		go_clear_signal = 0;
		end_process = 0;
		
		case (current_state)
			PRE_DRAW: go_reset_data = 1;
			READ_PROCESSOR: go_read_processor = 1;
			DRAW_COMMAND: go_draw_command = 1;
			CLEAR_SIGNALS: go_clear_signal = 1;
			DONE_DRAW: end_process = 1;
		endcase
	end
	
	
	always @(posedge clk) begin: state_FFs		
		if (program_reset)
			current_state <= PRE_DRAW;
		else			
			current_state <= next_state;
	end
	
	
endmodule
