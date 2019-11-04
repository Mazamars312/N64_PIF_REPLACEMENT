`timescale 1ns/100ps

// Simulater for the N64PIF controller By Murray Aickin
// Email: Murray.aickin@boomweb.co.nz
// --------------------------------------------------------------------
// --------------------------------------------------------------------
// Bits Description:
// 				A 			--> buttons[0]
// 				B 			--> buttons[1]
// 				Z 			--> buttons[2]
// 				Start 	--> buttons[3]
// 				Up 		--> buttons[4]
// 				Down 		--> buttons[5]
// 				Left 		--> buttons[6]
// 				Right		--> buttons[7]
// 				N/A 		--> buttons[8]
// 				N/A 		--> buttons[9]
// 				L 			--> buttons[10]
// 				R 			--> buttons[11]
// 				C-UP 		--> buttons[12]
// 				C-DOWN	--> buttons[13]
// 				C-Left	--> buttons[14]
// 				C-Right	--> buttons[15]
// 				X-Axis 	--> buttons[23:16]
// 				Y-Axis 	--> buttons[31:24]

/**************************************************************

    address lines
        0x0000 - cmd
        0x0001 - high address
        0x0010 - Low address/xor CRC[4:0]
        0x0011 - Controller access and ready/waiting status
        0x0100 - Controller controll signals
        0x0101 - Read fifo (8-bits)
        0x0110 - Write fifo (8-bits)

    Commands
        0x00 - Status of controller
        0x01 - Read controller buttons
        0x02 - Read Ram
        0x03 - Write ram
        0xff - reset controller

**************************************************************/


module controller_test_bench(

    );

		reg clk;
		reg reset_l;

//		output reg [33:0]buttons=34'd0,
//		output reg alive=1'd0,
//		reg joy1_out;
//		reg joy2_out;
//		reg joy3_out;
//		reg joy4_out;

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
            clk <= 'b0;
            joy_out <= 'b0;
            reset_l <= 'b1;
            address <= 'b0;
            data_in_bus <= 'b0;
            write <= 'b0;
            ce <= 'b0;

            #4 reset_l <= 'b0;

            #4 reset_l <= 'b1;

            #8  address <= 4'b0000;
                data_in_bus <= 8'h01; // the command we want to send
                ce <= 'b1;
                write <= 'b1;
            // write data to fifo 0
            #4  address <= 4'b0110;
                data_in_bus <= 8'h01;
                // write data to fifo 1
            #4  address <= 4'b0110;
                data_in_bus <= 8'h02;
                // write data to fifo 2
            #4  address <= 4'b0110;
                data_in_bus <= 8'h03;
                // write data to fifo 3
            #4  address <= 4'b0110;
                data_in_bus <= 8'h04;
                // write data to fifo 4
            #4  address <= 4'b0110;
                data_in_bus <= 8'h05;
                // write data to fifo 5
            #4  address <= 4'b0110;
                data_in_bus <= 8'h06;
                // write data to fifo 6
            #4  address <= 4'b0110;
                data_in_bus <= 8'h07;
                // write data to fifo 7
            #4  address <= 4'b0110;
                data_in_bus <= 8'h08;
                // write data to fifo 8
            #4  address <= 4'b0110;
                data_in_bus <= 8'h09;
                // write data to fifo 9
            #4  address <= 4'b0110;
                data_in_bus <= 8'h0A;
                // write data to fifo 10
            #4  address <= 4'b0110;
                data_in_bus <= 8'h0B;
                // write data to fifo 11
            #4  address <= 4'b0110;
                data_in_bus <= 8'h0C;
                // write data to fifo 12
            #4  address <= 4'b0110;
                data_in_bus <= 8'h0D;
                // write data to fifo 13
            #4  address <= 4'b0110;
                data_in_bus <= 8'h0E;
                // write data to fifo 14
            #4  address <= 4'b0110;
                data_in_bus <= 8'h0F;
                // write data to fifo 15
            #4  address <= 4'b0110;
                data_in_bus <= 8'h10;
                // write data to fifo 16
            #4  address <= 4'b0110;
                data_in_bus <= 8'h11;
                // write data to fifo 17
            #4  address <= 4'b0110;
                data_in_bus <= 8'h12;
                // write data to fifo 18
            #4  address <= 4'b0110;
                data_in_bus <= 8'h13;
                // write data to fifo 19
            #4  address <= 4'b0110;
                data_in_bus <= 8'h14;
                // write data to fifo 20
            #4  address <= 4'b0110;
                data_in_bus <= 8'h15;
                // write data to fifo 21
            #4  address <= 4'b0110;
                data_in_bus <= 8'h16;
                // write data to fifo 22
            #4  address <= 4'b0110;
                data_in_bus <= 8'h17;
                // write data to fifo 23
            #4  address <= 4'b0110;
                data_in_bus <= 8'h18;
                // write data to fifo 24
            #4  address <= 4'b0110;
                data_in_bus <= 8'h19;
                // write data to fifo 25
            #4  address <= 4'b0110;
                data_in_bus <= 8'h1A;
                // write data to fifo 26
            #4  address <= 4'b0110;
                data_in_bus <= 8'h1B;
                // write data to fifo 27
            #4  address <= 4'b0110;
                data_in_bus <= 8'h1C;
                // write data to fifo 28
            #4  address <= 4'b0110;
                data_in_bus <= 8'h1D;
                // write data to fifo 29
            #4  address <= 4'b0110;
                data_in_bus <= 8'h1E;
                // write data to fifo 30
            #4  address <= 4'b0110;
                data_in_bus <= 8'h1F;
                // write data to fifo 31
            #4  address <= 4'b0110;
                data_in_bus <= 8'h20;
                // write data to fifo 32
            #4  address <= 4'b0110;
                data_in_bus <= 8'h21;

                // high address

            #4  address <= 4'b0001;
                data_in_bus <= 8'h22;

                // Low address

            #4  address <= 4'b0010;
                data_in_bus <= 8'h35;

                // Enable Joy1 controller and start processing the controller

            #4  address <= 4'b0100;
                data_in_bus <= 8'h01;

            #4  ce <= 'b0;
                write <= 'b0;

            #100 $finish;
        end

        always begin
          #2 clk = ~clk;
        end

//		assign joy1 = joy_out ? joy1_out : 'bz;
//		assign joy2 = joy_out ? joy2_out : 'bz;
//		assign joy3 = joy_out ? joy3_out : 'bz;
//		assign joy4 = joy_out ? joy4_out : 'bz;


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


N64_controller N64_controller_joy1
(
    .clock (clk),
    .reset_l (reset_l),
	.A (1'b0),
	.B(1'b0),
	.R(1'b0),
	.L(1'b0),
	.Z(1'b0),
	.START(1'b0),
	.yellow_UP(1'b0),
	.yellow_DOWN(1'b0),
	.yellow_LEFT(1'b0),
	.yellow_RIGHT(1'b0),
	.gray_UP(1'b0),
	.gray_DOWN(1'b0),
	.gray_LEFT(1'b0),
	.gray_RIGHT(1'b0),
	.joystick_X(8'b0),
	.joystick_Y(8'b0),
	.out(joy1)
);


endmodule
