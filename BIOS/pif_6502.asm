
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
  beq pif_process
  jmp MAINLOOP

pif_process
