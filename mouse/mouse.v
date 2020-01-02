module mouse(
		input clk, reset, done_ld,
		input signed [7:0] dx, dy,
		input sx, sy,
		output reg signed [11:0] cx,
		output reg signed [11:0] cy
	);
	
	
	always @(posedge done_ld) begin
		if (~reset) begin
			cx = cx + dx;
			cy = cy - dy;
			
			if (cx > 640)
				cx = 640;
			
			if (cx < 0)
				cx = 0;
			
			if (cy > 480)
				cy = 480;
			
			if (cy < 0)
				cy = 0;
				
		end
		else begin
			cx = 320;
			cy = 240;
		end
	end
			
	
endmodule
