// --------------------------------------------------------------------
// Copyright (c) 2017 by FPGALOVER 
// --------------------------------------------------------------------
//                     web: http://www.fpgalover.com
//                     email: admin@fpgalover.com or hbecerra@ece.ubc.ca
// --------------------------------------------------------------------
// First Author: Holguer Andres Becerra Daza
// Module: N64 Controller Interface
// Re-edited for the N64PIF controller By Murray Aickin
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

module N64_controller_top(
		input clk,
		input reset_l,

//		output reg [33:0]buttons=34'd0,
//		output reg alive=1'd0,
		inout joy1,
		inout joy2,
		inout joy3,
		inout joy4,
		
		input [3:0]       address,
		input [7:0]       data_in_bus,
		input             write,
		input             ce,
		output reg [7:0]  data_out_bus
);


						//counter_en___finish_______oe__get__state
localparam IDLE_FSM		 =	8'b0___________0________0___0_0000;
localparam POLL_FSM		 =	8'b0___________0________1___0_0000;
localparam SEND0_FSM1	 =	8'b0___________0________1___0_0010;
localparam SEND0_FSM2	 =	8'b0___________0________1___0_0011;
localparam SEND1_FSM1	 =	8'b0___________0________1___0_0100;
localparam SEND1_FSM2	 =	8'b0___________0________1___0_0101;
localparam SENT_COMMAND	 =	8'b0___________0________1___0_0111;
localparam GET_FSM 		 =	8'b1___________0________0___0_0110;
localparam FINISH_FSM 	 =	8'b0___________1________0___0_1110;

localparam THREEuSECONDS = 32'd150;
localparam ONEuSECONDS = 32'd50;
localparam HUNDRED_MS = 32'd400000;
  

reg [7:0]   state=IDLE_FSM;
reg [31:0]  counter_delay =32'd0;
reg [31:0]  counter_delay_pulses =32'd0;
reg [8:0]   counter_polling =7'd0;
reg [5:0]   counting_data =6'd0;
//=9'b110000000;
reg [33:0]  buffer_buttons=34'd0;
reg [2:0]   controller_8bit_counter;
wire        counter_en=state[7];
wire        oe=state[5];
wire        finish=state[6];
wire        counting_data_clk=state[4];
wire        data_out=state[0];
reg         data_in=1'b0;
reg         start_counter=1'b0;

//		inout data,
reg         start;

// Below is the new code

reg [7:0]   cmd_to_controller;
reg [7:0]   address_high;
reg [7:0]   address_low;

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

wire        empty_read_fifo_status;
wire        empty_write_fifo_status;

reg         empty_read_fifo;
reg         empty_write_fifo;

reg         ready;
reg         processing;
reg         joy1_enable;
reg         joy2_enable;
reg         joy3_enable;
reg         joy4_enable;

reg [7:0]  contorller_input_8;   

wire [7:0] fifo_buffer_write_controller;

/*****************************************************************************************

    This is the Interface from the CPU and will interface to the regs that setup the 
    command, address for MEM access (Last 5bits are the CRC) and the data to be sent.
    
        address lines
        0x0000 - cmd [7:0]
        0x0001 - high address[15:8] 
        0x0010 - Low address[7:5]/CRC[4:0]
        0x0011 - Controller status 
        0x0100 - Controller control
        0x0101 - Read fifo (8-bits)
        0x0110 - Write fifo (8-bits)
        
      Controller Status bits - This is read only
        [7] - Ready
        [6] - Processing a FIFO/Controller accessing
        [5] - the Write FIFO is empty
        [4] - the Read FIFO is empty
        [3] - Joystick port 4 is being access/processed
        [2] - Joystick port 3 is being access/processed
        [1] - Joystick port 2 is being access/processed
        [0] - Joystick port 1 is being access/processed  
        
        
      Controller Control bits - This is write only - Once writen to the controller will start running. 
      Try to only write one bit at a time.

        [5] - the Write FIFO is to be emptied
        [4] - the Read FIFO is to be emptied
        [3] - Joystick port 4 is to be processed - no over controller will be processed
        [2] - Joystick port 3 is to be processed - no over controller will be processed
        [1] - Joystick port 2 is to be processed - no over controller will be processed
        [0] - Joystick port 1 is to be processed - no over controller will be processed

******************************************************************************************/

