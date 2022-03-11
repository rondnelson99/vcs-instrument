.include "defines.asm"

.RAMSECTION "Note RAM" SLOT "RAM"
wRootA: db
wCurrentNoteA: db ;bits 0-4 are period, bit 5,6 are instrument, bit 7 is note on
wCurrentNoteB: db
.ENDS

;instruments: 0 = pure div2, 1 = pure div6, 2 = buzzy div15

.enum 0
INTERVALS_OCTAVE ds $100
INTERVALS_MAJOR_SEVENTH ds $100
INTERVALS_MAJOR_SIXTH ds $100
INTERVALS_MINOR_SIXTH ds $100
INTERVALS_FIFTH ds $100
INTERVALS_FOURTH ds $100
INTERVALS_MAJOR_THIRD ds $100
INTERVALS_MINOR_THIRD ds $100
INTERVALS_MAJOR_SECOND ds $100
.ende

.SECTION "note routine", FREE
ProcessNotes:
    ; process note A
    lda wRootA
    and #%01111111
    tax
    /*; * and # are increment and decrement
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
    */

    ; test for octave (key 3)
    lda #%00100000 ; mask for 1
    bit wPressedKeys
    beq @noOctave
    ; use table to ascend octave
    lda.w (IntervalTables + INTERVALS_OCTAVE),x
    sta wCurrentNoteA
@noOctave

    ; test for major seventh (key 2)
    lda #%01000000 ; mask for 2
    bit wPressedKeys
    beq @noMajorSeventh
    ; use table to ascend major seventh
    lda.w (IntervalTables + INTERVALS_MAJOR_SEVENTH),x
    sta wCurrentNoteA
@noMajorSeventh

    ; test for major sixth (key 1)
    lda #%10000000 ; mask for 1
    bit wPressedKeys
    beq @noMajorSixth
    ; use table to ascend major sixth
    lda.w (IntervalTables + INTERVALS_MAJOR_SIXTH),x
    sta wCurrentNoteA
@noMajorSixth

    ; test for fifth (key 5)
    lda #%00001000 ; mask for 5
    bit wPressedKeys
    beq @noFifth
    ; use table to ascend fifth
    lda.w (IntervalTables + INTERVALS_FIFTH),x
    sta wCurrentNoteA
@noFifth

    ; test for fourth (key 4)
    lda #%00010000 ; mask for 4
    bit wPressedKeys
    beq @noFourth
    ; use table to ascend fourth
    lda.w (IntervalTables + INTERVALS_FOURTH),x
    sta wCurrentNoteA
@noFourth

    ; test for major third (key 8)
    lda #%00100000 ; mask for 8 A
    bit wPressedKeys + 2
    beq @noMajorThird
    ; use table to ascend major third
    lda.w (IntervalTables + INTERVALS_MAJOR_THIRD),x
    sta wCurrentNoteA
@noMajorThird

    ; test for minor third (key 7)
    lda #%10000000 ; mask for 7
    bit wPressedKeys + 2
    beq @noMinorThird
    ; use table to ascend minor third
    lda.w (IntervalTables + INTERVALS_MINOR_THIRD),x
    sta wCurrentNoteA
@noMinorThird

    ; test for major second (key *)
    lda #%00000010 ; mask for *
    bit wPressedKeys 
    beq @noMajorSecond
    ; use table to ascend major second
    lda.w (IntervalTables + INTERVALS_MAJOR_SECOND),x
    sta wCurrentNoteA
@noMajorSecond

    ; test for root (key 0)
    lda #%00000010 ; mask for 0 A
    bit wPressedKeys + 2
    beq @noRoot
    stx wCurrentNoteA
@noRoot

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
    ldx #15 ; max volume
    lda #%11111010 ;mask for 1 2 3 4 5 *
    bit wHeldKeys
    bne @Play
    lda #%10100010 ;mask for 7 8 0
    bit wHeldKeys + 2
    bne  @Play
    ;play the note
    ldx #0 ;mute
@Play
    stx AUDV0


    rts
.ENDS

.SECTION "instrument table", FREE, ALIGN 4
InstrumentTable:
    .db $4, $c, $1, $6
.ENDS

.SECTION "interval tables", FREE, ALIGN 256
IntervalTables:
.INCBIN	"res/intervaltables.bin"
.ENDS
