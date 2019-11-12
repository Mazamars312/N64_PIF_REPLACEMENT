	*= $F000

CRCrom_LUT0	  = $3280
CRCrom_LUT1	  = $3290

Controller_CMD    = $32A0
Controller_LOA    = $32A1
Controller_HIA    = $32A2
Controller_WRT    = $32A3
Controller_RED    = $32A4
Controller_STA    = $32A5
Controller_CON    = $32A6

EPROM_CMD         = $32B0
EPROM_LOA         = $32B1
EPROM_HIA         = $32B2
EPROM_WRT         = $32B3
EPROM_RED         = $32B4
EPROM_STA         = $32B5
EPROM_CON         = $32B6

N64_NMI           = $32C0
N64_INT2          = $32C1
N64_PIFDISABLED   = $32C2
N64_PIF_PAGE      = $32C3
N64_PAL           = $32C4
N64_RESET_BUTTON  = $32C5
N64_PIF_PROCESSING= $32C6
N64_PIF_ADDRESS   = $32C7
N64_PIF_READWRITE = $32C8

PIF_ROM           = $2000

PIF_RAM           = $1000

N64_RAM           = $17C0
N64_SGM           = $17FF


; Set zeropage locations

;00-0F is temp numbers for checking things

; the below is for Channel processing
; zeropage 10 channel 1 cmd
; zeropage 11 channel 1 send data
; zeropage 12 channel 1 receive data
; zeropage 20 channel 2 cmd
; zeropage 21 channel 2 send data
; zeropage 22 channel 2 receive data
; zeropage 30 channel 3 cmd
; zeropage 31 channel 3 send data
; zeropage 32 channel 3 receive data
; zeropage 40 channel 4 cmd
; zeropage 41 channel 4 send data
; zeropage 42 channel 4 receive data
; zeropage 50 channel 5 cmd
; zeropage 51 channel 5 send data
; zeropage 52 channel 5 receive data

; zeropage C0 is the key
; zeropage C1 is the lut 0 or 1
; zeropage C2 is the sgn
; zeropage C3 is the mag
; zeropage C4 is the mod
; zeropage C5 is the responce
; zeropage C6 is the challenge
; zeropage c7/c8 the address to be read from the CRC Rom
; zeropage c9 is the offset base address of the CRC Rom

;d0 is the 31:24 bits of the CRC being used
;d1 is the 23:16 bits of the CRC being used
;d2 is the 15:8  bits of the CRC being used
;d3 is the 7:0   bits of the CRC being used

;f0-ff is mamory transfers

;	jmp PIF_ROM2RAM

controller_testing:
	LDA #$FF
	STA $17C0
	LDA #$01
	STA $17C1
	LDA #$04
	STA $17C2
	LDA #$01
	STA $17C3
	LDA #$FF
	STA $17C8
	LDA #$01
	STA $17C9
	LDA #$04
	STA $17CA
	LDA #$01
	STA $17CB
	LDA #$FE
	STA $17D0
	LDA #$01
	sta $17ff
	
	LDA #$00
	STA Controller_CMD
	LDA #$00
	STA Controller_LOA
	LDA #$00
	STA Controller_HIA
	LDA #$80
	STA Controller_WRT
	LDA #$45
	STA Controller_RED
	LDA #$80
	STA Controller_STA
	LDA #$00
	STA Controller_CON
	jsr pif_process_init	
	jmp controller_testing
	