always @(posedge clk or negedge reset_l) begin
    if (~reset_l) begin
        fifo_buffer_write_write <= 1'b0;
        data_out_bus <= 'bz;
        fifo_buffer_read_read <= 'b0;
        fifo_buffer_write_write_data <= 'b0;
        fifo_buffer_write_write <= 'b0;
        cmd_to_controller <= 'b0;
        address_high <= 'b0;
        joy4_enable <= 'b0;
        joy3_enable <= 'b0;
        joy2_enable <= 'b0;
        joy1_enable <= 'b0;
        ready <= 'b1;
        processing <= 'b0;
        empty_write_fifo <= 'b0;
        empty_read_fifo <= 'b0;

    end
    else begin
        fifo_buffer_write_write <= 1'b0;
        data_out_bus <= 'bz;
        fifo_buffer_read_read <= 'b0;

        empty_read_fifo <= 'b0;
        empty_write_fifo <= 'b0;
        if (write && ce) begin
            case (address)
                3'b0000 : begin
                    cmd_to_controller <= data_in_bus;
                end
                3'b0001 : begin
                    address_high <= data_in_bus;
                end
                3'b0010 : begin
                    address_low <= data_in_bus;
                end

                3'b0100 : begin
                    {empty_write_fifo,empty_read_fifo,joy4_enable,joy3_enable,joy2_enable,joy1_enable} <= data_in_bus[5:0];
                    if (|{data_in_bus[3],data_in_bus[2],data_in_bus[1],data_in_bus[0]}) begin 

                        ready <= 1'b0;
                    end
                end

                3'b0110 : begin
                    fifo_buffer_write_write_data <= data_in_bus;
                    fifo_buffer_write_write <= 1'b1;
                end
                default : begin
                end
            endcase
        end
        if (~write && ce) begin
            case (address)
                3'b0000 : begin
                    data_out_bus <= cmd_to_controller;
                end
                3'b0001 : begin
                    data_out_bus <= address_high;
                end
                3'b0010 : begin
                    data_out_bus <= address_low;
                end
                3'b0011 : begin
                    data_out_bus <= {ready, processing, empty_write_fifo_status, empty_read_fifo_status,
                                     joy4_enable, joy3_enable, joy2_enable, joy1_enable}; // notused on reads
                    
                end
                3'b0101 : begin
                    data_out_bus <= fifo_buffer_read_read_data;
                    fifo_buffer_read_read <= 1'b1;
                end
                default : begin
    
                end
            endcase
        end
        
        if(state[6])begin
            joy4_enable <= 'b0;
            joy3_enable <= 'b0;
            joy2_enable <= 'b0;
            joy1_enable <= 'b0;
        end
        if (~processing) ready <= 'b1;
        if (state == IDLE_FSM) processing <= 'b0; else processing <= 'b1;
    end
end

// this works in bytes so make sure if you are doing 32bits that you have this as 4 bytes for counting. This is also the real number as well.

reg [8:0] counter_receive;
reg [8:0] counter_send;
reg [3:0] counter_command;
reg       address_send;
reg       read_write; //1 == read;


/*********************************************************

    Commands
        0x00 - Status of controller
        0x01 - Read controller buttons
        0x02 - Read Ram
        0x03 - Write ram
        0xff - reset controller

*********************************************************/

