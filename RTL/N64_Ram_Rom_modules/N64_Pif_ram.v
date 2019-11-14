`timescale 1ns / 1ps
module N64_pif_ram(
    input               clka,
    
    input       [10:0]  address_a,
    input               wren_a,
    input       [7:0]   data_a,
	input				oe,
    output reg  [7:0]   q_a,
	output reg			valid,
    
    input               clkb,
    input       [8:0]   address_b,
    input               wren_b,
    input       [31:0]  data_b,
    output reg  [31:0]  q_b
);

	reg [31:0] mem [511:0];

	integer i;
	initial begin
		for(i = 0; i < 512; i = i + 1) begin
			mem[i] = 32'd0;
	
		end
	end

    reg [31:0]  temp_a_data;
    reg [1:0]   temp_a_address;
    
    always @(posedge clka) begin
	   temp_a_address <= address_a[1:0];
	   valid <= oe;
	end
	
	always @* begin
        case (temp_a_address[1:0])
			2'b11 	: q_a <= temp_a_data[ 7: 0];
			2'b10 	: q_a <= temp_a_data[15: 8];
			2'b01 	: q_a <= temp_a_data[23:16];
			default	: q_a <= temp_a_data[31:24];
		endcase
    end

	always @(posedge clka) begin
		if(wren_a && (address_a[1:0] == 2'b11)) mem[address_a[10:2]][ 7: 0] <= data_a;
		if(wren_a && (address_a[1:0] == 2'b10)) mem[address_a[10:2]][15: 8] <= data_a;
		if(wren_a && (address_a[1:0] == 2'b01)) mem[address_a[10:2]][23:16] <= data_a;
		if(wren_a && (address_a[1:0] == 2'b00)) mem[address_a[10:2]][31:24] <= data_a;
        
		temp_a_data <= mem[address_a[10:2]];
	end
	


	always @(posedge clkb) begin
		if(wren_b) begin
			mem[address_b] <= data_b;
		end
		q_b <= mem[address_b];
	end

endmodule