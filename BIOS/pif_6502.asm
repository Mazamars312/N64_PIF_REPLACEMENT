
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
  jsr PIF_ROM2RAM
  jsr NMI_UP
  jmp MAINLOOP


MAINLOOP:
  jsr CHECK_CONTROLLER_STATUS



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

  Loop:
  lda [$FB],Y ;indirect index source memory address, starting at $00
  sta [$FD],Y ;indirect index dest memory address, starting at $00
  inc $FB ;increment low order source memory address byte by 1
  inc $FD ;increment low order dest memory address byte by 1
  bne Loop ;loop until our dest goes over 255

  inc $FC ;increment high order source memory address, starting at $80
  inc $FE ;increment high order dest memory address, starting at $60
  lda $FE ;load high order mem address into a
  cmp #$20 ;compare with the last address we want to write
  bne Loop ;if we're not there yet, loop
  rts

NMI_UP:
  lda #$ff
  sta N64_NMI
  rts

NMI_DOWN:
  lda #$ff
  sta N64_NMI
  rts

INT_UP:
  lda #$ff
  sta N64_INT2
  rts

INT_DOWN:
  lda #$ff
  sta N64_INT2
  rts



;
;
;
; CLRMEM: LDA #$00        ;Set up zero value
; CLRM1:  DEY             ;Decrement counter
;         STA (TOPNT),Y   ;Clear memory location
;         BNE CLRM1       ;Not zero, continue checking
;         RTS             ;RETURN
;
;
; ; Debouncer for interupt
;
;         LDA #$00        ;CLEAR PERIPHERAL CONTROL REGISTER
;         STA $A00C
;         STA $A003       ;MAKE PORT A INPUTS
;         STA $40         ;CLOSURE COUNT = 0
; CHKBTN: LDA $A001       ;READ PORT A
;         BPL DONE        ;DONE IF BUTTON NO. 2 IS PUSHED (PA7 = 0)
;         AND #$04        ;IS BUTTON NO. 1 PUSHED (PA2 = 0)?
;         BNE CHKBTN      ;NO. WAIT UNTIL IT IS.
;         INC $40         ;YES. INCREMENT CLOSURE COUNT.
;         JSR DLY10       ;WAIT 10 MILLISECONDS TO DEBOUNCE
; CHKREL: LDA $A001       ;READ PORT A AGAIN
;         AND #$04        ;IS BUTTON NO. 1 STILL CLOSED?
;         BEQ CHKREL      ;YES. WAIT FOR RELEASE
;         JSR DLY10       ;NO. DEBOUNCE THE KEY OPENING
;         JMP CHKBTN      ; AND WAIT FOR NEXT CLOSURE
;
;
; DLY10:   LDA #$00       ;SET TI ONE-SHOT MODE, WITH NO PB7
;          STA $A00B
;          LDA #$10       ;WRITE COUNT LSBY
;          STA $A004
;          LDA #$27       ;WRITE COUNT MSBY AND START TIMER
;          STA $A005
;          LDA #$40       ;SELECT T1 INTERRUPT MASK
; CHKT1:   BIT $A00D      ;HAS T1 COUNTED DOWN?
;          BEQ CHKT1      ;NO. WAIT UNTIL IT HAS
;          LDA $A004      ;YES. CLEAR T1 INTERRUPT FLAG
;          RTS            ; AND RETURN
