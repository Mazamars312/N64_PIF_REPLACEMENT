module rom_6502(
    input               clk,
    
    input       [11:0]   address,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

	reg [127:0] mem [255:0];

	integer i;
	initial begin
		for(i = 0; i < 255; i = i + 1) begin
			mem[i] = 8'd0; // This will be changed with the orginal rom
		end
		$readmemh("6502.mem", mem);
	end

	always @(posedge clk) begin
	   case (address[3:0])
	       5'hf : q_a <= mem[address[11:4]][  7:  0];
	       5'he : q_a <= mem[address[11:4]][ 15:  8];
	       5'hd : q_a <= mem[address[11:4]][ 23: 16];
	       5'hc : q_a <= mem[address[11:4]][ 31: 24];
	       5'hb : q_a <= mem[address[11:4]][ 39: 32];
	       5'ha : q_a <= mem[address[11:4]][ 47: 40];
	       5'h9 : q_a <= mem[address[11:4]][ 55: 48];
	       5'h8 : q_a <= mem[address[11:4]][ 63: 56];
	       5'h7 : q_a <= mem[address[11:4]][ 71: 64];
	       5'h6 : q_a <= mem[address[11:4]][ 79: 72];
	       5'h5 : q_a <= mem[address[11:4]][ 87: 80];
	       5'h4 : q_a <= mem[address[11:4]][ 95: 88];
	       5'h3 : q_a <= mem[address[11:4]][103: 96];
	       5'h2 : q_a <= mem[address[11:4]][111:104];
	       5'h1 : q_a <= mem[address[11:4]][119:112];
	       5'h0 : q_a <= mem[address[11:4]][127:120];
	   endcase
		
		valid <= oe;
	end

endmodule