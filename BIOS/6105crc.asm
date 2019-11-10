6105_crc_init
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
  ;lda #$00
  ;sta $
  6105_crc_main_loop
  lda [$FC],X ; we get the hig nibbles to  process
  lsr A ; we shift 4 for the top nibble
  lsr A
  lsr A
  lsr A
  and #$0F ; and just to make sure that the nibble is only 4Bits
  jsr 6105_crc_process
  stx $F0
  ldx #$00
  lda [$FC],X
  and #$0F
  jsr 6105_crc_process
  stx $F1 ; Store the first nibble at zeropage F0
  lda $F0
  asl A
  asl A
  asl A
  asl A
  ora $F1
  ldx #$00
  sta [$FC],X
  inc $FC
  ldx $FC
  cpx #$FF
  bne 6105_crc_main_loop
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

6105_crc_process ; from here we will use the C0 zeropage locations
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
  jmp sgn_key
  ; sgn =
  sgn_key
  lda $C5
  lsr A
  lsr A
  lsr A
  and #$01
  sta $C2
  ;mag check
  cmp #$01
  bne mag_false
  mag_true
  lda #$ff
  eor $c5
  sta $c3
  jmp mod_test
  mag_false
  lda #$07
  and $c5
  sta $c3

  mod_test

  lda #$B0
  sta $00
  lda #$03
  sta $01
  lda $00
  sec
modulus
  sbc $00
  bcs modulus
  adc $01
  tax
  cpx #$1
  bne sign_neg_1
  lda $C2
  sta $C4
  jmp lut1_level1_test

  sign_neg_1
  lda #$01
  sbc $c2
  sta $C4

  lut1_level1_test
  ldx #$01
  cpx $C5
  beq lut1_level1_lut1_mod_true
  ldx #$09
  cpx $C5
  beq lut1_level1_lut1_mod_true
  jmp lut1_level2_test

  lut1_level1_lut1_mod_true
  ldx #$01
  cpx $C1
  bne lut_check
  lda #$01
  sta $C4

  lut1_level2_test
  ldx #$0B
  cpx $C5
  beq lut1_level2_lut1_mod_true
  ldx #$0E
  cpx $C5
  beq lut1_level2_lut1_mod_true
  jmp lut_check

  lut1_level2_lut1_mod_true
  ldx #$01
  cpx $C1
  bne lut_check
  lda #$00
  sta $C4

  lut_check
  ldx $c4
  cpx #$01
  bne LUT_NOT_TRUE
  lda #$00
  sta $C1
  rts
  LUT_NOT_TRUE
  lda #$01
  sta $C1
  jmp MAINLOOP
