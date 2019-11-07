/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2019 Murray Aickin
 */

module N64_interface_external(

    input               clk,
    input               reset_l,
    input [3:0]         cpu_address,
    input               cpu_wren,
    input [7:0]         cpu_data_in,
	input               cpu_oe,
    output reg [7:0]    cpu_data_out,
    output reg          cpu_valid,

    input               n64_clk,
    input               n64_rsp_in,
    output reg          n64_pif_out,
    
    output reg          NMI,
    output reg          INT2,

    output reg [8:0]    pif_interface_address,
    output reg          pif_interface_wren,
    input      [31:0]   pif_interface_data_in,
    output reg [31:0]   pif_interface_data_out
    );
    
    reg         pif_disable;
    reg [7:0]   pif_page;
    reg [7:0]   crap_write;
    
    // pif regs
    
    reg [3:0]   pif_state;
    reg [8:0]   pif_address;
    reg [1:0]   pif_op;
    reg [31:0]  pif_shift_data;
    reg         pif_ack_sent;
    reg         n64_rsp_in_reg, n64_rsp_in_reg1, n64_rsp_in_reg2;
    reg [11:0]  pif_count;
    
    /***************************************************************
    
        CPU Interface
        
    ***************************************************************/
    
    always @(posedge clk or negedge reset_l) begin
        if (~reset_l) begin
            cpu_data_out <= 'b0;
            cpu_valid <= 'b0;
            NMI <= 'b0;
            INT2 <= 'b0;
            pif_disable <= 'b0;
            pif_page <= 'b0;
            crap_write <= 'b0;
        end
        else begin
            cpu_data_out <= 'b0;
            cpu_valid <= cpu_oe;
            pif_disable <= pif_disable;
            pif_page <= pif_page;
            NMI <= NMI;
            INT2 <= INT2;
            crap_write <= crap_write;
            if (cpu_wren) begin
                case (cpu_address)
                    4'h0    : NMI <= |{cpu_data_in};
                    4'h1    : INT2 <= |{cpu_data_in};
                    4'h2    : pif_disable <= |{cpu_data_in};
                    4'h3    : pif_page <= cpu_data_in;
                    default : crap_write <= 8'b0;
                endcase
            end
            else begin
                case (cpu_address)
                    4'h0    : cpu_data_out <= {8{NMI}};
                    4'h1    : cpu_data_out <= {8{INT2}};
                    4'h2    : cpu_data_out <= {8{pif_disable}};
                    4'h3    : cpu_data_out <= pif_page;
                    default : cpu_data_out <= crap_write;
                endcase
            end
        end    
    end


    /****************************************************************
    
        Pif interface location
    
    ****************************************************************/
    
    always @(negedge n64_clk or negedge reset_l ) begin
        if (~reset_l) begin
            n64_rsp_in_reg     <= 1'b1;
            n64_rsp_in_reg1   <= 1'b1;
            n64_rsp_in_reg2   <= 1'b1;
        end
        else begin
            n64_rsp_in_reg     <= n64_rsp_in;
            n64_rsp_in_reg1   <= n64_rsp_in_reg;
            n64_rsp_in_reg2   <= n64_rsp_in_reg1;
        end
    end
    
    // state of the PIF interface
    localparam  idle         =   3'd0;
    localparam  address_get  =   3'd1;
    localparam  decode       =   3'd2;
    localparam  read_ack     =   3'd3;
    localparam  read_data    =   3'd4;
    localparam  write_ark    =   3'd5;
    localparam  write_data   =   3'd6;
    
    
    // what type of operation that we are going to do
    localparam  read_4bytes     =   2'd0;
    localparam  read_64bytes    =   2'd1;
    localparam  write_4bytes    =   2'd2;
    localparam  write_64bytes   =   2'd3;

    always @(posedge n64_clk or negedge reset_l) begin
        if (~reset_l) begin
            pif_state               <= idle;
            n64_pif_out             <= 'b1;
            pif_shift_data          <= 'b0;
            pif_ack_sent            <= 'b0;
            pif_op                  <= 'b0;
            pif_interface_address   <= 'b0;
            pif_interface_wren      <= 'b0;
        end
        else begin
            n64_pif_out <= 1'b1;
            pif_interface_wren <= 1'b0;
            case (pif_state)
                address_get : begin
                    if (pif_count != 10'd0) begin
                        pif_shift_data[11:0]    <= {pif_shift_data[10:0] ,n64_rsp_in_reg};
                        pif_count               <= pif_count - 1'd1;
                        pif_state               <= address_get;
                    end
                    else begin 
                        pif_interface_address   <= pif_shift_data[8:0];
                        pif_op                  <= pif_shift_data[10:09];
                        pif_state               <= decode;
                    end
                end
                decode : begin
                    if (pif_op == write_64bytes) begin  // write 64 bytes DMA
                        pif_shift_data  <= 32'd0;
                        pif_count       <= 10'd0;
                        pif_state       <= write_ark;
                    end
                    if (pif_op == write_4bytes) begin   // write word 
                        pif_shift_data  <= 32'd0;
                        pif_count       <= 10'd0;
                        pif_state       <= write_ark; 
                    end
                    if (pif_op == read_4bytes) begin    // read word
                        pif_shift_data  <= pif_interface_data_in;
                        pif_count       <= 10'd32;
                        pif_state       <= read_ack;
                    end
                    if (pif_op == read_64bytes) begin   // read 64 bytes DMA
                        pif_shift_data  <= pif_interface_data_in;
                        pif_count       <= 10'd512;
                        pif_state       <= read_ack;
                    end
                end
                read_ack : begin
                    n64_pif_out <= 1'b0;
                    pif_state <= read_data;
                end
                read_data : begin
                   if (pif_op == read_4bytes) begin
                        if (pif_count != 0) begin
                            pif_count   <= pif_count -1;
                            n64_pif_out <= pif_interface_data_out [pif_count[4:0]];
                            //pif_shift_data [31:0] <= {pif_shift_data[30:0],1'b0};
                        end
                        else if (pif_count == 0) begin
                            pif_state <= idle;
                        end
                    end
                    if (pif_op == read_64bytes) begin // read64B
                        if (pif_count != 0) begin
                            if (pif_count[4:0] == 0) begin
                                pif_interface_address <= pif_interface_address + 1'd1;   
                            end
                            pif_count <= pif_count -1;
                            n64_pif_out <= pif_interface_data_out [pif_count[4:0]];
                            //pif_shift_data  <= {pif_shift_data[30:0],1'b0};
                        end
                        else if (pif_count == 0) begin
                            pif_state <= idle;
                        end
                    end
                end
                write_ark : begin
                    // issue a write ack to rcp, then wait for ack from rcp
                    if (pif_ack_sent == 0) begin
                        n64_pif_out <= 0; // ack the write operation request
                        pif_ack_sent <= 1;
                    end
                    else if (pif_ack_sent == 1) begin
                        if (n64_rsp_in_reg1 == 0 && n64_rsp_in_reg2 == 1) begin
                            pif_state <= write_data;
                        end
                    end
                end
                write_data : begin
                    if (pif_op == write_64bytes) begin // pif write 64B
                        if (pif_count != 512) begin
                            pif_count <= pif_count +1;
                            pif_shift_data [31:0] <= {pif_shift_data[30:0], n64_rsp_in_reg1};
                            if ((pif_count !== 0) && (pif_count[4:0] == 0)) begin
                                pif_interface_data_out = pif_shift_data;
                                pif_interface_wren <= 1'b1;   
                                pif_interface_address <= pif_interface_address +1;
                            end
                        end
                        else  begin
                            pif_interface_data_out = pif_shift_data;
                            pif_state <= idle; 
                            pif_interface_wren <= 1'b1;
                        end
                    end
                    if (pif_op == write_4bytes) begin // pif write 4B
                        if (pif_count != 32) begin
                            pif_count <= pif_count +1;
                            pif_shift_data [31:0] <= {pif_shift_data[30:0], n64_rsp_in_reg1};
                        end
                        else  begin
                            pif_interface_data_out = pif_shift_data;
                            pif_state <= idle; 
                            pif_interface_wren <= 1'b1;
                        end
                    end
                end
                default : begin
                    if (n64_rsp_in_reg == 0 && n64_rsp_in_reg1 == 1) begin
                        pif_state <= address_get; 
                        pif_count <= 12'd11; // 11 word address shift
                    end
                    pif_ack_sent <= 1'b0; // clear out for next time
                end
            endcase
        end
    end


endmodule
