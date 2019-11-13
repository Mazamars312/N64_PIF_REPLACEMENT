# N64_PIF_REPLACEMENT
 #################### This is work in progress #####################

 Change of plans, We are going to have a 6502 in a N64!!!

 I started working on a the CPU and through well we are using 8 bits only, what CPU is a great way to bring into this system.

 The NES, C64 and many other computers out there. It was a part thought on the Z80 CPU, but with so many having refences of N64 in their name I could not resist.

 This CPU will replace the assumed 4bit cpu in the PIF controller. The CPU will run at 50mhz to keep the timing of the controller interface module in sync with it. The pif I believe was at 15.6mhz due to the interface between the RCP and the PIF (I could be wrong here). There could be a 1.7mhzish as that is what the CRC/eeprom is.

 With this core we will not have the CIC interface. But we will work on a new PIF Bios for the N64 that would check the first 1000 lines of cart rom and then tell the PIF core that we are one to use one of the many CIC chips. This will include the x105 CIC process as well.  

 The PIF processes will be as follows
  * Check the PIF ram's last byte to communicate with the N64.
  * If there is a change to the last byte. check what processes will be ran. (need to check these)
    0x80 = normal channel Loop
    0x20 = CRC check - for 6/7105 CRC checks
    0xC0 = clear PIF ram
    0x10 = disable PIF Rom
    0x30 = normal channel Loop
    0x50 = Change the CIC type ( More to come from this ;-) )
  * Check how many channels are to process
    1. Send command to reg
    2. Send address if needed
    3. Move data to write FIFO from the pif ram
    4. Select Joy interface to process
    5. wait until processing flag is down and ready is high
    6. pull data from read fifo to the pif ram
  * Setup Controller/eeprom module and then start process / this would include the ram to transfer to the eeprom/mempack
  * Move data from Controller/eeprom module to pif ram
  * Have some space for a rtc interface (this is a wish list for those with a everdrive 2.5 and below)
  * Process the CIC 6/7105 response if a CRC check is asked for
  * Clear ram loop
  * Control the reboot stage of the N64 with the NMI
  * Change the PIF Rom Offset for larger Bios roms
  * look out for the sequence 0xDEADDEAD in pif ram to reboot N64 via software.

	Memory map

  0x0000 - 0x0FFF  RAM for stacking and other accesses. 4k of ram.

  0x1000 - 0x17FF  the Full N64 PIF Rom/ram in ram form. This data will need to be transferred by the 6502 from the orginal Rom.
                   Now we have a fully changeable PIF rom on the fly. ;-)
  0x1800 - 0x1FFF  Mirror of Full N64 ROM and RAM.
  0x2000 - 0x27FF  The original PIF rom that needs to be copied to the PIF ram - this will be a read only rom for backups.
  0x2800 - 0x2FFF  Mirror original PIF rom.

  0x3200 - 0x327F  Reserved for Future stuff
	0x3280 - 0x329F  CIC Rom - 6505 Tables for CIC decoding
	0x32A0 - 0x32AF  Controller interface: A0 = 8 bit FIFO Write to controller, A1 8bit FIFO Read from Controller
	0x32B0 - 0x32BF  EPPROM Interface
	0x32C0 - 0x32CF  N64 interface
  0x32D0 - 0x32FF  Reserved for Future stuff

	0x8000 - 0xFFFF  Instruction Rom area


	Controller interface

		address
        0xA0 - cmd
        0xA1 - high address
        0xA2 - Low address/xor CRC[4:0]
        0xA3 - Controller access and ready/waiting status
        0xA4 - Controller control signals
        0xA5 - Read fifo (8-bits)
        0xA6 - Write fifo (8-bits)

		Commands for Controller interface.
        0x00 - Status of controller
        0x01 - Read controller buttons
        0x02 - Read Ram
        0x03 - Write ram
        0xff - reset controller

	Epprom - Will change later

		B0 - 8 bit FIFO Write to controller  (up to 33 commands can be written)
		B1 - 8 bit FIFO Read from Controller (up to 33 commands can be read)
		B2 - How many Writes are to happen over the interface
		B3 - How many Reads are to happen over the interface
		B4 - Status - bit 7 = Waiting , bit 6 = Ready , bit 5 = FIFO Write Full, bit 4 = FIFO Read Full, bit 0 - Epprom is being accessed
		B5 - Command - bit 7 = 0 , bit 6 = 0 , bit 5 = FIFO write empty, bit 4 = FIFO read empty, bit 0 - Epprom to process

	N64 Interactions

		C0 - If a 0xFF is written here the NMI on the N64 will become active, if 0x00 then NMI is deactivate
    C1 - If a 0xFF is written here the INT2 on the N64 will become active, if 0x00 then INT2 is deactivate
		C2 - if 0xFF is written then the PIF Rom is disabled from begin read by the n64
		C3 - PIF Ram Offset - This is for future looking at where we can have this offset the PIF to allow larger rom's at start up. 8 bit banking
    C4 - PAL SWITCH - When High the 6502 will setup the system as a PAL system
    C5 - RESET SWITCH - When High the CPU will say the RESET button is high. I was going to make it a interupt, but then we could not do a nice debounce loop.
    C6 - PIF_PROCESSING - This allows the 6502 see if the interface is being worked on by the N64. This is mostly used for the CRC testing.
    C7 - PIF_ADDRESS_ACCESS - This allows the 6502 see which address is being access by the N64.
    C8 - Allows the 6502 see what type of transfer is being done. 4 bytes or 64 bytes/dma.
    C9 - Reserved
    CA - This allows the 6502 to hold up the read from the N64 by blocking the read access ack. This is helpful to keep the N64 DMA wait for the 6502 to process the current ram at the moment.


There is also a controller module that will emulate the full N64 controller. Yep a full verilog controller that I want to test to make replacement controllers. We will also look at making an ADC interface for this so we can running control sticks

	N64_Controller_hand.v - a Verilog impermination of the N64 controller that will be able to have a memory pak and rumble pak integration. This is only digital at the moment for the
							x and y axis.


What needs to be done:

* 6502 ASM code to run
  tasks to be done:
      * Start up process
        1. Move pif_rom to pif_ram - DONE
        2. make NMI high once transfer is done.
        3. make the int2 signal LOW I believe that is the case
        4. make PIF_RAM {0x3ff} address byte to 0x00;

      * Have a main loop for the Check of the Reset button every half second
        1. check the int
* build up the mempak funchtion in the controller module so we can have a internal mempak on the core.
* once the mempak in the controller is done, we need to do the testing of the CRC module for the controller works.
* EEPROM FIFO in and outs need to be started and then interfaced with the EEPROM master code I have.
