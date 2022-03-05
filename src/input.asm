.include "defines.asm"

.RAMSECTION "input RAM" SLOT "RAM"
wPressedKeys: ds 3 ;the format is 123456*# (A) 123456*# (B) 77889900 (A,B)
wHeldKeys: ds 3
wNextKeys: ds 3
.ENDS

.SECTION "input routines", FREE ;since it takes 400us for a row to set, I divide this into four parts, 
;one for each row. they are callen throughout the drawing phase so that the new inputs are ready for blanking code 
ProcessInput1: ;start with the bottom row
    lda INPT4 ; bit 7 contains '#' A
    sta wNextKeys
    lda INPT0 ; bit 7 contains '*' A
    asl
    ror wNextKeys

    lda INPT5 ; bit 7 contains '#' B
    sta wNextKeys+1
    lda INPT2 ; bit 7 contains '*' B
    asl
    ror wNextKeys+1


    lda INPT3 ; bit 7 contains '0' B
    sta wNextKeys+2
    lda INPT1 ; bit 7 contains '0' A
    asl
    ror wNextKeys+2

    ;select the third row
    lda #%10111011
    sta.w SWCHA

    rts

ProcessInput2:
    ;this time, we do the third row
    lda INPT5 ; bit 7 contains '9' B
    asl
    ror wNextKeys+2
    lda INPT4 ; bit 7 contains '9' A
    asl
    ror wNextKeys+2
    lda INPT3 ; bit 7 contains '8' B
    asl
    ror wNextKeys+2
    lda INPT1 ; bit 7 contains '8' A
    asl
    ror wNextKeys+2
    lda INPT2 ; bit 7 contains '7' B
    asl
    ror wNextKeys+2
    lda INPT0 ; bit 7 contains '7' A
    asl
    ror wNextKeys+2

    ;secect the second row
    lda #%11011101
    sta.w SWCHA
    rts

ProcessInput3:
    ;now do the second row
    lda INPT4 ; bit 7 contains '6' A
    asl
    ror wNextKeys
    lda INPT1 ; bit 7 contains '5' A
    asl
    ror wNextKeys
    lda INPT0 ; bit 7 contains '4' A
    asl
    ror wNextKeys

    lda INPT5 ; bit 7 contains '6' B
    asl
    ror wNextKeys+1
    lda INPT3 ; bit 7 contains '5' B
    asl
    ror wNextKeys+1
    lda INPT2 ; bit 7 contains '4' B
    asl
    ror wNextKeys+1

    ;select the first row
    lda #%11101110
    sta.w SWCHA

    rts

ProcessInput4:
    ;now do the first row
    lda INPT4 ; bit 7 contains '3' A
    asl
    ror wNextKeys
    lda INPT1 ; bit 7 contains '2' A
    asl
    ror wNextKeys
    lda INPT0 ; bit 7 contains '1' A
    asl
    ror wNextKeys

    lda INPT5 ; bit 7 contains '3' B
    asl
    ror wNextKeys+1
    lda INPT3 ; bit 7 contains '2' B
    asl
    ror wNextKeys+1
    lda INPT2 ; bit 7 contains '1' B
    asl
    ror wNextKeys+1
    
    ;select the fourth row for next frame
    lda #%01110111
    sta.w SWCHA

    ;these are the new held keys, but they're inverted atm
    ;now we can calculate the new pressed keys by ORing the previous and new (non-inverted) held keys
    ;then we invert that

    ldx #2
@maskloop
    lda wHeldKeys,x
    ora wNextKeys,x
    eor #$ff
    sta wPressedKeys,x
    lda wNextKeys,x
    eor #$ff
    sta wHeldKeys,x
    dex
    bpl @maskloop

    rts
.ENDS