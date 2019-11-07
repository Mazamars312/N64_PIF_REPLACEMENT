module crc_rom(
    input               clk,
    
    input       [4:0]   address_a,
	input				oe,
	output reg			valid,
    output reg  [7:0]   q_a
    
);

/*****************************************************************************
    Here is the CRC code used by Project 64 where we are going to use
    the 6502 to process the 6105CRC seed codes. We need to remember that these
    are nibbles (4bits) when processing the seed responce.

    static char lut0[0x10] = {
        0x4, 0x7, 0xA, 0x7, 0xE, 0x5, 0xE, 0x1,
        0xC, 0xF, 0x8, 0xF, 0x6, 0x3, 0x6, 0x9
    };
    static char lut1[0x10] = {
        0x4, 0x1, 0xA, 0x7, 0xE, 0x5, 0xE, 0x1,
        0xC, 0x9, 0x8, 0x5, 0x6, 0x3, 0xC, 0x9
    };

*****************************************************************************/


	reg [8:0] mem [31:0];

	integer i;
	initial begin
	   	mem[ 0] = 8'h04;
		mem[ 1] = 8'h07;
		mem[ 2] = 8'h0A;
		mem[ 3] = 8'h07;
		mem[ 4] = 8'h0E;
		mem[ 5] = 8'h05;
		mem[ 6] = 8'h0E;
		mem[ 7] = 8'h01;
		mem[ 8] = 8'h0C;
		mem[ 9] = 8'h0F;
		mem[10] = 8'h08;
		mem[11] = 8'h0F;
		mem[12] = 8'h06;
		mem[13] = 8'h03;
		mem[14] = 8'h06;
		mem[15] = 8'h09;
		mem[16] = 8'h04;
		mem[17] = 8'h01;
		mem[18] = 8'h0A;
		mem[19] = 8'h07;
		mem[20] = 8'h0E;
		mem[21] = 8'h05;
		mem[22] = 8'h0E;
		mem[23] = 8'h01;
		mem[24] = 8'h0C;
		mem[25] = 8'h09;
		mem[26] = 8'h08;
		mem[27] = 8'h05;
		mem[28] = 8'h06;
		mem[29] = 8'h03;
		mem[30] = 8'h0C;
		mem[31] = 8'h09;
	end

	always @(posedge clk) begin
		q_a <= mem[address_a];
		valid <= oe;
	end

endmodule