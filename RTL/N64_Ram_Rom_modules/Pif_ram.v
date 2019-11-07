module ram_6502(
    input               clk,
    
    input       [8:0]   address_a,
	input				we,
	input       [7:0]   data_a,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

	reg [7:0] mem [511:0];

	integer i;
	initial begin
		for(i = 0; i < 512; i = i + 1) begin
			mem[i] = 8'd0;
		end
	end

	always @(posedge clk) begin
		if (we) mem[address_a] <= data_a;
		q_a <= mem[address_a];
		valid <= oe;
	end

endmodule