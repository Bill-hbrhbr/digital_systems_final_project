`timescale 1ns/1ns

module Decoder7Seg(C, HEX);
	//digits in binary form: act as 4-to-1 multiplexer
	input [3:0] C;
	
	//outputs for LED activations
	output [6:0] HEX;
	
	//connecting wires: derived from the truth table
	wire [6:0] Seg;
	
	//all use product-of-sum form representations
	assign Seg[0] = (C[3] | C[2] | C[1] | !C[0]) &
						 (C[3] | !C[2] | C[1] | C[0]) &
						 (!C[3] | C[2] | !C[1] | !C[0]) &
						 (!C[3] | !C[2] | C[1] | !C[0]);
	
	assign Seg[1] = (C[3] | !C[2] | C[1] | !C[0]) &
	                (C[3] | !C[2] | !C[1] | C[0]) &
						 (!C[3] | C[2] | !C[1] | !C[0]) &
						 (!C[3] | !C[2] | C[1] | C[0]) &
						 (!C[3] | !C[2] | !C[1] | C[0]) &
						 (!C[3] | !C[2] | !C[1] | !C[0]);
						 
	assign Seg[2] = (C[3] | C[2] | !C[1] | C[0]) &
	                (!C[3] | !C[2] | C[1] | C[0]) &
						 (!C[3] | !C[2] | !C[1] | C[0]) &
						 (!C[3] | !C[2] | !C[1] | !C[0]);
	
	assign Seg[3] = (C[3] | C[2] | C[1] | !C[0]) &
	                (C[3] | !C[2] | C[1] | C[0]) &
						 (C[3] | !C[2] | !C[1] | !C[0]) &
						 (!C[3] | C[2] | C[1] | !C[0]) &
						 (!C[3] | C[2] | !C[1] | C[0]) &
						 (!C[3] | !C[2] | !C[1] | !C[0]);
	
	assign Seg[4] = (C[3] | C[2] | C[1] | !C[0]) &
	                (C[3] | C[2] | !C[1] | !C[0]) &
						 (C[3] | !C[2] | C[1] | C[0]) &
						 (C[3] | !C[2] | C[1] | !C[0]) &
						 (C[3] | !C[2] | !C[1] | !C[0]) &
						 (!C[3] | C[2] | C[1] | !C[0]);
	
	assign Seg[5] = (C[3] | C[2] | C[1] | !C[0]) &
	                (C[3] | C[2] | !C[1] | C[0]) &
						 (C[3] | C[2] | !C[1] | !C[0]) &
						 (C[3] | !C[2] | !C[1] | !C[0]) &
						 (!C[3] | !C[2] | C[1] | !C[0]);
	
	assign Seg[6] = (C[3] | C[2] | C[1] | C[0]) &
	                (C[3] | C[2] | C[1] | !C[0]) &
						 (C[3] | !C[2] | !C[1] | !C[0]) &
						 (!C[3] | !C[2] | C[1] | C[0]);
	
	//the LED display uses common anode
	//0->on, 1->off.
	assign HEX = ~Seg;
	
endmodule

module BCD7Seg(data_in, h3, h2, h1, h0);
	input [9:0] data_in;
	output [6:0] h3, h2, h1, h0;
	
	reg [3:0] d3, d2, d1, d0;
	
	Decoder7Seg D3(d3, h3);
	Decoder7Seg D2(d2, h2);
	Decoder7Seg D1(d1, h1);
	Decoder7Seg D0(d0, h0);
	
	reg [9:0] temp;
	integer i;
	
	always @(*) begin
		temp = data_in;
		d3 = 0;
		d2 = 0;
		d1 = 0;
		if (temp > 999) begin
			d3 = 1;
			temp = temp - 1000;
		end
		
		for (i = 0; i < 10; i = i + 1) begin
			if (temp > 99) begin
				temp = temp - 100;
				d2 = d2 + 1;
			end
		end
		
		for (i = 0; i < 10; i = i + 1) begin
			if (temp > 9) begin
				temp = temp - 10;
				d1 = d1 + 1;
			end
		end
		
		d0 = temp;
	end
endmodule

