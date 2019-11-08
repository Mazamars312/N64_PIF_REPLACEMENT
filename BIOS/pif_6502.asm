; Ok Here we are, this is the 6502 code for the PIF controller.
; This will be a full work in processes

* = $F000
; Address Constants
CRCrom_LUT0	= $0280
CRCrom_LUT1	= $0290

Controller_CMD    = $02A0
Controller_LOA    = $02A1
Controller_HIA    = $02A2
Controller_WRT    = $02A3
Controller_RED    = $02A4
Controller_STA    = $02A5
Controller_CON    = $02A6

EPROM_CMD         = $02B0
EPROM_LOA         = $02B1
EPROM_HIA         = $02B2
EPROM_WRT         = $02B3
EPROM_RED         = $02B4
EPROM_STA         = $02B5
EPROM_CON         = $02B6

N64_NMI           = $02C0
N64_INT2          = $02C1
N64_PIFDISABLED   = $02C2
N64_PIF_PAGE      = $02C3
N64_PAL           = $02C4

PIF_ROM           = $1000

PIF_RAM           = $2000

; Controller Commands
controller_status       = #$00
controller_read_buttons = #$01
controller_read_mem     = #$02
controller_write_mem    = #$03
controller_reset        = #$FF

START:
  jmp PIF_ROM2RAM

MAINLOOP:



CHECK_CONTROLLER_STATUS:
  lda Controller_STA
  jmp CHECK_CONTROLLER_STATUS


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
  jmp MAINLOOP

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
