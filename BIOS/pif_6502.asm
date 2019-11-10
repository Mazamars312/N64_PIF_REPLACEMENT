
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

PIF_ROM           = $1000

PIF_RAM           = $2000

N64_RAM           = $2700
N64_SGM           = $27FF

controller_status       = #$00
controller_read_buttons = #$01
controller_read_mem     = #$02
controller_write_mem    = #$03
controller_reset        = #$FF

START:
  jsr CLEARPIFRAM
  jsr PIF_ROM2RAM
  jsr NMI_UP
  jmp MAINLOOP


MAINLOOP:
  jsr CHECKSEG
  jsr CHECK_RESET
  jmp MAINLOOP


CHECK_CONTROLLER_STATUS:
  lda Controller_STA
  rts


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
  lda #$00
  sta N64_NMI
  rts

INT_UP:
  lda #$ff
  sta N64_INT2
  rts

INT_DOWN:
  lda #$00
  sta N64_INT2
  rts


CLEARPIFROM
  lda #$00 ;set our destination memory to copy to, $1000, WRAM
  sta $FD
  lda #$10
  sta $FE
  ldy #$00 ;reset x and y for our loop
  ldx #$00
  jmp CLEARPIFRAMLOOP

CLEARPIFRAM
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
  jmp MAINLOOP


CHECKSEG
  ldx N64_SGM
  lda #$80
  sta N64_SGM
  cpx #$02
  beq 6105_crc_init
  cpx #$10
  beq CLEARPIFROM
  cpx #$C0
  beq CLEARPIFRAM
  cpx #$30
  beq CRC_CHECKING
  cpx #$08
  beq PIF_INTUPT
  cpx #$01
  beq pif_init
  jmp MAINLOOP

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

controller_init
  lda #$17C0,Y
  sta

pif_init
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
pif_process
 sty #$00
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

add_channel
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
  beq pif_process
  jmp controller_init

pif_finish
  lda #$00
  sta N64_SGM
  jmp MAINLOOP
