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
  beq pif_process
  jmp controller_init

pif_finish:
  lda #$00
  sta N64_SGM
  jmp MAINLOOP

controller_init:
  lda #$17C0,Y
  sta