always @* begin
    case (cmd_to_controller)
        8'h00 : begin
            counter_receive <= 9'd24;
            counter_send <= 9'd0;
            counter_command <= 4'd8;
            address_send <= 0;
            read_write <= 1;
        end
        8'h01 : begin
            counter_receive <= 9'd32;
            counter_send <= 9'd0;
            counter_command <= 4'd8;
            address_send <= 0;
            read_write <= 1;
        end
        8'h02 : begin
            counter_receive <= 9'd264;
            counter_send <= 9'd0;
            counter_command <= 4'd8;
            address_send <= 1;
            read_write <= 1;
        end
        8'h03 : begin
            counter_receive <= 9'd0;
            counter_send <= 9'd264;
            counter_command <= 4'd8;
            address_send <= 1;
            read_write <= 0;
        end
        8'hff : begin
            counter_receive <= 9'd0;
            counter_send <= 9'd0;
            counter_command <= 4'd8;
            address_send <= 0;
            read_write <= 1;
        end
    endcase
end



//assign data = oe ? data_out: 1'bz;
// Joystick output enabling code. we want the output to always begin driven high unless we want to use that controller
assign joy1 = joy1_enable ? (oe ? data_out : 1'bz) : 1'b1;
assign joy2 = joy2_enable ? (oe ? data_out : 1'bz) : 1'b1;
assign joy3 = joy3_enable ? (oe ? data_out : 1'bz) : 1'b1;
assign joy4 = joy4_enable ? (oe ? data_out : 1'bz) : 1'b1;
 
always@(posedge clk)
begin
    casez ({joy4_enable, joy3_enable, joy2_enable,joy1_enable})
       4'b1zzz : data_in <= joy4;
	   4'b01zz : data_in <= joy3;
	   4'b001z : data_in <= joy2;
	   default : data_in <= joy1;
	endcase
end

/***********************************************************

    Here is the setup FSM that we can use to setup the
    Controller FSM and counters

***********************************************************/

reg [2:0] FSM_Main, FSM_Main_c;

reg [3:0] counter_command_count, counter_command_count_c;
reg [8:0] counter_receive_count, counter_receive_count_c;
reg [8:0] counter_send_count, counter_send_count_c;
reg [3:0] counter_send_address_count, counter_send_address_count_c;
reg       fifo_write_next, fifo_write_next_c;
reg       fifo_read_next, fifo_read_next_c;
reg       fifo_read_data_next, fifo_read_data_next_c;
reg       controller_active, controller_active_c;

reg [7:0]  sending_data, sending_data_c;

localparam idle_con         =	3'd0;
localparam sendcommand      =	3'd1;
localparam sendaddress      =	3'd2;
localparam senddata         =	3'd3;
localparam receivedata      =	3'd4;
localparam stopbit          =	3'd5;


always @(posedge clk or negedge reset_l) begin
    if (~reset_l) begin
        FSM_Main <= idle_con;
        sending_data <= 'b0;
        counter_command_count <= 'b0;
        counter_receive_count <= 'b0;
        counter_send_count <= 'b0;
        counter_send_address_count <= 'b0;
        fifo_write_next <= 'b0;
        fifo_read_next <= 'b0;
        fifo_read_data_next <= 'b0;
        controller_active <= 'b0;
    end
    else begin
        FSM_Main <= FSM_Main_c;
        sending_data <= sending_data_c;
        counter_command_count <= counter_command_count_c;
        counter_receive_count <= counter_receive_count_c;
        counter_send_count <= counter_send_count_c;
        counter_send_address_count <= counter_send_address_count_c;
        fifo_write_next <= fifo_write_next_c;
        fifo_read_next <= fifo_read_next_c;
        fifo_read_data_next <= fifo_read_data_next_c;
        controller_active <= controller_active_c;
    end
end

always @* begin
    case (FSM_Main)
        sendcommand : begin
            if (counter_command_count == 4'h1 && (state == SENT_COMMAND)) begin
                if (address_send == 1) FSM_Main_c <= sendaddress;
                else FSM_Main_c <= stopbit;
            end
            else FSM_Main_c <= sendcommand;
        end
        stopbit : begin
            if (state != SEND1_FSM2) FSM_Main_c <= stopbit; //&& counter_polling == 'b0
            else begin
                if (counter_receive == 6'd0) FSM_Main_c <= idle_con;
                else FSM_Main_c <= receivedata;
            end
        end
        sendaddress : begin
            if (counter_send_address_count == 6'd0 && (state == SENT_COMMAND)) begin 
                if (read_write == 1) FSM_Main_c <= stopbit; 
                else FSM_Main_c <= senddata; 
            end
            else FSM_Main_c <= sendaddress;
        end
        senddata : begin
            if (counter_send_count == 6'd0 && (state == SENT_COMMAND)) FSM_Main_c <= stopbit;
            else FSM_Main_c <= senddata;
        end
        receivedata : begin
            if (counter_receive_count == 6'd0) FSM_Main_c <= idle_con;
            else FSM_Main_c <= receivedata;
        end
        default : begin
            if (|{joy4_enable, joy3_enable, joy2_enable, joy1_enable} && ~processing) FSM_Main_c <= sendcommand; // send status
            else FSM_Main_c <= idle_con;
        end
    endcase
end

/***********************************************************

    This is the sending the data to the controller FSM

***********************************************************/



always @* begin
    case (FSM_Main_c)
        sendcommand : begin
            sending_data_c <= cmd_to_controller;
        end
        stopbit : begin
            sending_data_c <= 8'b1111_1111; // We just have every number as a stopbit
        end
        sendaddress : begin
           if (counter_send_address_count[3] == 1'b1) sending_data_c <= address_high;
           else sending_data_c <= address_low;
        end
        senddata : begin
           sending_data_c <= fifo_buffer_write_controller;
        end
        default : begin
           sending_data_c <= 'b1;
        end
    endcase
end

/***********************************************************

    This is the to keep the controller fms running for sending data

***********************************************************/

always @* begin
    case (FSM_Main)
        idle_con : begin
          if (start) controller_active_c <= 1'b1;
          else controller_active_c <= 1'b0;
        end
        stopbit : begin
           if (state == SEND1_FSM2) controller_active_c <= 1'b1;
           else controller_active_c <= 1'b1;
        end
        receivedata : begin
           controller_active_c <= 1'b0;
        end
        default : begin
           controller_active_c <= 1'b1;
        end
    endcase
end

/***********************************************************

    This is the sending the data to the controller FSM

***********************************************************/

always @* begin
    case (FSM_Main)
        idle_con : begin
           if (|{joy4_enable, joy3_enable, joy2_enable, joy1_enable} && ~processing) start <= 1'b1;
           else start <= 1'b0;
        end
        default : begin
           start <= 1'b0;
        end
    endcase
end


/***********************************************************

    This is the sending the data to the controller FSM

***********************************************************/



always @* begin
    case (FSM_Main)
        senddata : begin
           if (counter_send_address_count[2:0] == 3'd0)fifo_write_next_c <= 1'b1;
           else fifo_write_next_c <= 1'b0;
        end
        default : begin
           fifo_write_next_c <= 'b0;
        end
    endcase
end



/***********************************************************

    This is the sending the data to the controller FSM

***********************************************************/



always @* begin
    case (FSM_Main)
        receivedata : begin
           if (receivedata[2:0] == 3'd0) fifo_read_next_c <= 1'b1;
           else fifo_read_next_c <= 1'b0;
        end
        default : begin
           fifo_read_next_c <= 'b0;
        end
    endcase
end


/***********************************************************

    read data fifo controller for reading

***********************************************************/

always @* begin
    case (FSM_Main)
        receivedata : begin
           if (receivedata[2:0] == 3'd0) fifo_read_data_next_c <= contorller_input_8;
           else fifo_read_data_next_c <= 1'b0;
        end
        default : begin
           fifo_read_data_next_c <= 'b0;
        end
    endcase
end


/***********************************************************

    command counter

***********************************************************/

always @* begin
    case (FSM_Main)
        sendcommand : begin
           if (state == SENT_COMMAND)counter_command_count_c <= counter_command_count - 4'd1;
           else counter_command_count_c <= counter_command_count;
        end
        default : begin
           counter_command_count_c <= counter_command;
        end
    endcase
end

/***********************************************************

    Send Data counter

***********************************************************/

always @* begin
    case (FSM_Main)
        senddata : begin
           if (state == SENT_COMMAND)counter_send_count_c <= counter_send_count - 4'd1;
           else counter_send_count_c <= counter_send_count;
        end
        default : begin
           counter_send_count_c <= counter_send - 'd1;
        end
    endcase
end

/***********************************************************

    address counter

***********************************************************/

always @* begin
    case (FSM_Main)
        sendaddress : begin
           if (state == SENT_COMMAND )counter_send_address_count_c <= counter_send_address_count - 4'd1;
           else counter_send_address_count_c <= counter_send_address_count;
        end

        default : begin
           counter_send_address_count_c <= 4'hf;
        end
    endcase
end

/***********************************************************

    receiving counter counter

***********************************************************/

always @* begin
    case (FSM_Main)
        receivedata : begin
           if (state == SENT_COMMAND )counter_receive_count_c <= counter_receive_count - 4'd1;
           else counter_receive_count_c <= counter_receive_count;
        end

        default : begin
           counter_receive_count_c <= counter_receive;
        end
    endcase
end

/***********************************************************

    Here is the interface counters

***********************************************************/

wire sync_data;
wire sync_data_not;

// this is the timer for each bit signal at 50mhz.

always@(posedge clk)
begin
	if(sync_data)
	begin
		controller_8bit_counter <= controller_8bit_counter - 1'b1;
	end
	else
	begin
		controller_8bit_counter<=controller_8bit_counter;
		if(!counter_en)
		begin
			controller_8bit_counter <= 3'd7;
		end
	end
end

// this is the input system that places what the data should be on the 8 bit bus 

always@(posedge clk)
begin
	counter_delay_pulses<=counter_delay_pulses;
	if(sync_data_not)
	begin
		contorller_input_8[controller_8bit_counter]<=(counter_delay_pulses[31:0]>=32'd100);
	end
	else if(sync_data)
	begin
		counter_delay_pulses<=0;
	end
	else
	begin
		if(counter_en)
		begin
			counter_delay_pulses<=counter_delay_pulses+1'b1;
		end
	end
end

// This is the counter for the output data. We will change this so each time the process starts
// it updates the counter polling to the higher number and then each 8 counts it gets updates the FIFO 
// we might make a reg that can be accessed by the main FSM

//wire idle_change = (state==IDLE_FSM);
wire [8:0] send_counter_state = address_send ? 9'd23 + counter_send : 9'd7;

always@(negedge data_out or posedge start)
begin
	if(start)
	begin
		counter_polling <= send_counter_state;
	end
	else
	begin
		if (counter_polling != 9'd0) counter_polling <= counter_polling - 'd1;
		else counter_polling <= counter_polling;
	end
end

wire [3:0] sending_data_location = counter_polling;


always@(posedge clk)
begin
	case(state[7:0])
	IDLE_FSM	:begin	 	
					counter_delay[31:0]<=0;
					state[7:0]<=IDLE_FSM;
					if(start)
					begin
						state[7:0]<=POLL_FSM;
					end
				 end
	POLL_FSM	:begin	 
					counter_delay[31:0]<=0;// otherwise go to get the data
					state[7:0]<=GET_FSM;
					if(controller_active)
					begin
						counter_delay[31:0]<=ONEuSECONDS;//send a 1 starting from 1 us
						state[7:0]<=SEND1_FSM1;
						if(sending_data[sending_data_location[2:0]]==1'b0)
						begin
							counter_delay[31:0]<=THREEuSECONDS;
							state[7:0]<=SEND0_FSM1;//send a 0  starting from 3 us
						end
					end
				 end
	SEND0_FSM1	:begin// send a 0  
					state[7:0]<=SEND0_FSM1;
					counter_delay[31:0]<=counter_delay[31:0]-1'b1;
					if(counter_delay[31:0]==32'd0)
					begin
						state[7:0]<=SEND0_FSM2;
						counter_delay[31:0]<=ONEuSECONDS;
					end
				 end
	SEND0_FSM2	:begin
					state[7:0]<=SEND0_FSM2;
					counter_delay[31:0]<=counter_delay[31:0]-1'b1;
					if(counter_delay[31:0]==32'd0)
					begin
						state[7:0]<=SENT_COMMAND;
					end
				 end
	SEND1_FSM1	:begin
					state[7:0]<=SEND1_FSM1;
					counter_delay[31:0]<=counter_delay[31:0]-1'b1;
					if(counter_delay[31:0]==32'd0)
					begin
						state[7:0]<=SEND1_FSM2;
						counter_delay[31:0]<=THREEuSECONDS;
					end
				 end
	SEND1_FSM2	:begin
					state[7:0]<=SEND1_FSM2;
					counter_delay[31:0]<=counter_delay[31:0]-1'b1;
					if(counter_delay[31:0]==32'd0)
					begin
						state[7:0]<=SENT_COMMAND;
					end
				 end
    SENT_COMMAND : begin
                    state[7:0]<=POLL_FSM;
					counter_delay[31:0]<='b0;
					
					
                end
	GET_FSM 	:begin	 
					state[7:0]<=GET_FSM;
					counter_delay[31:0]<=HUNDRED_MS;// DELAY AFTER POLLING AND GETTING DATA
				   if(counter_receive_count == 'b0)// wait untilt there are 33 pulses coming from the N64 controller
					begin
						state[7:0]<=FINISH_FSM;
					end
				 end
	FINISH_FSM 	:begin
					state[7:0]<=FINISH_FSM;
					counter_delay[31:0]<=counter_delay[31:0]-1'b1;
					if(counter_delay[31:0]==32'd0)
					begin
						state[7:0]<=IDLE_FSM;
					end
				 end
	default		:begin
					state[7:0]<=IDLE_FSM;
					counter_delay[31:0]<=32'd0;
				 end
	endcase 
end

async_trap_and_reset async_trap_and_reset_inst
(
	.async_sig(data_in) ,	// input  async_sig_sig
	.outclk(clk) ,	// input  outclk_sig
	.out_sync_sig(sync_data) ,	// output  out_sync_sig_sig
	.auto_reset(1'b1) ,	// input  auto_reset_sig
	.reset(1'b1) 	// input  reset_sig
);


async_trap_and_reset async_trap_and_reset_inst2
(
	.async_sig(~data_in) ,	// input  async_sig_sig
	.outclk(clk) ,	// input  outclk_sig
	.out_sync_sig(sync_data_not) ,	// output  out_sync_sig_sig
	.auto_reset(1'b1) ,	// input  auto_reset_sig
	.reset(1'b1) 	// input  reset_sig
);

n64_controller_fifo #(
    .width          (8),
    .widthu         (4)
)
n64_controller_fifo_read(
    .clk            (clk),
    .rst_n          (reset_l),
    // for the CPU
    .sclr           (empty_read_fifo),
    .rdreq          (fifo_buffer_read_read),   //input
    .empty          (empty_read_fifo_status),
    .q              (fifo_buffer_read_read_data),
    // for the controller
    .wrreq          (fifo_read_next),   //input
    .data           (fifo_read_data_next)    //input [66:0]
);

n64_controller_fifo #(
    .width          (8),
    .widthu         (4)
)
n64_controller_fifo_write(
    .clk            (clk),
    .rst_n          (reset_l),
     // for the CPU   
    .sclr           (empty_write_fifo),
    .wrreq          (fifo_buffer_write_write),
    .empty          (empty_write_fifo_status),
    .data           (fifo_buffer_write_write_data),
    // for the controller
    .rdreq          (fifo_write_next),   //input    
    .q              (fifo_buffer_write_controller)
);

endmodule


module async_trap_and_reset (async_sig, outclk, out_sync_sig, auto_reset, reset);
/* this module traps an asyncronous signal async_sig and syncronizes it via 2 flip-flops to outclk. The resulting
   signal is named out_sync_sig. auto_reset tells the module whether to do an auto-reset of out_sync_sig after 2 clocks.
   reset is an asynchronous reset signal. The reset signal is active LOW. */


input async_sig, outclk, auto_reset, reset;
output out_sync_sig;

reg async_trap, sync1, sync2;

reg actual_auto_reset_signal;


wire actual_async_sig_reset;

wire auto_reset_signal =  auto_reset && sync2;

assign actual_async_sig_reset = actual_auto_reset_signal || (!reset);


assign out_sync_sig = sync2;

always @ (posedge async_sig or posedge actual_async_sig_reset)
begin
	 if (actual_async_sig_reset)
	 	async_trap <= 1'b0;
	 else
	 	async_trap <= 1'b1;
end

always @ (posedge outclk or negedge reset)
begin
	 if (~reset)
	 begin
	 	  sync1 <= 1'b0;
		  sync2 <= 1'b0;
	 end else
	 begin
	 	  sync1 <= async_trap;
		  sync2 <= async_trap;
	 end
end

always @ (negedge outclk or negedge reset)
begin
	if (~reset)
		 actual_auto_reset_signal <= 1'b0;
	else
		 actual_auto_reset_signal <= auto_reset_signal;
end



endmodule

module n64_controller_fifo(
    input                       clk,
    input                       rst_n,
    input                       sclr,
    
    input                       rdreq,
    input                       wrreq,
    input       [width-1:0]     data,
    
    output                      empty,
    output reg                  full,
    output      [width-1:0]     q,
    output reg  [widthu-1:0]    usedw
);

parameter width     = 2;
parameter widthu    = 2;

reg [width-1:0] mem [(2**widthu)-1:0];

reg [widthu-1:0] rd_index = 0;
reg [widthu-1:0] wr_index = 0;

assign q    = mem[rd_index];
assign empty= usedw == 0 && ~(full);

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)           rd_index <= 0;
    else if(sclr)               rd_index <= 0;
    else if(rdreq && ~(empty))  rd_index <= rd_index + { {widthu-1{1'b0}}, 1'b1 };
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       wr_index <= 0;
    else if(sclr)                           wr_index <= 0;
    else if(wrreq && (~(full) || rdreq))    wr_index <= wr_index + { {widthu-1{1'b0}}, 1'b1 };
end

always @(posedge clk) begin
    if(wrreq && (~(full) || rdreq)) mem[wr_index] <= data;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                                               full <= 1'b0;
    else if(sclr)                                                   full <= 1'b0;
    else if(rdreq && ~(wrreq) && full)                              full <= 1'b0;
    else if(~(rdreq) && wrreq && ~(full) && usedw == (2**widthu)-1) full <= 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0)                       usedw <= 0;
    else if(sclr)                           usedw <= 0;
    else if(rdreq && ~(wrreq) && ~(empty))  usedw <= usedw - { {widthu-1{1'b0}}, 1'b1 };
    else if(~(rdreq) && wrreq && ~(full))   usedw <= usedw + { {widthu-1{1'b0}}, 1'b1 };
    else if(rdreq && wrreq && empty)        usedw <= { {widthu-1{1'b0}}, 1'b1 };
end

endmodule
