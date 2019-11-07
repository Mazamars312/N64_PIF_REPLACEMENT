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
    reg         cpu_ready;
    
    reg         controller_oe, eeprom_oe, ram_oe, pif_ram_oe, crc_rom_oe, n64_interface_reg_oe, pif_rom_oe, fake_oe;
    wire        controller_valid, eeprom_valid, ram_valid, pif_ram_valid, crc_rom_valid, n64_interface_reg_valid, pif_rom_valid, fake_valid;
	reg         controller_wr, eeprom_wr, ram_wr, pif_ram_wr, n64_interface_reg_wr;
    
    
    
    always @* begin
        controller_oe <= 'b0;
        eeprom_oe <= 'b0;
        ram_oe <= 'b0;
        pif_ram_oe <= 'b0;
        crc_rom_oe <= 'b0;
        n64_interface_reg_oe <= 'b0;
        pif_rom_oe <= 'b0;
		controller_wr <= 'b0;
        eeprom_wr <= 'b0;
        ram_wr <= 'b0;
        pif_ram_wr <= 'b0;
		n64_interface_reg_wr <= 'b0;
        if (address <= 15'h00ff) begin
            casez (address[7:0])
                8'h8z,
                8'h9z           : crc_rom_oe <= 1'b1;
                8'hAz           : begin 
									controller_oe <= 1'b1; 
									controller_wr <= cpu_write; 
									end
                8'hBz           : begin 
									eeprom_oe <= 1'b1; 
									eeprom_wr <= cpu_write; 
									end
                8'hCz           : begin 
									n64_interface_reg_oe <= 1'b1; 
									n64_interface_reg_wr <= cpu_write; 
									end
                8'hDz           : fake_oe <= 1'b1;
                8'hEz           : fake_oe <= 1'b1;
                8'hFz           : fake_oe <= 1'b1;
                default     : begin 
								pif_ram_oe <= 1'b1; 
								pif_ram_wr <= cpu_write; 
								end
            endcase
        end
        else begin
            if (address >= 15'h0400) pif_rom_oe <= 1'b1;
            else begin 
				ram_oe <= 1'b1; 
				ram_wr <= cpu_write; 
			end
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
    
    always @* begin
        cpu_ready <= 15'h0000;
        if (address <= 15'h00ff) begin
            casez (address[7:0])
                8'h8z,
                8'h9z           : cpu_ready <= crc_rom_valid;
                8'hAz           : cpu_ready <= controller_valid;
                8'hBz           : cpu_ready <= eeprom_valid;
                8'hCz           : cpu_ready <= n64_interface_reg_valid;
                8'hDz           : cpu_ready <= 1'b1;
                8'hEz           : cpu_ready <= 1'b1;
                8'hFz           : cpu_ready <= 1'b1;
                default         : cpu_ready <= pif_ram_valid;
            endcase
        end
        else begin
            if (address >= 15'h0400) cpu_ready <= ram_valid;
            else cpu_ready <= pif_rom_valid;
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
    
    
    pif_ram pif_ram( // this is the rom for the 6502 CPU
        .clk           (clk),
        .address_a     (address),
        .we            (ram_wr),
        .data_a        (cpu_data_out),
        .oe            (ram_oe),
        .valid         (ram_valid),
        .q_a           (ram_data_out)
    );
    
    pif_rom pif_rom(
        .clk           (clk),
        .address_a     (address),
        .oe            (pif_rom_oe),
	    .valid		   (pif_rom_valid),
        .q_a           (rom_data_out)
    );
    
    crc_rom crc_rom(
        .clk           (clk),
        .address_a     (address),
        .oe            (crc_rom_oe),
	    .valid		   (crc_rom_valid),
        .q_a           (rom_data_out)
    );
    
    N64_pif_ram N64_pif_ram(
        .clka           (clk),
    
        .address_a     (address),
        .wren_a        (pif_ram_wr),
        .data_a        (cpu_data_out),
	    .oe			   (pif_ram_oe),
        .q_a           (pif_ram_data_out),
        .valid         (pif_ram_valid),
    
        .clkb          (n64_clk),
        .address_b     (pif_interface_address),
        .wren_b        (pif_interface_wren),
        .data_b        (pif_interface_data_in),
        .q_b           (pif_interface_data_out)
    );
    
endmodule
