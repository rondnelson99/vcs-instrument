.include "defines.asm"


.RAMSECTION "graphics vars" SLOT "RAM"
wScreenDigit: db
wScreenDigit2: db
wScreenDigitPtr: dw
wScreenDigitPtr2: dw
.ENDS

.slot "ROM"
.SECTION "Render", FREE
RenderScreen:
    ; start by accurately positioning and configuring Player 0
    lda #7
    sta NUSIZ0
    sta NUSIZ1
    lda #$42
    sta COLUP0
    sta COLUP1
    lda #0
    sta GRP0
    nop
    nop
    sta RESP0
    nop
    lda #0
    sta GRP1
    sta RESP1
    lda #6
    sta wScreenDigit
    lda #9
    sta wScreenDigit2
    lda wScreenDigit
    asl
    asl
    asl ;multiply by 8
    sta wScreenDigitPtr
    ;now do the same for the other number
    lda wScreenDigit2
    asl
    asl
    asl
    sta wScreenDigitPtr2

    lda #>NumberData
    sta wScreenDigitPtr + 1
    sta wScreenDigitPtr2 + 1
    


    ldy #8
    sta WSYNC
    sty VBLANK
@drawnumber
    lda (wScreenDigitPtr),y
    sta GRP0
    lda (wScreenDigitPtr2),y
    sta GRP1
    ldx #8
@scanlineLoop
    sta WSYNC
    dex
    bne @scanlineLoop
    dey
    bne @drawnumber








    
    rts




.ENDS

.SECTION "Number font data", FREE, ALIGN 256 OFFSET 1 
;these graphics will be accessed with decrementing pointers, 
;so offset by 1 because the index range is 8-1 rather than 0-7
NumberData:
    incvr2bpp "res/numbers.1bpp", 80



.ENDS


