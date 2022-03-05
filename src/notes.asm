.include "defines.asm"

.RAMSECTION "Note RAM" SLOT "RAM"
wCurrentNoteA: db ;bits 0-4 are period, bit 5,6 are instrument, bit 7 is note on
wCurrentNoteB: db
.ENDS


.SECTION "note routine", FREE
ProcessNotes:
    ;check if Note A needs to be adjusted
    ldx wCurrentNoteA
    ; * and # are increment and decrement
    lda #%1 ; mask for #
    bit wPressedKeys
    beq @noDecrement

    txa
    and #%11111 ;isolates the period. Sets Z flag if period is minimum
    beq @noDecrement
    ; decrement period
    dex
    stx wCurrentNoteA
@noDecrement
    lda #%10 ; mask for *
    bit wPressedKeys
    beq @noIncrement

    txa
    and #%11111 ;isolates the period.
    cmp #%11111 ;sets Z flag if period is maximum
    beq @noIncrement
    ; increment period
    inx
    stx wCurrentNoteA
@noIncrement


    ;write the new frequency
    lda wCurrentNoteA
    sta AUDF0
 
    ;check if the note should actually be played
    ldx #0
    lda #%00001011 ;mask for '5','*','#'
    bit wHeldKeys
    beq @noPlay
    ;play the note
    ldx #15 ;max volume
@noPlay
    stx AUDV0



    lda #$c
    sta AUDC0
    rts
.ENDS