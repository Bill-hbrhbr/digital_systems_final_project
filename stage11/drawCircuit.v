module drawCircuit_main(
		output go_reset_data, go_read_processor, go_clear_signal, go_draw_command,
		
		output data_reset_done, finished_all, command_read, signals_cleared, done_draw_command,
		
		output [3:0] cs, ns,
		 
		// FPGA inputs
		input clk, program_reset,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// VGA
		output [9:0] vga_x,
		output [8:0] vga_y,
		output vga_in,	vga_wren,
		
		// RAM: processor 1024x48
		output [9:0] processor_addr,
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
		input dot_out,
		
		// Misc
		input [9:0] numCommands
	);
	
	//wire go_reset_data, go_read_processor, go_clear_signal, go_draw_command;
		
	//wire data_reset_done, finished_all, command_read, signals_cleared, done_draw_command;
	
	drawCircuit_controller Ctrl_11(
		.current_state(cs),
		.next_state(ns),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(program_reset),  // ~KEY[0]
		
		// Initial and Final
		.start_process(start_process),
		.end_process(end_process),
		
		// Input hanshakes
		.data_reset_done(data_reset_done), 
		.finished_all(finished_all),
		.command_read(command_read),
		.signals_cleared(signals_cleared),
		.done_draw_command(done_draw_command),

		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_read_processor(go_read_processor),
		.go_draw_command(go_draw_command),
		.go_clear_signal(go_clear_signal)
	);

	
	drawCircuit_datapath Data_11(
		// FPGA inputs
		.clk(clk),

		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_read_processor(go_read_processor),
		.go_draw_command(go_draw_command),
		.go_clear_signal(go_clear_signal),
		
		// Output hanshakes
		.data_reset_done(data_reset_done), 
		.finished_all(finished_all),
		.command_read(command_read),
		.signals_cleared(signals_cleared),
		.done_draw_command(done_draw_command),
		
		// RAM: processor 1024x47
		.processor_addr(processor_addr),
		.processor_wren(processor_wren),
		.processor_out(processor_out),
		
		// VGA
		.vga_x(vga_x),
		.vga_y(vga_y),
		.vga_in(vga_in),
		.vga_wren(vga_wren),
		
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
		.dot_out(dot_out),
		
		// Misc
		.numCommands(numCommands)

	);


	
endmodule
