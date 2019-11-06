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
    reg  [7:0]  cpu_data_in;
    wire [7:0]  cpu_data_out, ram_data_out, n64_controller_data_out, pif_ram_data_out, eeprom_data_out, rom_data_out, crc_rom_data_out, n64_interface_reg_data_out;
    wire        cpu_write;
    wire        ready;
    
    reg         controller_oe, eeprom_oe, ram_oe, pif_ram_oe, crc_rom_oe, n64_interface_reg_oe, rom_oe, fake_oe;
    
    
    
    always @* begin
        controller_oe <= 'b0;
        eeprom_oe <= 'b0;
        ram_oe <= 'b0;
        pif_ram_oe <= 'b0;
        crc_rom_oe <= 'b0;
        n64_interface_reg_oe <= 'b0;
        rom_oe <= 'b0;
        if (address <= 15'h00ff) begin
            casez (address[7:0])
//                8'b0zzz_zzzz    : pif_ram_oe <= 1'b1; we do this with the default
                8'h8z,
                8'h9z           : crc_rom_oe <= 1'b1;
                8'hAz           : controller_oe <= 1'b1;
                8'hBz           : eeprom_oe <=1'b1;
                8'hCz           : n64_interface_reg_oe <= 1'b1;
                8'hDz           : fake_oe <= 1'b1;
                8'hEz           : fake_oe <= 1'b1;
                8'hFz           : fake_oe <= 1'b1;
                default     : pif_ram_oe <= 1'b1;
            endcase
        end
        else begin
            if (address >= 15'h0400) crc_rom_oe <= 1'b1;
            else ram_oe <= 1'b1;
        end
    end
    
    always @* begin
        cpu_data_in <= 15'h0000;
        if (address <= 15'h00ff) begin
            casez (address[7:0])
                8'h8z,
                8'h9z           : cpu_data_in <= crc_rom_data_out;
                8'hAz           : cpu_data_in <= n64_controller_data_out;
                8'hBz           : cpu_data_in <= eeprom_data_out;
                8'hCz           : cpu_data_in <= n64_interface_reg_data_out;
                8'hDz           : cpu_data_in <= 15'h0000;
                8'hEz           : cpu_data_in <= 15'h0000;
                8'hFz           : cpu_data_in <= 15'h0000;
                default         : cpu_data_in <= pif_ram_data_out;
            endcase
        end
        else begin
            if (address >= 15'h0400) cpu_data_in <= ram_data_out;
            else cpu_data_in <= rom_data_out;
        end
    end
    
    
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
    
    
    N64_controller_top N64_controller_top(
    .clk          (clk),
    .reset_l      (reset_l),
    
    .joy1         (joy1),
    .joy2         (joy2),
    .joy3         (joy3),
    .joy4         (joy4),
    
    .address      (address),
    .data_in_bus  (cpu_data_out),
    .write        (write),
    .ce           (ce),
    .data_out_bus (n64_controller_data_out)
    );
    
endmodule
