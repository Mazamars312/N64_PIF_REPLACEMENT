`timescale 1ns / 1ps


// Real Controller core for the N64 By Murray Aickin
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


    Commands
        0x00 - Status of controller
        0x01 - Read controller buttons
        0x02 - Read Ram
        0x03 - Write ram
        0xff - reset controller

**************************************************************/


module N64_controller
(
    input clock, reset_l,
	input A, B, R, L, Z, START,
	input yellow_UP, yellow_DOWN, yellow_LEFT, yellow_RIGHT,
	input gray_UP, gray_DOWN, gray_LEFT, gray_RIGHT,
	input [7:0] joystick_X, joystick_Y,
	inout out
);
wire buttons = 32'h0000_0000;

reg [2:0] controller_fsm, controller_fsm_c;

reg [7:0] input_buffer;

reg [7:0] cmd_received;

reg get_processing, get_processing_c;

reg [7:0] command_in, command_in_c;

reg [31:0] cart_mem [2047:0];

localparam cmd_input    =   3'd0;
localparam stopbitr     =   3'd1;
localparam cmd_addressl =   3'd2;
localparam cmd_addressh =   3'd3;
localparam data_send    =   3'd4;
localparam data_receive =   3'd5;
localparam stopbits     =   3'd6;


always @(posedge clock or negedge reset_l) begin
    if (~reset_l) begin
        controller_fsm <= 'b0;
        get_processing <= 'b0;
        command_in <= 'b0;
    end
    else begin
        controller_fsm <= controller_fsm_c;
        get_processing <= get_processing_c;
        command_in <=  command_in_c;
    end
end

/******************************************************************

    THe FSM Status For the internal side.

******************************************************************/


always @* begin
    case (controller_fsm)
        stopbitr : begin
            controller_fsm_c <= cmd_input;
        end
        cmd_addressl : begin
            if (counter == 7 && sync_data) begin
                case (cmd_received)
                    8'h02   : controller_fsm_c <= data_receive;
                    default : controller_fsm_c <= data_send;
                endcase
            end
            else controller_fsm_c <= cmd_addressh;
        end
        cmd_addressh : begin
            if (counter == 7 && sync_data) controller_fsm_c <= cmd_addressl;
            else controller_fsm_c <= cmd_addressh;
        end
        data_send : begin
            controller_fsm_c <= stopbits;
        end
        data_receive : begin
            controller_fsm_c <= stopbitr;
        end
        stopbits : begin
            controller_fsm_c <= cmd_input;
        end
        default : begin
            if (counter == 7 && sync_data) begin
             case (input_buffer)
                8'h00 : begin
                    controller_fsm_c <= data_send;
                end
                8'h02 ,
                8'h03 : begin
                    controller_fsm_c <= cmd_addressh;
                end
                8'hff : begin
                    controller_fsm_c <= data_send;
                end
                default : begin
                    controller_fsm_c <= data_send;
                end
             endcase
            end
            else begin
                controller_fsm_c <= cmd_input;
            end
        end
    endcase
end

/******************************************************************

    THe FSM Status For the internal side.

******************************************************************/


always @* begin
    case (controller_fsm)
        cmd_input : begin
            command_in_c <= input_buffer;
        end
        default : begin
            command_in_c <= command_in;
        end
    endcase
end

/******************************************************************

    THe FSM Controll reg For the internal side.

******************************************************************/


always @* begin
    case (controller_fsm)
        stopbitr ,
        data_send,
        stopbits : begin
            get_processing_c <= 1'b1;
        end
        default : begin
            get_processing_c <= 1'b0;
        end
    endcase
end
						//counter_en___finish_______oe__get__state
localparam IDLE_FSM		 =	8'b0___________0________0___0_0000;
localparam POLL_FSM		 =	8'b0___________0________1___0_0000;
localparam SEND0_FSM1	 =	8'b0___________0________1___0_0010;
localparam SEND0_FSM2	 =	8'b0___________0________1___0_0011;
localparam SEND1_FSM1	 =	8'b0___________0________1___0_0100;
localparam SEND1_FSM2	 =	8'b0___________0________1___0_0101;
localparam GET_FSM 		 =	8'b1___________0________0___0_0110;
localparam FINISH_FSM 	 =	8'b0___________1________0___0_1110;

localparam THREEuSECONDS = 32'd150;
localparam ONEuSECONDS = 32'd50;
localparam HUNDRED_MS = 32'd400000;


reg [7:0]state=GET_FSM;
reg [31:0]counter_delay =32'd0;
reg [31:0]counter_delay_pulses =32'd0;
reg [3:0]counter_polling =4'd0;
reg [5:0]counting_data =6'd0;
wire [8:0]polling_data=9'b110000000;
reg [33:0]buffer_buttons=34'd0;
reg [2:0]counter=3'd0;
wire counter_en=state[7];
wire oe=state[5];
wire finish=state[6];
wire counting_data_clk=state[4];
wire data_out=state[0];
reg data_in=1'b0;
reg real_in=1'b0;
reg start_counter=1'b0;




assign out = oe ? data_out: 1'bz;

always@(posedge clock)
begin
	data_in<=out;
end

wire sync_data;
wire sync_data_not;


async_trap_and_reset async_trap_and_reset_inst
(
	.async_sig(data_in) ,	// input  async_sig_sig
	.outclk(clock) ,	// input  outclk_sig
	.out_sync_sig(sync_data) ,	// output  out_sync_sig_sig
	.auto_reset(1'b1) ,	// input  auto_reset_sig
	.reset(reset_l) 	// input  reset_sig
);


async_trap_and_reset async_trap_and_reset_inst2
(
	.async_sig(~data_in) ,	// input  async_sig_sig
	.outclk(clock) ,	// input  outclk_sig
	.out_sync_sig(sync_data_not) ,	// output  out_sync_sig_sig
	.auto_reset(1'b1) ,	// input  auto_reset_sig
	.reset(reset_l) 	// input  reset_sig
);





always@(posedge clock)
begin
	if(sync_data)
	begin
		counter<=counter-1'b1;
	end
	else
	begin
		counter<=counter;
		if(!counter_en)
		begin
			counter<=3'd7;
		end
	end
end



always@(posedge clock)
begin
	counter_delay_pulses<=counter_delay_pulses;
	if(sync_data_not)
	begin
		input_buffer[counter]<=(counter_delay_pulses[31:0]>=32'd100);
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



//always@(posedge data_out, posedge finish)
//begin
//	if(finish)
//	begin
//		counter_polling[3:0]<=4'd0;
//	end
//	else
//	begin
//		counter_polling[3:0]<=counter_polling[3:0]+1'b1;
//	end
//end




always@(posedge clock)
begin
	case(state[7:0])
	IDLE_FSM	:begin
					counter_delay[31:0]<=0;
					state[7:0]<=IDLE_FSM;
					if(~data_in)
					begin
						state[7:0]<=GET_FSM;
					end
				 end
    GET_FSM 	:begin
					state[7:0]<=GET_FSM;
					counter_delay[31:0]<=HUNDRED_MS;// DELAY AFTER POLLING AND GETTING DATA
				   if(get_processing && sync_data)// wait untilt there are 33 pulses coming from the N64 controller
					begin
						state[7:0]<=FINISH_FSM;
					end
				 end
	POLL_FSM	:begin
					counter_delay[31:0]<=0;// otherwise go to get the data
					state[7:0]<=FINISH_FSM;
					if(counter_polling[3:0]<=4'd8)
					begin
						counter_delay[31:0]<=ONEuSECONDS;//send a 1 starting from 1 us
						state[7:0]<=SEND1_FSM1;
						if(polling_data[counter_polling[3:0]]==1'b0)
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
						state[7:0]<=POLL_FSM;
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
						state[7:0]<=POLL_FSM;
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
