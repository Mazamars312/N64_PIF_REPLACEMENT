module N64_pif_ram(
    input               clk,
    
    input       [5:0]   address_a,
    input               wren_a,
    input       [7:0]   data_a,
	input				oe,
    output reg  [7:0]   q_a,
	output reg			valid,
    

    input       [3:0]   address_b,
    input               wren_b,
    input       [31:0]  data_b,
    output reg  [31:0]  q_b
);

	reg [7:0] mem0 [15:0];
	reg [7:0] mem1 [15:0];
	reg [7:0] mem2 [15:0];
	reg [7:0] mem3 [15:0];

	integer i;
	initial begin
		for(i = 0; i < 16; i = i + 1) begin
			mem0[i] = 8'd0;
			mem1[i] = 8'd0;
			mem2[i] = 8'd0;
			mem3[i] = 8'd0;
		end
	end

	always @(posedge clk) begin
		if(wren_a && (address_a[1:0] == 2'b00)) mem0[address_a[5:2]] <= data_a;
		if(wren_a && (address_a[1:0] == 2'b01)) mem1[address_a[5:2]] <= data_a;
		if(wren_a && (address_a[1:0] == 2'b10)) mem2[address_a[5:2]] <= data_a;
		if(wren_a && (address_a[1:0] == 2'b11)) mem3[address_a[5:2]] <= data_a;
		case (address_a[1:0])
			2'b00 	: q_a <= mem0[address_a[5:2]];
			2'b01 	: q_a <= mem1[address_a[5:2]];
			2'b10 	: q_a <= mem2[address_a[5:2]];
			default	: q_a <= mem3[address_a[5:2]];
		endcase
		valid <= oe;
	end

	always @(posedge clk) begin
		if(wren_b) begin
			mem0[address_b] <= data_b[ 7: 0];
			mem1[address_b] <= data_b[15: 8];
			mem2[address_b] <= data_b[23:16];
			mem3[address_b] <= data_b[31:24];
		end
		q_b <= {mem3[address_b], mem2[address_b], mem1[address_b], mem0[address_b]};
	end

endmodule