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
    
    wire    n64_clk, n64_rsp; 
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
    
    reg cbus_read_enable;                      // enable cbus read mux
    reg cbus_write_enable;                     // enable cbus tristate drivers
    reg [1:0] cbus_select;    // cbus data select
    reg [2:0] cbus_command;  // cbus data type
    reg dma_start;                             // first dbus word flag
    reg dbus_enable;                           // enable dbus tristate drivers
    reg dma_grant;                             // DMA request granted
    reg read_grant;                            // read request granted
    
    wire dma_request;                          // request a DMA cycle
    wire read_request;                         // request a read response cycle
    wire interrupt;                            // SI interrupt source
    
    wire [31:0] cbus_data;        // IO bus
    wire [63:0] dbus_data;        // DMA bus
    
    initial begin
        clk <= 'b0;
        
        cbus_read_enable <= 'b0;                      // enable cbus read mux
        cbus_write_enable <= 'b0;                     // enable cbus tristate drivers
        cbus_select <= 'b0;                           // cbus data select
        cbus_command <= 'b0;                          // cbus data type
        dma_start <= 'b0;                             // first dbus word flag
        dbus_enable <= 'b0;                           // enable dbus tristate drivers
        dma_grant <= 'b0;                             // DMA request granted
        read_grant <= 'b0;                            // read request granted
        
        reset_l <= 'b1;
  
        #4 reset_l <= 'b0;

        #10 reset_l <= 'b1;
        
        #100 $finish;
    end
    
    always begin
      #2 clk = ~clk;
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





si si(
    .clk (clk), 
    .reset_l(reset_l),
    .cbus_read_enable(), 
    .cbus_write_enable(), 
    .cbus_select(), 
    .cbus_command(),
    .dma_start(),  
    .dbus_enable(), 
    .dma_grant(), 
    .read_grant(), 
    .pif_rsp(n64_pif),
    .dma_request(), 
    .read_request(), 
    .interrupt(), 
    .pif_cmd(n64_rsp), 
    .pif_clk(n64_clk),
    .cbus_data(), 
    .dbus_data()
    );
    
endmodule