crc_testing:
	LDA #$04
	STA $3280
	LDA #$07
	STA $3281
	LDA #$0A
	STA $3282
	LDA #$07
	STA $3283
	LDA #$0E
	STA $3284
	LDA #$05
	STA $3285
	LDA #$0E
	STA $3286
	LDA #$01
	STA $3287
	LDA #$0C
	STA $3288
	LDA #$0F
	STA $3289
	LDA #$08
	STA $328A
	LDA #$0F
	STA $328B
	LDA #$06
	STA $328C
	LDA #$03
	STA $328D
	LDA #$06
	STA $328E
	LDA #$09
	STA $328F
	
	LDA #$04
	STA $3290
	LDA #$01
	STA $3291
	LDA #$0A
	STA $3292
	LDA #$07
	STA $3293
	LDA #$0E
	STA $3294
	LDA #$05
	STA $3295
	LDA #$0E
	STA $3296
	LDA #$01
	STA $3297
	LDA #$0C
	STA $3298
	LDA #$09
	STA $3299
	LDA #$08
	STA $329A
	LDA #$05
	STA $329B
	LDA #$06
	STA $329C
	LDA #$03
	STA $329D
	LDA #$0C
	STA $329E
	LDA #$09
	STA $329F
	;8FBB1DB876B63CEC
	
	LDA #$8f
	STA $17f0
	LDA #$bb
	STA $17F1
	LDA #$1d
	STA $17F2
	LDA #$b8
	STA $17F3
	LDA #$9A
	STA $17F4
	LDA #$76
	STA $17F5
	LDA #$b6
	STA $17F6
	LDA #$3c
	sta $17F7
	LDA #$02
	STA $17F8
	LDA #$5b
	STA $17F9
	LDA #$ea
	STA $17FA
	LDA #$ed
	STA $17FB
	LDA #$ec
	STA $17FC
	LDA #$80
	STA $17FD
	LDA #$3a
	STA $17FE
	LDA #$6b
	STA $17FF
	jsr crcinit6105	
	jmp crc_testing

; this is the starting code for the orginal start up ready to go
;  jsr INT_DOWN
;  jsr NMI_DOWN
;  jsr CLEARPIFROM
;  jsr PIF_ROM2RAM
;  JSR NMI_UP
;  lda #$80
;  sta N64_SGM
;  JSR CRC_INIT_BOOTUP
  
;  lda #$80
;  sta N64_SGM


MAINLOOP:
	jsr CHECKSEG
	jsr CHECK_RESET_BUTTON
	jmp MAINLOOP

PIF_ROM2RAM:
	lda #$00 ;set our source memory address to copy from, $2000
	sta $FB
	lda #$20
	sta $FC
	lda #$00 ;set our destination memory to copy to, $1000, WRAM
	sta $FD
	lda #$10
	sta $FE
	ldy #$00 ;reset x and y for our loop
	ldx #$00

PIF_ROM2RAMLOOP:
	lda ($FB),Y ;indirect index source memory address, starting at $00
	sta ($FD),Y ;indirect index dest memory address, starting at $00
	iny  ;increment low order source memory address byte by 1
	cpy #$00
	bne PIF_ROM2RAMLOOP ;loop until our dest goes over 255
	inc $FC ;increment high order source memory address, starting at $80
	inc $FE ;increment high order dest memory address, starting at $60
	lda $FE ;load high order mem address into a
	cmp #$18 ;compare with the last address we want to write
	bne PIF_ROM2RAMLOOP ;if we're not there yet, loop
	rts

NMI_UP:
	lda #$ff
	sta N64_NMI
	rts

NMI_DOWN:
	ldx #$00
NMI_DOWN_LOOP:
	lda #$00
	sta N64_NMI
	inx
	cpx #$ff
	bne NMI_DOWN_LOOP
	rts

INT_UP:
	lda #$ff
	sta N64_INT2
	lda #$00
	sta N64_SGM
	jmp pif_process_init

INT_DOWN:
	ldx #$00
INT_DOWN_LOOP:
	lda #$00
	sta N64_INT2
	inx
	cpx #$20
	bne INT_DOWN_LOOP
	rts


CLEARPIFROM:
	lda #$00 ;set our destination memory to copy to, $1000, WRAM
	sta $FD
	lda #$10
	sta $FE
	LDY #$00 ;reset x and y for our loop
	lda #$00
	ldx #$00
	jmp CLEARPIFRAMLOOP

CLEARPIFRAM:
	lda #$00 ;set our destination memory to copy to, $1000, WRAM
	sta $FD
	lda #$17
	STA $FE
	ldy #$C0
	LDA #$00
	ldx #$00	
