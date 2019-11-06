/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2019 Murray Aickin
 */


module N64_PIF_TOP(
    input n64_clk,
    input n64_rsp,
    output n64_pif,
    inout joy1,
    inout joy2,
    inout joy3,
    inout joy4,
    output eprom_clk,
    inout eprom_data,
    input reset_button,
    output NMI,
    output INT2,
    input clk,
    input reset_l
    );
    
    wire [15:0] address;
    wire [7:0]  cpu_data_in, cpu_data_out;
    wire        cpu_write;
    wire        ready;
    
    
    cpu6502 cpu6502( 
    .clk    (clk), 
    .reset  (reset_l), 
    .AB     (address), 
    .DI     (cpu_data_in), 
    .DO     (cpu_data_out), 
    .WE     (cpu_write), 
    .IRQ    (1'b0), 
    .NMI    (1'b0), 
    .RDY    (ready) );
    
    
endmodule
