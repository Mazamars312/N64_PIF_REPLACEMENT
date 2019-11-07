; Ok Here we are, this is the 6502 code for the PIF controller.
; This will be a full work in processes

* = $F000

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


START LDA





CLRMEM  LDA #$00        ;Set up zero value
CLRM1   DEY             ;Decrement counter
        STA (TOPNT),Y   ;Clear memory location
        BNE CLRM1       ;Not zero, continue checking
        RTS             ;RETURN


; Debouncer for interupt

        LDA #$00        ;CLEAR PERIPHERAL CONTROL REGISTER
        STA $A00C
        STA $A003       ;MAKE PORT A INPUTS
        STA $40         ;CLOSURE COUNT = 0
CHKBTN  LDA $A001       ;READ PORT A
        BPL DONE        ;DONE IF BUTTON NO. 2 IS PUSHED (PA7 = 0)
        AND #$04        ;IS BUTTON NO. 1 PUSHED (PA2 = 0)?
        BNE CHKBTN      ;NO. WAIT UNTIL IT IS.
        INC $40         ;YES. INCREMENT CLOSURE COUNT.
        JSR DLY10       ;WAIT 10 MILLISECONDS TO DEBOUNCE
CHKREL  LDA $A001       ;READ PORT A AGAIN
        AND #$04        ;IS BUTTON NO. 1 STILL CLOSED?
        BEQ CHKREL      ;YES. WAIT FOR RELEASE
        JSR DLY10       ;NO. DEBOUNCE THE KEY OPENING
        JMP CHKBTN      ; AND WAIT FOR NEXT CLOSURE


DLY10    LDA #$00       ;SET TI ONE-SHOT MODE, WITH NO PB7
         STA $A00B
         LDA #$10       ;WRITE COUNT LSBY
         STA $A004
         LDA #$27       ;WRITE COUNT MSBY AND START TIMER
         STA $A005
         LDA #$40       ;SELECT T1 INTERRUPT MASK
CHKT1    BIT $A00D      ;HAS T1 COUNTED DOWN?
         BEQ CHKT1      ;NO. WAIT UNTIL IT HAS
         LDA $A004      ;YES. CLEAR T1 INTERRUPT FLAG
         RTS            ; AND RETURN
