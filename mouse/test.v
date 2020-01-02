module test(

	output 	VGA_CLK,   						//	VGA Clock
	output	VGA_HS,							//	VGA H_SYNC
	output	VGA_VS,							//	VGA V_SYNC
	output	VGA_BLANK_N,						//	VGA BLANK
	output	VGA_SYNC_N,						//	VGA SYNC
	output [7:0]	VGA_R,   						//	VGA Red[9:0]
	output [7:0]	VGA_G,	 						//	VGA Green[9:0]
	output [7:0]	VGA_B,   						//	VGA Blue[9:0]

	input CLOCK_50, 
	input [3:0] KEY,
	input [9:0] SW,
	inout PS2_CLK, PS2_DAT,
	output	[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5,
	
	output reg [2:0] cs = 0, ns
	
);
	wire en;
	wire [7:0] data;
	
	reg [3:0] h0 = 0, h1 = 0, h2 = 0, h3 = 0, h4 = 0, h5 = 0;
	
	
	PS2_Controller #(.INITIALIZE_MOUSE(1)) mod(
		// Inputs
		.clk(CLOCK_50),
		.reset(~KEY[0]),

		//the_command,
		//send_command,

		// Bidirectionals
		.PS2_CLK(PS2_CLK),					// PS2 Clock
		.PS2_DAT(PS2_DAT),					// PS2 Data

		// Outputs
		//command_was_sent,
		//.error_communication_timed_ou,

		.received_data(data),
		.received_data_en(en)		// If 1 - new data has been received
	);
	
	
	localparam START = 3'd0,
				  LD_0 = 3'd1,
				  LD_0_WAIT = 3'd2,
				  LD_1 = 3'd3,
				  LD_1_WAIT = 3'd4,
				  LD_2 = 3'd5,
				  LD_2_WAIT = 3'd6;
	
	reg ld0, ld1, ld2, done_ld;
	
	always @(*) begin
		ld0 = 0;
		ld1 = 0;
		ld2 = 0;
		done_ld = 0;
		case (cs)
			LD_0: ld0 = 1;
			LD_1: ld1 = 1;
			LD_2: ld2 = 1;
			LD_2_WAIT: done_ld = 1;
		endcase
	end
				  
	
	always @(*) begin
		case (cs)
			START:
				ns = en ? LD_0 : START;
			
			LD_0:
				ns = en ? LD_0 : LD_0_WAIT;
				
			LD_0_WAIT:
				ns = en ? LD_1 : LD_0_WAIT;
			
			LD_1:
				ns = en ? LD_1 : LD_1_WAIT;
				
			LD_1_WAIT:
				ns = en ? LD_2 : LD_1_WAIT;
				
			LD_2:
				ns = en ? LD_2 : LD_2_WAIT;
				
			LD_2_WAIT:
				ns = en ? LD_0 : LD_2_WAIT;
		
		endcase
	end
	
	
	
	always @(posedge CLOCK_50) begin
		if (~KEY[0])
			cs <= START;
		else
			cs <= ns;
	end
	

	always @(*) begin
		if (ld0) begin
			h0 = data[3:0];
			h1 = data[7:4];
		end
		
		if (ld1) begin
			h2 = data[3:0];
			h3 = data[7:4];
		end
		
		if (ld2) begin
			h4 = data[3:0];
			h5 = data[7:4];
		end
	end
	
	Decoder7Seg D5(h5, HEX5);
	Decoder7Seg D4(h4, HEX4);
	Decoder7Seg D3(h3, HEX3);
	Decoder7Seg D2(h2, HEX2);
	Decoder7Seg D1(h1, HEX1);
	Decoder7Seg D0(h0, HEX0);
	
	
	
	mouse M1(
		.clk(CLOCK_50),
		.reset(~KEY[0]),
		.done_ld(done_ld),
		.sx(h5[0]),
		.sy(h5[1]),
		.dx({h1, h0}),
		.dy({h3, h2}),
		.cx(x),
		.cy(y)
	);
	
	wire signed [11:0] x;
	wire signed [11:0] y;
	wire wren, colour, resetn;
	assign wren = 1;
	assign colour = SW[0];
	assign resetn = KEY[0];
	
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x[9:0]),
			.y(y[8:0]),
			.plot(wren),
			// Signals for the DAC to drive the monitor.
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.MONOCHROME = "TRUE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "vga/ddc.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
endmodule
