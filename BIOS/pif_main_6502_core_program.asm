*= $F000

CRCrom_LUT0	= $0280
CRCrom_LUT1	= $0290

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

N64_RAM           = $1700
N64_SGM           = $17FF


; Set zeropage locations

;00-0F is temp numbers for checking things

; the below is for Channel processing
; 10 channel 1 cmd
; 11 channel 1 send data
; 12 channel 1 receive data
; 20 channel 2 cmd
; 21 channel 2 send data
; 22 channel 2 receive data
; 30 channel 3 cmd
; 31 channel 3 send data
; 32 channel 3 receive data
; 40 channel 4 cmd
; 41 channel 4 send data
; 42 channel 4 receive data
; 50 channel 5 cmd
; 51 channel 5 send data
; 52 channel 5 receive data

;d0 is the 31:24 bits of the CRC being used
;d1 is the 23:16 bits of the CRC being used
;d2 is the 15:8  bits of the CRC being used
;d3 is the 7:0   bits of the CRC being used

;f0-ff is mamory transfers



jsr INT_DOWN
jsr NMI_DOWN
jsr CLEARPIFRAM
jsr PIF_ROM2RAM
jsr NMI_UP
lda #$00
sta N64_SGM
jsr CRC_INIT_BOOTUP
jmp MAINLOOP

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
; inc $FD ;increment low order dest memory address byte by 1
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
cpx #$00
bne INT_DOWN_LOOP
rts


CLEARPIFROM:
lda #$00 ;set our destination memory to copy to, $1000, WRAM
sta $FD
lda #$10
sta $FE
ldy #$00 ;reset x and y for our loop
ldx #$00
jmp CLEARPIFRAMLOOP

CLEARPIFRAM:
lda #$00 ;set our destination memory to copy to, $1000, WRAM
sta $FD
lda #$17
STA $FE
ldy #$C0
lda #$01
CLEARPIFRAMLOOP:
sta ($FD),Y ;indirect index dest memory address, starting at $00
INy
cpy #$00
bne CLEARPIFRAMLOOP ;loop until our dest goes over 255
inc $FE ;increment high order dest memory address, starting at $60
lda $FE ;load high order mem address into a
cmp #$18;compare with the last address we want to write
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
jmp crcinit6105

test_crc_change:
cpx #$40
Bne test_DMA_int
jmp CRC_CHANGE  ; This is for changing the CRC. write the CRC in offset 0x24 of 0x17c0 to place this in the ram Temp files
test_DMA_int:
cpx #$08
bne test_clear_rom
jmp INT_UP ; this will do a interupt after processing the code
test_clear_rom:
CPX #$10
Bne test_clear_ram
JMP CLEARPIFROM
test_clear_ram:
cpx #$C0
BNE test_crc_update
JMP CLEARPIFRAM
test_crc_update:
cpx #$30
Bne test_pif_process
JMP CRC_UPDATE  ; This is for a reboot of the CRC in the system
test_pif_process:
cpx #$01
BNE clear_process
JMP pif_process_init
clear_process:
lda #$00        ; this is the ready signal for the PIF
sta N64_SGM
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
jmp MAINLOOP
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
sta N64_NMI
jsr CRC_UPDATE
jmp MAINLOOP


CRC_UPDATE:
ldx #$24
ldy #$00
CRC_UPDATE_LOOP:
lda $d0,x
sta $17c0,y
inx
iny
cpx #$28
bne CRC_INIT_BOOTUP_LOOP
lda #$80
sta N64_SGM
jmp CRC_UPDATE_LOOP


;d0 is the 31:24 bits of the CRC being used
;d1 is the 23:16 bits of the CRC being used
;d2 is the 15:8  bits of the CRC being used
;d3 is the 7:0   bits of the CRC being used