CLEARPIFRAMLOOP:
	sta ($FD),Y ;indirect index dest memory address, starting at $00
	INy 
	cpy #$00
	bne CLEARPIFRAMLOOP ;loop until our dest goes over 255
	inc $FE ;increment high order dest memory address, starting at $60
	ldx $FE ;load high order mem address into a
	cpx #$18;compare with the last address we want to write
	bne CLEARPIFRAMLOOP ;if we're not there yet, loop
	rts


CHECKSEG:
	ldx N64_SGM
	cpx #$00
	BNE test_crc_challange_system
	rts ; we have to make sure that if it is 00 then we can move it on
  
test_crc_challange_system:
	LDA #$80
	sta N64_SGM
	cpx #$02
	BNE test_crc_change
	jsr crcinit6105
  
test_crc_change: 
	cpx #$40
	Bne test_DMA_int
	JSR CRC_CHANGE  ; This is for changing the CRC. write the CRC in offset 0x24 of 0x17c0 to place this in the ram Temp files
	
test_DMA_int: 
	cpx #$08
	bne test_clear_rom
	JSR INT_UP ; this will do a interupt after processing the code
	
test_clear_rom:
	CPX #$10
	Bne test_clear_ram
	JSR CLEARPIFROM
	
test_clear_ram:  
	cpx #$C0
	BNE test_crc_update
	JSR CLEARPIFRAM
	
test_crc_update:  
	cpx #$30
	Bne test_pif_process 
	JSR CRC_UPDATE  ; This is for a reboot of the CRC in the system
	
test_pif_process:  
	cpx #$01
	BNE clear_process
	JSR pif_process_init
	
clear_process:  
	txa        ; this is the ready signal for the PIF
	sta N64_SGM
	rts

; This is the 6502 impermintation of the N64 CRC 6/7105 challange and responce process
; It is based on the code by X-scale but converted to ASM.
; It has not been tested yet at this moment but it does have most of teh code down ready to be tested.

; zeropage C0 is the key
; zeropage C1 is the lut 0 or 1
; zeropage C2 is the sgn
; zeropage C3 is the mag
; zeropage C4 is the mod
; zeropage C5 is the responce
; zeropage C6 is the challenge
; zeropage C7/C8 the address to be read from the CRC Rom
; zeropage C9 is the offset base address of the CRC Rom


crcinit6105
	lda #$0B
	sta $c0
	lda #$00
	sta $c1
	sta $c2
	sta $c3
	sta $c4
	sta $c5
	sta $c6
	sta $c7
	sta $c8
	sta $c9
	ldx #$00 ; clear the x Reg will be used for the respoce
	ldy #$00 ; here is the key we start with
	lda #$00  ; Here is the start of the CRC seek for the challange


crc_main_loop
	lda $17F0,Y ; we get the hig nibbles to  process
	lsr  ; we shift 4 for the top nibble
	lsr 
	lsr 
	lsr 
	AND #$0F ; and just to make sure that the nibble is only 4Bits
	sty $C9
	jsr crc_process_nibble
	stx $CA
	LDX #$00
	ldy $C9
	lda $17F0,y
	and #$0F
	jsr crc_process_nibble
	STX $CB ; Store the first nibble at zeropage F0
	lda $CA
	asl 
	asl 
	asl 
	asl 
	ora $CB
	ldy $C9
	STA $17F0,y
	iny
	cpy #$0F
	bne crc_main_loop
	lda #$00
	sta $17FF
	rts

; zeropage C0 is the key
; zeropage C1 is the lut 0 or 1
; zeropage C2 is the sgn
; zeropage C3 is the mag
; zeropage C4 is the mod
; zeropage C5 is the responce
; zeropage C6 is the challenge
; zeropage c7/c8 the address to be read from the CRC Rom
; zeropage FA/FB is the base address of the CRC Rom

crc_process_nibble ; from here we will use the C0 zeropage locations
	sta $C6
	lda $C0
	adc #$04
	sta $C5
	ldx #$00
responce_multi_5 ; responce = (key +5) * Challange
	INX
	CPX $C6
	bcs responce_zero
	ADC $C5
	jmp responce_multi_5
responce_zero
	and #$07 ; responce & 0x07
	sta $C5
	; key = lut [responce]
	ldx $C1
	cpx #$01
	beq lut1_key
