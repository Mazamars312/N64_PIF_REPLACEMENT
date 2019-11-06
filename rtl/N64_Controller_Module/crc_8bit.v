`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.11.2019 21:01:50
// Design Name: 
// Module Name: crc_8bit
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


module crc_8bit(
    input clk,
    input reset,
    input [7:0] data_in,
    output reg [7:0] data_out,
    input data_ready
    );
    
    localparam idle     = 3'b000; // we wait
    localparam loop     = 3'b001; // the loop test using the counter
    localparam shift    = 3'b010; // we shift the data_out (crc) to the left by one
    localparam crc_or   = 3'b011; // then we check if we need the last byte to be OR'ed if the data_in == the mask/counter 
    localparam crc_xor  = 3'b100; // then we xor the result
    
    reg    [7:0] xor_trap, xor_trap_c; // = (data_out && 8'h80) ? 8'h85 : 8'h00;
    
    reg     [3:0] count, count_c;
    reg     [7:0] CRC;
    reg     [2:0] state, state_c;
    reg     [7:0] mask;
    
    wire    [7:0] xor_trap_test = (data_out && 8'h80) ? 8'h85 : 8'h00;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 'b0;
            data_out <= 'b0;
            state <= 'b0;
            xor_trap <= 'b0;
        end
        else begin
            count <= count_c;
            data_out <= CRC;
            state <= state_c;
            xor_trap <= xor_trap_c;
        end
    end
    
    always @* begin
        case (state)
            shift   : xor_trap_c <= xor_trap_test;
            default : xor_trap_c <= xor_trap;
        endcase
    end
    
    always @* begin
        case (state)
            loop    :   if (count == 3'd7) state_c <= idle;
                        else state_c <= shift;
            shift   :   state_c <= crc_or;
            crc_or  :   state_c <= crc_xor;
            crc_xor :   state_c <= loop;
            default : begin
                if (data_ready) state_c <= shift;
                else state_c <= idle;
            end
        endcase
    end
    
    always @* begin
        case (state)
            idle    : count_c <= 3'd7;
            crc_xor : count_c <= count - 3'd1;
            default : count_c <= count;
        endcase
    end
    
    always @* begin
        case (state)
            idle    : CRC <= data_out;
            shift   : CRC <= {data_out[6:0],1'b0};
            crc_or  : if (data_in == mask) CRC <= data_out | 8'b0000_0001;
                      else CRC <= data_out;
            crc_xor : CRC <= data_out ^ xor_trap;
            default : CRC <= data_out;
        endcase
    end
    
    always @* begin
        case (count)
            3'd7    : mask <= 8'b1000_0000;
            3'd6    : mask <= 8'b0100_0000;
            3'd5    : mask <= 8'b0010_0000;
            3'd4    : mask <= 8'b0001_0000;
            3'd3    : mask <= 8'b0000_1000;
            3'd2    : mask <= 8'b0000_0100;
            3'd1    : mask <= 8'b0000_0010;
            default : mask <= 8'b0000_0001;
        endcase
    end
    
    
endmodule
