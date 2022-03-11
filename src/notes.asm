.include "defines.asm"

.RAMSECTION "Note RAM" SLOT "RAM"
wCurrentNoteA: db ;bits 0-4 are period, bit 5,6 are instrument, bit 7 is note on
wCurrentNoteB: db
.ENDS

;instruments: 0 = pure div2, 1 = pure div6, 2 = buzzy div15

.enum 0
INTERVALS_UP_OCTAVE: ds $80
INTERVALS_DOWN_OCTAVE: ds $80
INTERVALS_UP_FIFTH: ds $80
INTERVALS_DOWN_FIFTH: ds $80
.ende

.SECTION "note routine", FREE
ProcessNotes:
    ;check if Note A needs to be adjusted
    lda wCurrentNoteA
    and #%01111111
    tax
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

    ; test for up/down octave (keys 1 and 3)
    lda #%10000000 ; mask for 1
    bit wPressedKeys
    beq @noOctaveDown
    ; use table to descend octave
    lda.w (IntervalTables + INTERVALS_DOWN_OCTAVE),x
    sta wCurrentNoteA
@noOctaveDown

    lda #%00100000 ; mask for 3
    bit wPressedKeys
    beq @noOctaveUp
    ; use table to ascend octave
    lda.w (IntervalTables + INTERVALS_UP_OCTAVE),x
    sta wCurrentNoteA
@noOctaveUp

    ; test for up/down fifth (keys 4 and 6)
    lda #%00010000 ; mask for 4
    bit wPressedKeys
    beq @noFifthDown
    ; use table to descend fifth
    lda.w (IntervalTables + INTERVALS_DOWN_FIFTH),x
    sta wCurrentNoteA
@noFifthDown

    lda #%00000100 ; mask for 6
    bit wPressedKeys
    beq @noFifthUp
    ; use table to ascend fifth
    lda.w (IntervalTables + INTERVALS_UP_FIFTH),x
    sta wCurrentNoteA
@noFifthUp


    ;write the new frequency
    lda wCurrentNoteA
    sta AUDF0

    ;isolate the instrument
    rol
    rol
    rol
    rol
    and #%11
    tax
    lda.w InstrumentTable,x
    sta AUDC0

 
    ;check if the note should actually be played
    ldx #0
    lda #%10111111 ;mask for 1 3 4 6 5 * #
    bit wHeldKeys
    beq @noPlay
    ;play the note
    ldx #15 ;max volume
@noPlay
    stx AUDV0


    rts
.ENDS

.SECTION "instrument table", FREE, ALIGN 4
InstrumentTable:
    .db $4, $c, $1, $6
.ENDS

.SECTION "interval tables", FREE, ALIGN 128
IntervalTables:
.INCBIN	"res/intervaltables.bin"
.ENDS