lut0_key
	ldx $C5
	LDA $3280,x
	sta $C0
	jmp sgn_key
lut1_key
	ldx $C5
	LDA $3290,x
	sta $C0
sgn_key:
	lda $C5
	lsr 
	lsr 
	lsr 
	and #$01
	sta $C2
	;mag check
	cmp #$01
	bne mag_false
mag_true:
	lda #$ff
	eor $c5
	sta $c3
	jmp mod_test
mag_false:
	lda #$07
	and $c5
	sta $c3

mod_test:
	lda $C3
	sta $00
	lda $03
	sta $01
	lda $00
	sec
modulus:
	cmp #$00
	beq mobulus_zero
	SBC $00
	bcs modulus
	adc $01
mobulus_zero
	TAX
	cpx #$1
	bne sign_neg_1
	lda $C2
	sta $C4
	jmp lut1_level1_test

sign_neg_1:
	lda #$01
	sbc $c2
	sta $C4

lut1_level1_test:
	ldx #$01
	cpx $C5
	beq lut1_level1_lut1_mod_true
	ldx #$09
	cpx $C5
	beq lut1_level1_lut1_mod_true
	jmp lut1_level2_test

lut1_level1_lut1_mod_true:
	ldx #$01
	cpx $C1
	bne lut_check
	lda #$01
	sta $C4

lut1_level2_test:
	ldx #$0B
	cpx $C5
	beq lut1_level2_lut1_mod_true
	ldx #$0E
	cpx $C5
	beq lut1_level2_lut1_mod_true
	jmp lut_check

lut1_level2_lut1_mod_true:
	ldx #$01
	cpx $C1
	bne lut_check
	lda #$00
	sta $C4

lut_check:
	ldx $c4
	cpx #$01
	bne LUT_NOT_TRUE
	lda #$00
	sta $C1
	rts
LUT_NOT_TRUE:
	lda #$01
	STA $C1
	ldx $C5
	rts

;d0 is the 31:24 bits of the CRC
;d1 is the 23:16 bits of the CRC
;d2 is the 15:8  bits of the CRC
;d3 is the 7:0   bits of the CRC

CRC_CHANGE:
	ldx #$24
	ldy #$00
CRC_CHANGE_LOOP:
	lda $17c0,x
	sta $d0,y
	inx
	iny
	cpx #$29
	BNE CRC_CHANGE_LOOP
	lda #$00
	sta $17FF
	rts


; the Check reset will do debouncing on the Reset button and will keep a counter in a resetted state until the Reset button is up Longer
; than the counter stays active.
; 00 is the First counter for debouncing
; 01 is the second of the counter for debouncing
; 02 is the thrid counter for debouncing
; 03 is the forth counter for debouncing
; X reg is for the inter counter

CHECK_RESET_BUTTON:
	lda #$FF
	cmp N64_RESET_BUTTON
	Beq RESET_BUTTON_INIT
	rts
RESET_BUTTON_INIT:
	lda #$00
	ldx #$00
	sta $00
	sta $01
	sta $02
	sta $03
debounce_init:
	lda #$00
	sta N64_NMI
	lda #$00
	sta $00
	sta $01
	sta $02
	sta $03
inc_x_counter:
	lda #$FF
	cmp N64_RESET_BUTTON ; we stay in the init until the button is left off
	beq debounce_init
	inx
	cpx #$00
	bne inc_x_counter
debounce_mem00:
	inc $00
	lda #$00
	cmp $00
	bne inc_x_counter
debounce_mem01:
	inc $01
	lda #$00
	cmp $01
	bne inc_x_counter
debounce_mem02:
	inc $02
	lda #$00
	cmp $02
	bne inc_x_counter
debounce_mem03:
	inc $03
	lda #$00
	cmp $03
	bne inc_x_counter
debounce_completed:
	lda #$00
	sta $00
	sta $01
	sta $02
	sta $03
	lda #$FF
	STA N64_NMI
	JMP CRC_INIT_BOOTUP
	
CRC_UPDATE:		; This is for changing the CRC  using the 30 code and will reboot the core
	ldx #$00
	LDY #$24
	LDA #$C0
	STA $CE
	LDA #$17
	sta $CF
