module rom_6502(
    input               clk,
    
    input       [11:0]   address_a,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

	reg [8:0] mem [4095:0];

	integer i;
	initial begin
		for(i = 0; i < 4096; i = i + 1) begin
			mem[i] = 8'd0; // This will be changed with the orginal rom
		end
	end

	always @(posedge clk) begin
		q_a <= mem[address_a];
		valid <= oe;
	end

endmodule