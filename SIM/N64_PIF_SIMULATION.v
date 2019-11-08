`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.11.2019 15:30:16
// Design Name: 
// Module Name: N64_PIF_SIMULATION
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


module N64_PIF_SIMULATION(

    );
    
    reg     n64_clk, n64_rsp; 
    wire    n64_pif;
    
    reg     clk;
    reg     reset_l;
    
    wire    joy1;
    wire    joy2;
    wire    joy3;
    wire    joy4;
    
    wire    eprom_clk, eprom_data;
    wire    reset_button = 1'b0;
    wire    NMI;
    wire    INT2;
    wire    PAL_NTSC = 1'b0;
    
    initial begin
        clk <= 'b0;
        n64_clk <= 'b0;
        reset_l <= 'b1;
        n64_rsp <= 'b0;
        #4 reset_l <= 'b0;

        #4 reset_l <= 'b1;
        
        #100 $finish;
    end
    
    always begin
      #2 clk = ~clk;
    end
    
    
    always begin
      #20 n64_clk = ~n64_clk;
    end
    
    
    N64_PIF_TOP N64_PIF_TOP(
    .n64_clk    (n64_clk),
    .n64_rsp    (n64_rsp),
    .n64_pif    (n64_pif),
    .joy1       (joy1),
    .joy2       (joy2),
    .joy3       (joy3),
    .joy4       (joy4),
    .eprom_clk  (eprom_clk),
    .eprom_data (eprom_data),
    .reset_button (reset_button),
    .NMI        (NMI),
    .INT2       (INT2),
    .PAL_NTSC   (PAL_NTSC),
    .clk        (clk),
    .reset_l    (reset_l)
    );
    
    N64_controller N64_controller_joy1
(
    .clock (clk),
    .reset_l (reset_l),
	.A (1'b0),
	.B(1'b0),
	.Z(1'b0),
    .START(1'b1),
    .gray_UP(1'b0),
	.gray_DOWN(1'b0),
	.gray_LEFT(1'b0),
	.gray_RIGHT(1'b0),
	.L(1'b1),
    .R(1'b1),
	.yellow_UP(1'b0),
	.yellow_DOWN(1'b0),
	.yellow_LEFT(1'b0),
	.yellow_RIGHT(1'b0),
	.joystick_X(8'h5),
	.joystick_Y(8'h4),
	.mem_rumble(1'b0),
	.out(joy1)
);
    
endmodule
