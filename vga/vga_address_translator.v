/* This module converts a user specified coordinates into a memory address.
 * The output of the module depends on the resolution set by the user.
 */
module vga_address_translator(x, y, mem_address);

	parameter RESOLUTION = "640x480";
	input [9:0] x; 
	input [8:0] y;	
	output [18:0] mem_address;
	
	assign mem_address = ({1'b0, y, 9'd0} + {1'b0, y, 7'd0} + {1'b0, x});
	
endmodule
