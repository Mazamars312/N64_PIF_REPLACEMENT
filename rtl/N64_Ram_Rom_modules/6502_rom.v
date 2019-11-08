module rom_6502(
    input               clk,
    
    input       [11:0]   address_a,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

	reg [7:0] mem [4095:0];

	integer i;
	initial begin
		for(i = 0; i < 4096; i = i + 1) begin
			mem[i] = 8'd0; // This will be changed with the orginal rom
		end
		mem[00] = 8'h4C; 
		mem[01] = 8'h09; 
		mem[02] = 8'hC0; 
		mem[03] = 8'hAD; 
		mem[04] = 8'hA5; 
		mem[05] = 8'h02; 
		mem[06] = 8'h4C; 
		mem[07] = 8'h03;
        mem[08] = 8'hC0; 
        mem[09] = 8'hA9; 
        mem[10] = 8'h00; 
        mem[11] = 8'h8D; 
        mem[12] = 8'hFB; 
        mem[13] = 8'h00; 
        mem[14] = 8'hA9; 
        mem[15] = 8'h20;
        mem[16] = 8'h8D; 
        mem[17] = 8'hFC; 
        mem[18] = 8'h00; 
        mem[19] = 8'hA9; 
        mem[20] = 8'h00; 
        mem[21] = 8'h8D; 
        mem[22] = 8'hFD; 
        mem[23] = 8'h00;
        mem[24] = 8'hA9; 
        mem[25] = 8'h10; 
        mem[26] = 8'h8D; 
        mem[27] = 8'hFE; 
        mem[28] = 8'h00; 
        mem[29] = 8'hA0; 
        mem[30] = 8'h00; 
        mem[31] = 8'hA2;
        mem[32] = 8'h00; 
        mem[33] = 8'hB1; 
        mem[34] = 8'hFB; 
        mem[35] = 8'h91; 
        mem[36] = 8'hFD; 
        mem[37] = 8'hEE; 
        mem[38] = 8'hFB; 
        mem[39] = 8'h00;
        mem[40] = 8'hEE; 
        mem[41] = 8'hFD; 
        mem[42] = 8'h00; 
        mem[43] = 8'hD0; 
        mem[44] = 8'hF4; 
        mem[45] = 8'hEE; 
        mem[46] = 8'hFC; 
        mem[47] = 8'h00;
        mem[48] = 8'hEE; 
        mem[49] = 8'hFE; 
        mem[50] = 8'h00; 
        mem[51] = 8'hAD; 
        mem[52] = 8'hFE; 
        mem[53] = 8'h00; 
        mem[54] = 8'hC9; 
        mem[55] = 8'h20;
        mem[56] = 8'hD0; 
        mem[57] = 8'hE7; 
        mem[58] = 8'h4C; 
        mem[59] = 8'h03; 
        mem[60] = 8'hC0;
        mem[4090] = 8'hF0;
        mem[4091] = 8'h00;
        mem[4092] = 8'hF0;
        mem[4093] = 8'h00;
        mem[4094] = 8'hF0;
        mem[4095] = 8'h00;
	end

	always @(posedge clk) begin
		q_a <= mem[address_a];
		valid <= oe;
	end

endmodule