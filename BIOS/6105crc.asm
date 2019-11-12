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
; zeropage c7/c8 the address to be read from the CRC Rom
; zeropage c9 is the offset base address of the CRC Rom


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
  cpx #$28
  Beq CRC_CHANGE_jump
  JMP crc_main_loop
CRC_CHANGE_jump
  lda #$00
  sta $17FF
  jmp CRC_CHANGE_LOOP
