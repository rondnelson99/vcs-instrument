.include "defines.asm"


.RAMSECTION "graphics vars" SLOT "RAM"


.ENDS

.ENUM Scratchpad
wScreenDigitPtr: dw
wScreenDigitPtr2: dw
wScreenDigitPtr3: dw
wScreenDigitPtr4: dw
wTempLineCount: db ;temorary counter for when registers are full
.ENDE

.slot "ROM"
.SECTION "Render", FREE
RenderScreen:
    ;input calls are spread throughout the drawing because they need to be at least 7 scanlines apart
    jsr ProcessInput1

    ;start with two-digit instrument divider indicators for the two voices
    ; cofigure some stuff for that while waiting to position the players
    sta WSYNC
    lda #4 ;two copies, wide
    sta NUSIZ0
    sta NUSIZ1
    lda #$65
    sta COLUP0
    sta COLUP1
    lda #0
    sta GRP0
    sta GRP1
    sta PF0
    sta PF1
    sta PF2

    sta RESP0
    sta RESP1

    lda #1<<4 ; shift 1 px left
    sta HMP1
    
    lda #>NumberData
    sta wScreenDigitPtr + 1
    sta wScreenDigitPtr2 + 1
    sta wScreenDigitPtr3 + 1
    sta wScreenDigitPtr4 + 1

    ; set up the pointers for the two digit divider indicators
    lda wCurrentNoteA
    rol
    rol
    rol
    rol ;get the instrument number into the bottom two bits
    and #%11
    tax
    lda.w InstrumentDividerTable,x
    and #$f0
    lsr
    sta wScreenDigitPtr
    lda.w InstrumentDividerTable,x
    and #$0f
    asl
    asl
    asl
    sta wScreenDigitPtr2

    lda #0
    sta WSYNC
    sta HMOVE
    sta VBLANK

    ldy #7 
DrawDividers:
    lda #2
    sta wTempLineCount
@nextLine
    sta WSYNC
    lda (wScreenDigitPtr),y
    sta GRP0
    lda (wScreenDigitPtr2),y
    sta GRP1 
    lax (wScreenDigitPtr3),y
    lda (wScreenDigitPtr4),y

    SLEEP 12
    stx GRP0
    sta GRP1

    dec wTempLineCount
    bne @nextLine
    dey
    bne DrawDividers
    
    sta WSYNC
    lda #$ff
    sta VBLANK

    lda #0
    sta GRP0
    sta GRP1 ; clear the player sprites

    ; configure graphics stuff for the two big numbers
    lda #%10
    sta CTRLPF ;scoreboard mode

    lda #$c2 ;nice green
    bit wCurrentNoteA
    bmi @green
    lda #$42 ; if the interval is out of tune, make it red
@green
    sta COLUP0
    lda #$78
    sta COLUP1

    lda #6 << 3
    sta wScreenDigitPtr3
    lda #9 << 3
    sta wScreenDigitPtr4

   

    ;set the first 2 digits
    lda wCurrentNoteA
    and #%11111 ; isolate the period
    tax
    inx ;increment since it's off by one
    lda.w BinToBCD,x ; now first digit is in top 4 bis of A, but it needs to be in bits 3-6
    lsr 
    and #%01111000 ;isolate the digit
    sta wScreenDigitPtr
    lda.w BinToBCD,x
    and #$0F ;isolate the digit
    asl
    asl 
    asl ; get it in bits 3-6
    sta wScreenDigitPtr2



    lda #6 << 3
    sta wScreenDigitPtr3
    lda #9 << 3
    sta wScreenDigitPtr4
    
    
    


    lda #0
    sta VBLANK
    ldy #7 
DrawNumbers:
    lda #7
    sta wTempLineCount
@nextLine
    sta WSYNC
    lda (wScreenDigitPtr),y
    sta PF1
    lax (wScreenDigitPtr2),y
    lda.w BitReverseLUT,x
    sta PF2 ;cycle 20
    lax (wScreenDigitPtr4),y
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
    bne DrawNumbers

    ;enable VBLANK
    sta WSYNC
    lda #%10
    sta VBLANK

    ;move on with input
    jsr ProcessInput2

    .rept 7
    sta WSYNC
    .endr

    jsr ProcessInput3

    .rept 7
    sta WSYNC
    .endr

    jsr ProcessInput4

DelayRTS: ;useful to jsr to as a delay
    rts




.ENDS

.SECTION "Number font data", FREE, ALIGN 256 
;these graphics will be accessed with decrementing pointers
NumberData:
    incvr2bpp "res/numbers.1bpp", 80
.ENDS

.SECTION "Frequency to BCD conversion table", FREE, ALIGN 64
;this table is used to convert binary numbers 0-32 to BCD
BinToBCD:
    .rept 33 INDEX I
        .db ((I/10)<<4) + I#10
    .endr
.ENDS
    

.SECTION "Bit reverse LUT", FREE, ALIGN 256
BitReverseLUT:
    .rept 256 INDEX I
        .dbm bitReverse I
    .endr
.ENDS


