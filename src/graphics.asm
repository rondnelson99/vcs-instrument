.include "defines.asm"


.RAMSECTION "graphics vars" SLOT "RAM"
wScreenDigit: db
wScreenDigit2: db
wScreenDigit3: db
wScreenDigit4: db
wScreenDigitPtr: dw
wScreenDigitPtr2: dw
wScreenDigitPtr3: dw
wScreenDigitPtr4: dw
wTempLineCount: db ;temorary counter for when registers are full

.ENDS

.slot "ROM"
.SECTION "Render", FREE
RenderScreen:
    ; start by accurately positioning and configuring Player 0
    lda #%10
    sta CTRLPF ;scoreboard mode
    lda #$42
    sta COLUP0
    lda #$78
    sta COLUP1
    lda #0
    sta PF0
    sta PF1
    sta PF2
    lda #6
    sta wScreenDigit
    lda #9
    sta wScreenDigit2
    lda #4
    sta wScreenDigit3
    lda #2
    sta wScreenDigit4
    
    ldx #3
    ldy #6
@shiftloop
    lda wScreenDigit,x
    asl
    asl
    asl
    sta wScreenDigitPtr,y
    dey
    dey
    dex
    bpl @shiftloop

    lda #>NumberData
    sta wScreenDigitPtr + 1
    sta wScreenDigitPtr2 + 1
    sta wScreenDigitPtr3 + 1
    sta wScreenDigitPtr4 + 1
    


    lda #0
    sta VBLANK
    ldy #7 
@drawnumbers
    lda #8
    sta wTempLineCount
@nextLine
    sta WSYNC
    lda (wScreenDigitPtr),y
    sta PF1
    lax_ind_y wScreenDigitPtr2
    lda.w BitReverseLUT,x
    sta PF2 ;cycle 20
    lax_ind_y wScreenDigitPtr4
    lda.w BitReverseLUT,x 
    tax 
    lda (wScreenDigitPtr3),y ;cycle 36
    SLEEP 2
    sta PF1 ;cycle 41
    SLEEP 6
    stx PF2 ;cycle 50
    
    dec wTempLineCount
    bne @nextLine
    dey
    bne @drawnumbers

    sta WSYNC

DelayRTS: ;useful to jsr to as a delay
    rts




.ENDS

.SECTION "Number font data", FREE, ALIGN 256 
;these graphics will be accessed with decrementing pointers
NumberData:
    incvr2bpp "res/numbers.1bpp", 80
.ENDS

.SECTION "Bit reverse LUT", FREE, ALIGN 256
BitReverseLUT:
    .rept 256 INDEX I
        .dbm bitReverse I
    .endr
.ENDS


