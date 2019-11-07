module pif_rom(
    input               clk,
    
    input       [8:0]   address_a,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

	reg [8:0] mem [511:0];

	integer i;
	initial begin
		for(i = 0; i < 512; i = i + 1) begin
			mem[i] = 8'd0; // This will be changed with the orginal rom
		end
	end

	always @(posedge clk) begin
		q_a <= mem[address_a];
		valid <= oe;
	end

endmodule