CRC_UPDATE_LOOP:
	lda $00d0,x
	sta ($CE),y
	inx
	iny
	CPy #$28
	bne CRC_UPDATE_LOOP
	lda #$00
	sta N64_SGM
	jmp CRC_INIT_BOOTUP_LOOP


  ;d0 is the 31:24 bits of the CRC being used
  ;d1 is the 23:16 bits of the CRC being used
  ;d2 is the 15:8  bits of the CRC being used
  ;d3 is the 7:0   bits of the CRC being used

CRC_INIT_BOOTUP:
	lda #$00
	ldx #$24
	STA N64_RAM,X
	sta $D0
	inx
	lda #$00
	LDY N64_PAL ; if High we will make it PAL
	cpy #$FF
	beq CRC_INIT_BOOTUP_PAL
	lda #$0A
CRC_INIT_BOOTUP_PAL:
	STA N64_RAM,X
	sta $D1
	inx
	lda #$3F
	STA N64_RAM,X
	sta $D2
	inx
	STA N64_RAM,X
	sta $D3
	LDA #$00
	sta N64_SGM
CRC_INIT_BOOTUP_LOOP:
	ldx N64_PIF_PROCESSING
	cpx #$FF
	bne CRC_INIT_BOOTUP_LOOP
	ldx N64_PIF_ADDRESS
	cpx #$FC
	bcc CRC_INIT_BOOTUP_LOOP
	lda #$80
	sta N64_SGM
	rts

; zeropage 00 low address reading on PifRam
; zeropage 01 high
; zeropage 02 channels to worked on #$10 -- Joy 1	#$20 -- Joy 2	#$30 -- Joy 3	#$40 -- Joy4	#$50 -- EPPROM
; zeropage 03 save the current Y and this will be the next Y on the main loop
; zeropage 04 
; zeropage 05 controller processing for controller as a bit location 	#$01 -- Joy 1	#$02 -- Joy 2	#$04 -- Joy 3	#$08 -- Joy4
; zeropage 0A	Current Command
; zeropage 0B	Current Receive bytes
; zeropage 0C	Current send Bytes
; zeropage 10 channel 1 cmd
; zeropage 11 channel 1 send data
; zeropage 12 channel 1 receive data
; zeropage 20 channel 2 cmd
; zeropage 21 channel 2 send data
; zeropage 22 channel 2 receive data
; zeropage 30 channel 3 cmd
; zeropage 31 channel 3 send data
; zeropage 32 channel 3 receive data
; zeropage 40 channel 4 cmd
; zeropage 41 channel 4 send data
; zeropage 42 channel 4 receive data
; zeropage 50 channel 5 cmd
; zeropage 51 channel 5 send data
; zeropage 52 channel 5 receive data

pif_process_init:
	LDA #$80
	STA N64_SGM
	lda #$17
	sta $01
	lda #$c0
	sta $00
	lda #$00
	sta $03
	sta $10
	sta $11
	sta $12
	sta $20
	sta $21
	sta $22
	sta $30
	sta $31
	sta $32
	sta $40
	sta $41
	sta $42
	sta $50
	sta $51
	STA $52
	LDA #$10
	STA $02
	LDA #$00
	STY $00
pif_looping:
	CPY #$ff
	BNE pif_finish_not	
	JMP pif_finish
	
pif_finish_not:	
	STY $03
	ldx $17C0,Y
	CPX #$fe
	bne test_finished1
	jmp pif_finish
test_finished1:	
	cpx #$fd
	BNE test_finished2
	JMP pif_finish	
test_finished2:	
	cpx #$00
	bne test_channel_check
	jsr add_channel
test_channel_check:
	lda #$00
	CPX #$ff
	BNE test_pif_next_address
	STA $03
	JSR Process_controller
	INY
	LDA $17C0,Y
	INY
	ADC $17C0,Y
	ADC $03
	adc #$02
test_pif_next_address:	
	ldy $03
	JMP pif_looping
	


Process_controller
	ldx #$00
	INY
	LDA ($02,X)
	CPX #$00
	BNE Test_read_buttons
	jsr Controller_status
