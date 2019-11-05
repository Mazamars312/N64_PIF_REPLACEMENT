# N64_PIF_REPLACEMENT
 #################### This is work in progress #####################

	This is the start of the pif mips controller rom on the instruction side

	This CPU will have a 32 Bit instruction rom and only a 8 bit data pathway
	
	We have the following 30 commands (2 are Null commands as we will have 
	
	one bit on the instruction ops to say if the op is a reg to reg operand 
	
	or immediate calculation.
	
	We also have no interupts on this and everything needs checked in code.
	
	We have 8 regisutres and what we usally use them for in this system
	
	S0	Always Zero for ALU instuctions
	S1	Mostly used for channel testing
	S2 	PIF send commands
	S3	PIF to receive commands
	S4	The command to be sent on that channel
	S5	Used for testing branchs
	S6	Load and store data
	S7	Ram pointer
	
	S0 also has a special function for BEQ, BNQ and BFZ commands where it can be writen for to help on the branching offset. 
		This reg is store only in the branching unit and is only used for the these commands. So this will not affect the S0 reg for ALU calulations
		If the instruction [4] bit is 1 then the branch address will look like this (Special S0 reg , offset[3:0])
		Else if the instruction [4] bit is 0. you can make a small jump. please not that this is still a signed offset.This will only do 8 offsets up and down
	

	OPS:
	
	reg to reg ops
	op	A	B 	WB
	
	ADD			Areg 		Breg 	WBreg
	SUB			Areg 		Breg 	WBreg
	AND			Areg 		Breg 	WBreg
	OR			Areg 		Breg 	WBreg
	XOR			Areg 		Breg 	WBreg
	MUL			Areg		Breg	WBreg
	MOV			Areg 		0 	  	WBreg
	BEQ			Areg 		Breg 	if [4] = 1 then branch address = (Special S0 reg , offset[3:0]) else (8x offset[3], offset [3:0]) So branches are signed
	BNQ			Areg 		Breg 	if [4] = 1 then branch address = (Special S0 reg , offset[3:0]) else (8x offset[3], offset [3:0]) So branches are signed
	JAR			Areg		Breg	0		The Areg will be the high address and the B reg will be the low address for the jump
	

	reg to immediate ops
	
	These call the Areg and then the ALU uses the immi value with it. This is then writen back to the Areg
	
	op[	A	Imm
	
	ADDI		Areg 		immidiate value [7:0]
	SUBI		Areg 		immidiate value [7:0]
	ANDI		Areg 		immidiate value [7:0]
	ORI			Areg 		immidiate value [7:0]
	XORI		Areg 		immidiate value [7:0]
	MUL			Areg		immidiate value [3:0]
	SLLI		Areg 		Shift[3:0]
	SRAI		Areg		Shift[3:0]
	SRUI		Areg		Shift[3:0]
	BFZ			Areg		if [4] = 1 then branch address = (Special S0 reg , offset[3:0]) else (8x offset[3], offset [3:0]) So branches are signed
	J			Jump to address[10:0]
	LB			Areg 		RAM address [7:0]
	SB			Areg 		RAM address [7:0]
	LI			Areg 		immidiate value [7:0]
	
	Memory map
	
	0x00 - 0x3F		PIF Ram
	0x40 - 0x7F		Scrach Ram
	0x80 - 0x9F		6505 Tables for CIC decoding
	0xA0 - 0xAF		Controller interface: A0 = 8 bit FIFO Write to controller, A1 8bit FIFO Read from Controller 
	0xB0 - 0xBF		EPPROM Interface
	0xC0 - 0xCF		N64 interface
	0xD0 - 0xFF		Un-reserved - Will look at a RTC interface. Or have some CPU control regs like a page changer
	
	
	
	Controller interface
	
		address 
        0xA0 - cmd
        0xA1 - high address
        0xA2 - Low address/xor CRC[4:0]
        0xA3 - Controller access and ready/waiting status 
        0xA4 - Controller controll signals
        0xA5 - Read fifo (8-bits)
        0xA6 - Write fifo (8-bits)
		
		Commands
        0x00 - Status of controller
        0x01 - Read controller buttons
        0x02 - Read Ram
        0x03 - Write ram
        0xff - reset controller
				
	Epprom - Will change later
	
		B0 - 8 bit FIFO Write to controller  (upto 33 commands can be written)
		B1 - 8 bit FIFO Read from Controller (upto 36 commands can be read)
		B2 - How many Writes are to happen over the interface
		B3 - How many Reads are to happen over the interface
		B4 - Status - bit 7 = Waiting , bit 6 = Ready , bit 5 = FIFO Write Full, bit 4 = FIFO Read Full, bit 0 - Epprom is being accessed
		B5 - Command - bit 7 = 0 , bit 6 = 0 , bit 5 = FIFO write empty, bit 4 = FIFO read empty, bit 0 - Epprom to process
	
	N64 Interations
	
		C0 - If a 0xFF is writen here the NMI on the N64 will become active, if 0x00 then NMI is deactive
		C1 - This is a read reg only for the reset button 0x00 is off, and 0xFF is on. so the main loop needs to check this all the time to reboot the N64
		C2 - if 0xFF is writen then the PIF Rom is disabled from begin read by the n64
		C3 - PIF Ram Offset - This is for future looking at where we can have this offset the PIF to allow larger rom's at start up. 8 bit banking
		
		
There is also a controller module that is part of this

	N64_Controller_hand.v - a verilog impermination of the N64 controller that will be able to have a memory pak and rumble pak intergrated. This is only digital at the moment for the 
							x and y axis.
							
							
	N64_controller_sv.sv - is a test controller that Ive tried to use in simulation. Not fully working at this moment.
