`timescale 1ns / 1ps
module ram_6502(
    input               clk,
    
    input       [10:0]   address,
	input				we,
	input       [7:0]   data,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

	reg [7:0] mem [4095:0];

	integer i;
	initial begin
		for(i = 0; i < 4096; i = i + 1) begin
			mem[i] = 8'd0;
		end
	end

	always @(posedge clk) begin
		if (we) mem[address] <= data;
		q_a <= mem[address];
		valid <= oe;
	end

endmodule