Test_read_buttons:
	LDX $02
	CPX #$01
	BNE Test_read_mempak
	jsr Controller_read_buttons
Test_read_mempak:	
	LDX $02
	CPX #$02
	BNE Test_Controller_write_mempak
	jsr Controller_read_buttons
Test_Controller_write_mempak:
	LDX $02
	CPX #$03
	BNE Test_Controller_reset_command
	jsr Controller_write_mempak
Test_Controller_reset_command:
	LDX $02
	CPX #$04
	BNE Test_Controller_finish_processing
	JSR Controller_reset_cmd
Test_Controller_finish_processing:
	;need to check what address is the next channel
	LDA #$10 ; We increase the channel for controllers
	ADC $02
	sta $02
	rts
	


	
	;Controller_CMD    = $32A0
	;Controller_LOA    = $32A1
	;Controller_HIA    = $32A2
	;Controller_WRT    = $32A3
	;Controller_RED    = $32A4
	;Controller_STA    = $32A5
	;Controller_CON    = $32A6
	
Controller_status:
	ldy #$00
	LDA $00
	STA Controller_CMD
	LDA #$00
	STA Controller_LOA
	sta Controller_HIA	
	JSR Send_conntroller_start_cmd
	JSR Controller_wait_completed
	jsr Controller_read_fifo
	jsr Controller_update_channel_access
	rts
	

Controller_read_buttons:
	ldy #$00
	LDA $01
	STA Controller_CMD
	LDA #$00	
	JSR Send_conntroller_start_cmd
	JSR Controller_wait_completed
	jsr Controller_read_fifo
	jsr Controller_update_channel_access
	rts

Controller_read_mempak:
	ldy #$00
	LDA $02
	STA Controller_CMD
	LDA #$00
	STA Controller_LOA
	sta Controller_HIA	
	JSR Send_conntroller_start_cmd
	jsr Controller_write_fifo
	JSR Controller_wait_completed
	jsr Controller_read_fifo
	jsr Controller_update_channel_access
	rts


Controller_write_mempak:
	ldy #$00
	LDA $03
	STA Controller_CMD
	LDA #$00
	STA Controller_LOA
	sta Controller_HIA	
	JSR Send_conntroller_start_cmd
	JSR Controller_wait_completed
	jsr Controller_read_fifo
	jsr Controller_update_channel_access
	rts


Controller_reset_cmd:
	ldy #$00
	LDA $ff
	STA Controller_CMD
	LDA #$00
	STA Controller_LOA
	sta Controller_HIA	
	JSR Send_conntroller_start_cmd
	JSR Controller_wait_completed
	jsr Controller_update_channel_access
	rts
	
; here are all the commands to the controller_system	
Send_conntroller_start_cmd:
	LDX $02
	CPX $01
	bne test_joy2
	LDA #$01
test_joy2:	
	CPX $02
	bne test_joy3
	LDA #$02
test_joy3:	
	CPX $03
	bne test_joy4
	LDA #$04
test_joy4:
	LDA #$08
	STA $05
	sta Controller_CON
	rts	

Controller_wait_completed:
	LDX Controller_STA
	CPX #$7F
	BCS Controller_wait_completed	
	RTS
	
Controller_read_fifo:
	LDY #$02
	LDA $02,Y
	TAX
Controller_read_fifo_loop:
	LDA Controller_RED
	sta ($00,X)
	dex
	cpx #$00
	bne Controller_read_fifo_loop	
	RTS
	
Controller_write_fifo:

	RTS
		
	
Controller_update_channel_access:
	
	RTS
		
		

add_channel:
	lda $11
	adc #$01
	sta $11
	tax
	CPX #$05
	bne test_eprom_channel
	JSR eeprom_init
test_eprom_channel:
	CPX #$06
	BNE test_finish_channel
	pla
	jmp pif_finish
test_finish_channel:
	lda $17C0,Y
	tax
	cpx #$FF
	; beq pif_process
	rts

pif_finish:
	LDA #$ff
	sta $03
	lda #$00
	sta N64_SGM
	rts

;controller_init:
 ; lda $17C0,Y
;  sta

eeprom_init:

	rts



