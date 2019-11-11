
* = $F000

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

controller_status       = #$00
controller_read_buttons = #$01
controller_read_mem     = #$02
controller_write_mem    = #$03
controller_reset        = #$FF

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


START:
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
  jmp CHECKSEG
  jmp CHECK_RESET_BUTTON
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
  lda [$FB],Y ;indirect index source memory address, starting at $00
  sta [$FD],Y ;indirect index dest memory address, starting at $00
  inc $FB ;increment low order source memory address byte by 1
  inc $FD ;increment low order dest memory address byte by 1
  bne PIF_ROM2RAMLOOP ;loop until our dest goes over 255
  inc $FC ;increment high order source memory address, starting at $80
  inc $FE ;increment high order dest memory address, starting at $60
  lda $FE ;load high order mem address into a
  cmp #$20 ;compare with the last address we want to write
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
  cpx #$00
  beq NMI_DOWN_LOOP
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
  beq INT_DOWN_LOOP
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
  lda #$C0 ;set our destination memory to copy to, $1000, WRAM
  sta $FD
  lda #$1f
  sta $FE
  ldy #$00 ;reset x and y for our loop
  ldx #$00
  jmp CLEARPIFRAMLOOP

CLEARPIFRAMLOOP:
  sta [$FD],Y ;indirect index dest memory address, starting at $00
  inc $FD ;increment low order dest memory address byte by 1
  bne CLEARPIFRAMLOOP ;loop until our dest goes over 255
  inc $FE ;increment high order dest memory address, starting at $60
  lda $FE ;load high order mem address into a
  cmp #$20 ;compare with the last address we want to write
  bne CLEARPIFRAMLOOP ;if we're not there yet, loop
  jmp pif_process_init


CHECKSEG:
  ldx N64_SGM
  cpx #$00
  beq MAINLOOP ; we have to make sure that if it is 00 then we can move it on
  lda #$80
  sta N64_SGM
  cpx #$02
  beq 6105_crc_process_init
  cpx #$40
  beq CRC_CHANGE  ; This is for changing the CRC. write the CRC in offset 0x24 of 0x17c0 to place this in the ram Temp files
  cpx #$08
  beq INT_UP ; this will do a interupt after processing the code
  cpx #$10
  beq CLEARPIFROM
  cpx #$C0
  beq CLEARPIFRAM
  cpx #$30
  beq CRC_UPDATE  ; This is for a reboot of the CRC in the system
  cpx #$01
  beq pif_process_init
  lda #$00        ; this is the ready signal for the PIF
  sta N64_SGM
  jmp MAINLOOP



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
  bne MAINLOOP
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
  lda N64_PAL
  cmp #$FF
  lda #$00
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
  cmp #$FF
  bne CRC_INIT_BOOTUP_LOOP
  ldx N64_PIF_ADDRESS
  cpx #$FC
  bcs CRC_INIT_BOOTUP_LOOP
  lda #$80
  sta N64_SGM
  rts
