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
    wire [7:0]  cpu_data_out, ram_6502_out, n64_controller_data_out, pif_rom_out, pif_ram_out, eeprom_data_out, rom_6502_out, crc_data_out, n64_interface_reg_data_out;
    wire        cpu_write;
    reg         cpu_ready;
    
    wire [8:0]  pif_interface_address;
    wire        pif_interface_wren;
    wire [31:0] pif_interface_data_in;
    wire [31:0] pif_interface_data_out;
    
    reg         controller_oe, eeprom_oe, rom_6502_oe,ram_6502_oe, pif_ram_oe, crc_rom_oe, n64_interface_reg_oe, pif_rom_oe, fake_oe;
    wire        controller_valid, eeprom_valid, ram_6502_valid, rom_6502_valid, pif_rom_valid, pif_ram_valid, crc_rom_valid, n64_interface_reg_valid,  fake_valid;
	reg         controller_wr, eeprom_wr, ram_6502_wr, pif_ram_wr, n64_interface_reg_wr;
    
    
    
    always @* begin
        controller_oe <= 'b0;
        eeprom_oe <= 'b0;
        ram_6502_oe <= 'b0;
        pif_ram_oe <= 'b0;
        crc_rom_oe <= 'b0;
        n64_interface_reg_oe <= 'b0;
        pif_rom_oe <= 'b0;
        rom_6502_oe <= 1'b0;
		controller_wr <= 'b0;
        eeprom_wr <= 'b0;
        ram_6502_wr <= 'b0;
        pif_ram_wr <= 'b0;
		n64_interface_reg_wr <= 'b0;
        casez (address)
                16'h028z,
                16'h029z    :   crc_rom_oe <= 1'b1;
                16'h02Az    : begin 
                                controller_oe <= 1'b1; 
                                controller_wr <= cpu_write; 
                                end
                16'h02Bz    : begin 
                                eeprom_oe <= 1'b1; 
                                eeprom_wr <= cpu_write; 
                                end
                16'h02Cz    : begin 
                                n64_interface_reg_oe <= 1'b1; 
                                n64_interface_reg_wr <= cpu_write; 
                                end
                16'h02Dz,
                16'h02Ez,
                16'h02Fz    : fake_oe <= 1'b1;
                16'h00zz,
                16'h01zz    : begin 
                                ram_6502_oe <= 1'b1; 
                                ram_6502_wr <= cpu_write; 
                                end
                16'h1zzz    : begin
                                pif_ram_oe <= 1'b1; 
                                pif_ram_wr <= cpu_write; 
                                end
                                        
                16'h2zzz    : pif_rom_oe <= 1'b1;
                default     : rom_6502_oe <= 1'b1;
            endcase
        end
    
    always @* begin
        casez (address)
            16'h028z,
            16'h029z           : cpu_data_in <= crc_data_out;
            16'h02Az           : cpu_data_in <= n64_controller_data_out;
            16'h02Bz           : cpu_data_in <= eeprom_data_out;
            16'h02Cz           : cpu_data_in <= n64_interface_reg_data_out;
            16'h00zz,
            16'h01zz           : cpu_data_in <= ram_6502_out;
            16'h1zzz           : cpu_data_in <= pif_ram_out; 
            16'h2zzz           : cpu_data_in <= pif_rom_out; 
            default            : cpu_data_in <= rom_6502_out;
        endcase
    end

    always @* begin
        casez (address)
            16'h028z,
            16'h029z           : cpu_ready <= crc_rom_valid;
            16'h02Az           : cpu_ready <= controller_valid;
            16'h02Bz           : cpu_ready <= eeprom_valid;
            16'h02Cz           : cpu_ready <= n64_interface_reg_valid;
            16'h00zz,
            16'h01zz           : cpu_ready <= ram_6502_valid;
            16'h1zzz           : cpu_ready <= pif_ram_valid; 
            16'h2zzz           : cpu_ready <= pif_rom_valid; 
            default            : cpu_ready <= rom_6502_valid;
        endcase
    end
    
    
    cpu6502 cpu6502( 
        .clk    (clk), 
        .reset  (reset_l), 
        .AB     (address), 
        .DI     (cpu_data_in), 
        .DO     (cpu_data_out), 
        .WE     (cpu_write), 
        .IRQ    (reset_button), 
        .NMI    (1'b0), 
        .RDY    (cpu_ready) 
    );
    
    
    N64_controller_top N64_controller_top(
        .clk          (clk),
        .reset_l      (reset_l),
        
        .joy1         (joy1),
        .joy2         (joy2),
        .joy3         (joy3),
        .joy4         (joy4),
        
        .address      (address),
        .data_in_bus  (cpu_data_out),
        .write        (controller_wr),
        .ce           (controller_oe),
        .valid        (controller_valid),
        .data_out_bus (n64_controller_data_out)
    );
    
    
    ram_6502 ram_6502( // this is the ram for the 6502 CPU
        .clk           (clk),
        .address_a     (address),
        .we            (ram_6502_wr),
        .data_a        (cpu_data_out),
        .oe            (ram_6502_oe),
        .valid         (ram_6502_valid),
        .q_a           (ram_6502_out)
    );
    
    rom_6502 rom_6502( // this is the rom for the 6502 CPU - mostly for instructions this is configured
        .clk           (clk),
        .address_a     (address),
        .oe            (rom_6502_oe),
	    .valid		   (rom_6502_valid),
        .q_a           (rom_6502_out)
    );
    
    crc_rom crc_rom( // this is the CRC rom for the 6105 seed
        .clk           (clk),
        .address_a     (address),
        .oe            (crc_rom_oe),
	    .valid		   (crc_rom_valid),
        .q_a           (crc_data_out)
    );
    
    pif_rom pif_rom( // this is the pif rom for the N64 to be uploaded into the ram
        .clk           (clk),
        .address_a     (address),
        .oe            (pif_rom_oe),
	    .valid		   (pif_rom_valid),
        .q_a           (pif_rom_out)
    );
    
    N64_pif_ram N64_pif_ram( // this is the Ram that the PIF interface uses to send the N64 ROM and PIF Ram
        .clka           (clk),
    
        .address_a     (address),
        .wren_a        (pif_ram_wr),
        .data_a        (cpu_data_out),
	    .oe			   (pif_ram_oe),
        .q_a           (pif_ram_out),
        .valid         (pif_ram_valid),

        .clkb          (n64_clk),
        .address_b     (pif_interface_address),
        .wren_b        (pif_interface_wren),
        .data_b        (pif_interface_data_in),
        .q_b           (pif_interface_data_out)
    );
    
    N64_interface_external N64_interface_external(

    .clk                    (clk),
    .reset_l                (reset_l),
    .cpu_address            (address),
    .cpu_wren               (n64_interface_reg_wr),
    .cpu_data_in            (cpu_data_in),
	.cpu_oe                 (n64_interface_reg_oe),
    .cpu_data_out           (n64_interface_reg_data_out),
    .cpu_valid              (n64_interface_reg_valid),

    .n64_clk                (n64_clk),
    .n64_rsp_in             (n64_rsp),
    .n64_pif_out            (n64_pif),
    
    .NMI                    (NMI),
    .INT2                   (INT2),

    .pif_interface_address  (pif_interface_address),
    .pif_interface_wren     (pif_interface_wren),
    .pif_interface_data_in  (pif_interface_data_in),
    .pif_interface_data_out (pif_interface_data_out)
    );
    
endmodule