CRC_INIT_BOOTUP:
lda #$00
ldx #$24
sta $17c0,X
inx
lda #$00
LDY N64_PAL
cpy #$FF
bne CRC_INIT_BOOTUP_PAL
lda #$0A
CRC_INIT_BOOTUP_PAL:
sta $17c0,X
inx
lda #$3F
sta $17c0,X
inx
sta $17c0,X
CRC_INIT_BOOTUP_LOOP:
ldx N64_PIF_PROCESSING
cpx #$FF
bne CRC_INIT_BOOTUP_LOOP
ldx N64_PIF_ADDRESS
cpx #$FC
bcs CRC_INIT_BOOTUP_LOOP
lda #$80
sta N64_SGM
rts

; 00 low address reading on PifRam
; 01 high
; 02 channels to worked on
; 03 channel selection offset see the offset tomorrow
; 10 channel 1 cmd
; 11 channel 1 send data
; 12 channel 1 receive data
; 20 channel 2 cmd
; 21 channel 2 send data
; 22 channel 2 receive data
; 30 channel 3 cmd
; 31 channel 3 send data
; 32 channel 3 receive data
; 40 channel 4 cmd
; 41 channel 4 send data
; 42 channel 4 receive data
; 50 channel 5 cmd
; 51 channel 5 send data
; 52 channel 5 receive data

pif_process_init:
lda #$00
sta $00
sta $01
sta $02
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
sta $52
pif_process:
sty $00
lda $17C0,Y
tax
iny
cpx #$fe
cpx #$fd
beq pif_finish
cpx #$00
beq add_channel
cpx #$ff
beq add_channel
cpy #$ff
beq pif_finish
jmp pif_process

add_channel:
lda $11
adc #$01
sta $11
tax
cpx #$05
beq eeprom_init
cpx #$06
beq pif_finish
lda $17C0,Y
tax
cpx #$FF
; beq pif_process
jmp pif_process

pif_finish:
lda #$00
sta N64_SGM
jmp MAINLOOP

;controller_init:
; lda $17C0,Y
;  sta

eeprom_init:
jmp MAINLOOP


; This is the 6502 impermintation of the N64 CRC 6/7105 challange and responce process
; It is based on the code by X-scale but converted to ASM.
; It has not been tested yet at this moment but it does have most of teh code down ready to be tested.


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
lda #$C0  ; Here is the start of the CRC seek for the challange
sta $FC
lda #$27
sta $FD ; this is the start of where the CRC SEED will be for the 6105 code in memory so we can start working with it
lda #$80
sta $FA
lda #$32
sta $FB ; this is the location of the first address for the CRC roms

crc_main_loop
lda [$FC],X ; we get the hig nibbles to  process
lsr  ; we shift 4 for the top nibble
lsr
lsr
lsr
and #$0F ; and just to make sure that the nibble is only 4Bits
jsr crc_process_nibble
stx $F0
ldx #$00
lda [$FC],X
and #$0F
jsr crc_process_nibble
stx $F1 ; Store the first nibble at zeropage F0
lda $F0
asl
asl
asl
asl
ora $F1
ldx #$00
sta [$FC],X
inc $FC
ldx $FC
cpx #$FF
bne crc_main_loop
lda #$00
sta [$FC],X
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
adc #$05
sta $C5
ldx #$00
responce_multi_5 ; responce = (key +5) * 5
adc $C5
inx
cpx $C6
bne responce_multi_5
and #$07 ; responce & 0x07
sta $C5
; key = lut [responce]
ldx $C1
cpx #$01
beq lut1_key
lut0_key
ldx $C5
lda $3280,x
jmp sgn_key
lut1_key
ldx $C5
lda $3290,x
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
lda #$B0
sta $00
lda #$03
sta $01
lda $00
sec
modulus:
sbc $00
bcs modulus
adc $01
tax
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
sta $C1
jmp crc_main_loop

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
cpx #$28
Beq CRC_CHANGE_jump
JMP crc_main_loop
CRC_CHANGE_jump
lda #$00
sta $17FF
jmp CRC_CHANGE_LOOP
