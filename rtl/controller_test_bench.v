`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.10.2019 18:38:40
// Design Name: 
// Module Name: controller_test_bench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module controller_test_bench(

    );
    
		reg clk;
		reg reset_l;

//		output reg [33:0]buttons=34'd0,
//		output reg alive=1'd0,
		reg joy1_out;
		reg joy2_out;
		reg joy3_out;
		reg joy4_out;
		
        wire joy1;
		wire joy2;
		wire joy3;
		wire joy4;
		
		reg joy_out;
		
		reg [3:0]       address;
		reg [7:0]       data_in_bus;
		reg             write;
		reg             ce;
		wire [7:0]  data_out_bus;
		
		
		initial begin
            #1 clk <= 'b0;
            joy_out <= 'b0;
            reset_l <= 'b1;
            address <= 'b0;
            data_in_bus <= 'b0;
            write <= 'b0;
            ce <= 'b0;
            
            #2 reset_l <= 'b0;
            
            #2 reset_l <= 'b1;
            
            #6  address <= 4'b0000;
                data_in_bus <= 8'h01; // the command we want to send
                ce <= 'b1;
                write <= 'b1;
            // write data to fifo 0
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 1
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 2
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 3
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 4
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 5
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 6
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 7
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 8
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 9
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 10
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 11
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 12
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 13
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 14
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 15
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 16
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 17
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 18
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 19
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 20
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 21
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 22
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 23
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 24
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 25
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 26
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 27
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 28
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 29
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 30
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 31
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
                // write data to fifo 32
            #2  address <= 4'b0110;
                data_in_bus <= 8'h22;
               
                // high address
                
            #2  address <= 4'b0001;
                data_in_bus <= 8'h22;
               
                // Low address
                
            #2  address <= 4'b0010;
                data_in_bus <= 8'h33;
                
                // Enable Joy1 controller and start processing the controller
                
            #2  address <= 4'b0100;
                data_in_bus <= 8'h01;
                
            #2  ce <= 'b0;
                write <= 'b0;
            
            #100 $finish;
        end

        always begin
          #1 clk = ~clk;
        end
		
		assign joy1 = joy_out ? joy1_out : 'bz;
		assign joy2 = joy_out ? joy2_out : 'bz;
		assign joy3 = joy_out ? joy3_out : 'bz;
		assign joy4 = joy_out ? joy4_out : 'bz;
		
		
		N64_controller_top N64_controller_top(
		.clk          (clk),
		.reset_l      (reset_l),

//		output reg [33:0]buttons=34'd0,
//		output reg alive=1'd0,
		.joy1         (joy1),
		.joy2         (joy2),
		.joy3         (joy3),
		.joy4         (joy4),
		
		.address      (address),
		.data_in_bus  (data_in_bus),
		.write        (write),
		.ce           (ce),
		.data_out_bus (data_out_bus)
);
    
    
endmodule
