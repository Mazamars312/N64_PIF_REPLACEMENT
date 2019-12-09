`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2019 06:24:40
// Design Name: 
// Module Name: EEPROM_interface_core
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


module EEPROM_interface_core(
    	input clk,
		input reset_l,

//		output reg [33:0]buttons=34'd0,
//		output reg alive=1'd0,
        output eprom_clk,
        inout eprom_data,

		input [3:0]       address,
		input [7:0]       data_in_bus,
		input             write,
		input             ce,
		output reg        valid,
		output reg [7:0]  data_out_bus
    );
    
// generate 100 Hz from 50 MHz
reg [17:0] count_reg = 0;
reg out_100hz = 0;

reg [7:0]   fifo_buffer_read    [32:0];
reg [7:0]   fifo_buffer_read_write_data;
wire [7:0]  fifo_buffer_read_read_data;
reg [6:0]   fifo_buffer_read_count;
reg         fifo_buffer_read_empty;
reg         fifo_buffer_read_write;
reg         fifo_buffer_read_read;
reg [7:0]   fifo_buffer_write    [32:0];
reg [7:0]   fifo_buffer_write_write_data;
wire [7:0]  fifo_buffer_write_read_data;
reg [6:0]   fifo_buffer_write_count;
reg         fifo_buffer_write_empty;
reg         fifo_buffer_write_write;
reg         fifo_buffer_write_read;

wire [7:0]  eeprom_data_in, eeprom_data_out;
wire        tx_data_req,rx_data_ready;

wire        empty_read_fifo_status;
wire        empty_write_fifo_status;

reg         empty_read_fifo;
reg         empty_write_fifo;

reg [7:0]   cmd_to_eeprom;
reg         ready;
reg         processing;
reg         eeprom_enable;

reg [7:0]   byte_count;

reg [7:0]   address_high;
reg [7:0]   address_low;

wire        eeprom_completed;
reg         eeprom_start;
reg         eeprom_wr;

reg [7:0]   state;

						//counter_en___finish_______oe__get__state
localparam IDLE_FSM         =	8'd0;
localparam START_PROCESS    =	8'd1;
localparam SEND_CMD         =	8'd3;
localparam SEND_ADDRESS     =	8'd2;
localparam SEND_DATA        =	8'd3;
localparam RECEIVE_DATA     =	8'd4;

    
    always @(posedge clk or negedge reset_l) begin
    if (~reset_l) begin
        fifo_buffer_write_write <= 1'b0;
        data_out_bus <= 'bz;
        fifo_buffer_read_read <= 'b0;
        fifo_buffer_write_write_data <= 'b0;
        fifo_buffer_write_write <= 'b0;
        cmd_to_eeprom <= 'b0;
        address_high <= 'b0;
        eeprom_enable <= 'b0;
        ready <= 'b1;
        processing <= 'b0;
        empty_write_fifo <= 'b0;
        empty_read_fifo <= 'b0;
        valid <= 'b0;
        byte_count <= 'b0;
    end
    else begin
        fifo_buffer_write_write <= 1'b0;
        data_out_bus <= 'bz;
        fifo_buffer_read_read <= 'b0;
        valid <= ce;
        empty_read_fifo <= 'b0;
        empty_write_fifo <= 'b0;
        if (write && ce) begin
            case (address)
                4'h00 : begin
                    cmd_to_eeprom <= data_in_bus;
                end
                4'h01 : begin
                    address_high <= data_in_bus;
                end
                4'h02 : begin
                    address_low <= data_in_bus;
                end
                4'h03 : begin
                    byte_count <= data_in_bus;
                end
                4'h05 : begin
                    {empty_write_fifo, empty_read_fifo, eeprom_enable} <= data_in_bus[2:0];
                    if (|{data_in_bus[0]}) begin
                        ready <= 1'b0;
                    end
                end

                4'h07 : begin
                    fifo_buffer_write_write_data <= data_in_bus;
                    fifo_buffer_write_write <= 1'b1;
                end
                
                default : begin
                end
            endcase
        end
        if (~write && ce) begin
            case (address)
                4'h00 : begin
                    data_out_bus <= cmd_to_eeprom;
                end
                4'h01 : begin
                    data_out_bus <= address_high;
                end
                4'h02 : begin
                    data_out_bus <= address_low;
                end
                4'h04 : begin
                    data_out_bus <= {ready, processing, empty_write_fifo_status, empty_read_fifo_status,
                                     eeprom_enable}; // notused on reads

                end
                4'h06 : begin
                    data_out_bus <= fifo_buffer_read_read_data;
                    fifo_buffer_read_read <= 1'b1;
                end
                default : begin

                end
            endcase
        end

        if(state == IDLE_FSM && processing)begin
            eeprom_enable <= 'b0;
        end
        if (~processing) ready <= 'b1;
        if (state == IDLE_FSM) processing <= 'b0; else processing <= 'b1;
    end
end

always @(posedge clk or negedge reset_l) begin
    if (reset_l) begin
        count_reg <= 0;
        out_100hz <= 0;
    end else begin
        if (count_reg < 249999) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            out_100hz <= ~out_100hz;
        end
    end
end

//n64_eeprom_fifo #(
//    .width          (8),
//    .widthu         (4)
//)
//n64_eeprom_fifo_read(
//    .clk_in         (out_100hz),
//    .clk_out        (clk),
//    .rst_n          (reset_l),
//    // for the CPU
//    .sclr           (empty_read_fifo),
//    .rdreq          (fifo_buffer_read_read),   //input
//    .empty          (empty_read_fifo_status),
//    .q              (fifo_buffer_read_read_data),
//    // for the controller
//    .wrreq          (rx_data_ready),   //input
//    .data           (eeprom_data_out)    //input [7:0]
//);

    FIFO36E1 #(
      .ALMOST_EMPTY_OFFSET(13'h0080),    // Sets the almost empty threshold
      .ALMOST_FULL_OFFSET(13'h0080),     // Sets almost full threshold
      .DATA_WIDTH(8),                    // Sets data width to 4-72
      .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
      .EN_ECC_READ("FALSE"),             // Enable ECC decoder, FALSE, TRUE
      .EN_ECC_WRITE("FALSE"),            // Enable ECC encoder, FALSE, TRUE
      .EN_SYN("FALSE"),                  // Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
      .FIFO_MODE("FIFO36"),              // Sets mode to "FIFO36" or "FIFO36_72" 
      .FIRST_WORD_FALL_THROUGH("TRUE"),  // Sets the FIFO FWFT to FALSE, TRUE
      .INIT(72'h000000000000000000),     // Initial values on output port
      .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
      .SRVAL(72'h000000000000000000)     // Set/Reset value for output port
   )
   FIFO36E1_read (
      // Read Data: 64-bit (each) output: Read output data
      .DO(fifo_buffer_read_read_data),                       // 64-bit output: Data output
      // Status: 1-bit (each) output: Flags and other FIFO status outputs
      .EMPTY(empty_write_fifo_status),                 // 1-bit output: Empty flag

      // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
      .RDCLK(clk),                 // 1-bit input: Read clock
      .RDEN(fifo_buffer_read_read),                   // 1-bit input: Read enable
      .REGCE(1'b1),                 // 1-bit input: Clock enable
      .RST(reset_l),                     // 1-bit input: Reset
      // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
      .WRCLK(out_100hz),                 // 1-bit input: Rising edge write clock.
      .WREN(rx_data_ready),                   // 1-bit input: Write enable
      // Write Data: 64-bit (each) input: Write input data
      .DI(eeprom_data_out) 
      
   );

//n64_eeprom_fifo #(
//    .width          (8),
//    .widthu         (4)
//)
//n64_eeprom_fifo_write(
//    .clk_in         (clk),
//    .clk_out        (out_100hz),
//    .rst_n          (reset_l),
//     // for the CPU
//    .sclr           (empty_write_fifo),
//    .wrreq          (fifo_buffer_write_write),
//    .empty          (empty_write_fifo_status),
//    .data           (fifo_buffer_write_write_data),
//    // for the controller
//    .rdreq          (tx_data_req),   //input
//    .q              (eeprom_data_in)
//);
    
    FIFO36E1 #(
      .ALMOST_EMPTY_OFFSET(13'h0080),    // Sets the almost empty threshold
      .ALMOST_FULL_OFFSET(13'h0080),     // Sets almost full threshold
      .DATA_WIDTH(8),                    // Sets data width to 4-72
      .DO_REG(1),                        // Enable output register (1-0) Must be 1 if EN_SYN = FALSE
      .EN_ECC_READ("FALSE"),             // Enable ECC decoder, FALSE, TRUE
      .EN_ECC_WRITE("FALSE"),            // Enable ECC encoder, FALSE, TRUE
      .EN_SYN("FALSE"),                  // Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
      .FIFO_MODE("FIFO36"),              // Sets mode to "FIFO36" or "FIFO36_72" 
      .FIRST_WORD_FALL_THROUGH("TRUE"),  // Sets the FIFO FWFT to FALSE, TRUE
      .INIT(72'h000000000000000000),     // Initial values on output port
      .SIM_DEVICE("7SERIES"),            // Must be set to "7SERIES" for simulation behavior
      .SRVAL(72'h000000000000000000)     // Set/Reset value for output port
   )
   FIFO36E1_write (
      // Read Data: 64-bit (each) output: Read output data
      .DO(eeprom_data_in),                       // 64-bit output: Data output
      // Status: 1-bit (each) output: Flags and other FIFO status outputs
      .EMPTY(empty_write_fifo_status),                 // 1-bit output: Empty flag

      // Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
      .RDCLK(out_100hz),                 // 1-bit input: Read clock
      .RDEN(tx_data_req),                   // 1-bit input: Read enable
      .REGCE(1'b1),                 // 1-bit input: Clock enable
      .RST(reset_l),                     // 1-bit input: Reset
      // Write Control Signals: 1-bit (each) input: Write clock and enable input signals
      .WRCLK(clk),                 // 1-bit input: Rising edge write clock.
      .WREN(fifo_buffer_write_write),                   // 1-bit input: Write enable
      // Write Data: 64-bit (each) input: Write input data
      .DI(fifo_buffer_write_write_data) 
      
   );
    
//      Lets have this ready

    i2c_master i2c_master(
		.clk              (out_100hz),
		.reset_l          (reset_l),
		.start            (eeprom_start),
		
		.nbytes_in        (byte_count),
		.address_high     (address_high[6:0]),
		.address_low      (address_low),
		.rw_in            (eeprom_wr),
		.completed        (eeprom_completed),
		.write_data       (eeprom_data_in),
		.read_data        (eeprom_data_out),
		.tx_data_req      (tx_data_req), 
		.rx_data_ready    (rx_data_ready), 
		
		.sda_w            (eprom_data),
		.scl              (eprom_clk)
	);
endmodule


//module n64_eeprom_fifo(
//    input                       clk_read,
//    input                       clk_write,
//    input                       rst_n,
//    input                       sclr,

//    input                       rdreq,
//    input                       wrreq,
//    input       [width-1:0]     data,

//    output                      empty,
//    output reg                  full,
//    output      [width-1:0]     q,
//    output reg  [widthu-1:0]    usedw
//);

//parameter width     = 2;
//parameter widthu    = 2;

//reg [width-1:0] mem [(2**widthu)-1:0];

//reg [widthu-1:0] rd_index = 0;
//reg [widthu-1:0] wr_index = 0;

//assign q    = mem[rd_index];
//assign empty= usedw == 0 && ~(full);

//always @(posedge clk_read or negedge rst_n) begin
//    if(rst_n == 1'b0)           rd_index <= 0;
//    else if(sclr)               rd_index <= 0;
//    else if(rdreq && ~(empty))  rd_index <= rd_index + { {widthu-1{1'b0}}, 1'b1 };
//end

//always @(posedge clk_write or negedge rst_n) begin
//    if(rst_n == 1'b0)                       wr_index <= 0;
//    else if(sclr)                           wr_index <= 0;
//    else if(wrreq && (~(full) || rdreq))    wr_index <= wr_index + { {widthu-1{1'b0}}, 1'b1 };
//end

//always @(posedge clk_write) begin
//    if(wrreq && (~(full) || rdreq)) mem[wr_index] <= data;
//end

//always @(posedge clk_write or negedge rst_n) begin
//    if(rst_n == 1'b0)                                               full <= 1'b0;
//    else if(sclr)                                                   full <= 1'b0;
//    else if(rdreq && ~(wrreq) && full)                              full <= 1'b0;
//    else if(~(rdreq) && wrreq && ~(full) && usedw == (2**widthu)-1) full <= 1'b1;
//end

//always @(posedge clk or negedge rst_n) begin
//    if(rst_n == 1'b0)                       usedw <= 0;
//    else if(sclr)                           usedw <= 0;
//    else if(rdreq && ~(wrreq) && ~(empty))  usedw <= usedw - { {widthu-1{1'b0}}, 1'b1 };
//    else if(~(rdreq) && wrreq && ~(full))   usedw <= usedw + { {widthu-1{1'b0}}, 1'b1 };
//    else if(rdreq && wrreq && empty)        usedw <= { {widthu-1{1'b0}}, 1'b1 };
//end

//endmodule

