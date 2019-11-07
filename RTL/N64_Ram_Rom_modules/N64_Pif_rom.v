module N64_pif_rom(
    input               clk,
    
    input       [8:0]   address_a,
    output reg  [31:0]  q_a
    
);

	reg [31:0] mem [511:0];

	integer i;
	initial begin
		for(i = 0; i < 512; i = i + 1) begin
			mem[i] = 8'd0;
		end
	end

	always @(posedge clk) begin
		q_a <= mem[address_a];
	end

endmodule