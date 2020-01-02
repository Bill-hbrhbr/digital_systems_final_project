
module getElement_main (
		output [3:0] cs, ns,
		
		// FPGA inputs
		input clk, program_reset, input_reset, input_over, go,
		input [9:0] data_in,
		
		// Initial and Final
		input start_process,
		output end_process,
		
		// Hex Display
		output [6:0] h0, h1, h2, h3, h4, h5,
		
		// element RAM
		output [4:0] element_addr,
		output [31:0] element_data,
		output element_wren,
		
		// element count
		output [4:0] numElements
		
	);
	
	
	wire data_reset_done, element_reset_done, count_increased, go_reset_data, go_reset_element, do_display, ld_type, ld_value, ld_exponent, ld_nodes;
	wire ld_memory, inc_count;
	
	getElement_controller Ctrl_1(
		.current_state(cs),
		.next_state(ns),
		
		// FPGA inputs
		.clk(clk),
		.program_reset(program_reset),    // ~KEY[0]
		.input_reset(input_reset),        // ~KEY[1]
		.input_over(input_over),          // ~KEY[2]
		.go(go),                          // ~KEY[3]
		
		// Initial and Final
		.start_process(start_process),    // run_getElement
		.end_process(end_process),        // getElement_done
		
		// Input handshakes
		.data_reset_done(data_reset_done),
		.element_reset_done(element_reset_done),
		.count_increased(count_increased),
		
		// Output handshakes
		.go_reset_data(go_reset_data),
		.go_reset_element(go_reset_element),
		.do_display(do_display),
		.ld_type(ld_type),
		.ld_value(ld_value),
		.ld_exponent(ld_exponent),
		.ld_nodes(ld_nodes),
		.ld_memory(ld_memory),
		.inc_count(inc_count)
		
		
	);
	
	
	getElement_datapath Data_1(
		// FPGA inputs
		.clk(clk),
		.data_in(data_in),   // SW[9:0]
		
		// Input handshakes
		.go_reset_data(go_reset_data),
		.go_reset_element(go_reset_element),
		.do_display(do_display),
		.ld_type(ld_type),
		.ld_value(ld_value),
		.ld_exponent(ld_exponent),
		.ld_nodes(ld_nodes),
		.ld_memory(ld_memory),
		.inc_count(inc_count),
		 
		 // Output handshakes
		.data_reset_done(data_reset_done),
		.element_reset_done(element_reset_done),
		.count_increased(count_increased),
		
		// HEX display
		.h0(h0),
		.h1(h1),
		.h2(h2),
		.h3(h3),
		.h4(h4),
		.h5(h5),
		
		// element RAM
		.element_addr(element_addr),
		.element_data(element_data),
		.element_wren(element_wren),
		
		// element count
		.element_index(numElements)
	);
	
endmodule
