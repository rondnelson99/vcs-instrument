.include "defines.asm"

.RAMSECTION "Note RAM" SLOT "RAM"
wCurrentNoteA: db ;bits 0-4 are period, bit 5,6 are instrument, bit 7 is note on
wCurrentNoteB: db
.ENDS

;instruments: 0 = pure div2, 1 = pure div6, 2 = buzzy div15


/*.MACRO IntervalNote ARGS oldnote intervalMul intervalDiv ;oldnote is in wCurrentNote format, 
    ;interval is a fraction where 2/3 = *up* a fifth. Supply the numerator and denominator as integers.
    
    ;first, check if the interval can be made using the current instrument
    ; isolate the frequency of the old note

    ;bit 7 indicates that the ratio can be formed perfectly



    .redef oldfreq (oldnote & %11111) + 1

    .print "trying to generate interval from oldfreq ", oldfreq, "\n"

    .redef newfreq (oldfreq * intervalMul / intervalDiv)

    .print "with the current instrument, the newfreq would be ", newfreq, "\n"

    .if ((oldfreq * intervalMul # intervalDiv == 0) && (newfreq <= 32))
        .print "the newfreq is valid, so use that\n\n"

        ; if so, we can use the current instrument
        .db (oldnote & %01100000) + (newfreq - 1) + %10000000
    .else
        .print "the interval does not work with the current instrument \n"
        ;if not, then we check the other instruments one by one until we find a perfect match
        .redef oldinst (oldnote >> 5 | %11)
        ; convert newfreq a multiple of the fundamental 30khz
        .if oldinst == 0 ;pure div2
            .print oldfreq, intervalMul, intervalDiv, "\n"
            .redef newfreq ((oldfreq * intervalMul / intervalDiv) * 2)
        .elif oldinst == 1 ;pure div6
            .redef newfreq ((oldfreq * intervalMul / intervalDiv) * 6)
        .elif oldinst == 2 ;buzzy div15
            .redef newfreq ((oldfreq * intervalMul / intervalDiv) * 15)
        .endif

        .print "the frequency is 30khz / ", newfreq, "\n"

        ;now try each instrument one by one until we find a perfect match
        .if (newfreq # 2 == 0) && (newfreq / 2 <= 32)
            .print "match found for div2\n\n"
            .db (newfreq / 2 - 1) + %10000000
        .elif (newfreq # 6 == 0) && (newfreq / 6 <= 32)
            .print "match found for div6\n\n"
            .db (newfreq / 6 - 1) + %10100000
        .elif (newfreq # 15 == 0) && (newfreq / 15 <= 32)
            .print "match found for div15\n\n"
            .db (oldfreq / 15 - 1) + %11000000
        .else
            .print "no match found\n"
            .print "finding best approximation\n"
            ; in tis case, there is no perfect match, so we find the closest one with all instruments
            ; find the closest div2
            .redef bestfreq $ee ;default
            .redef error 99999
            .if (newfreq / 2 <= 32)
                .redef bestfreq (newfreq / 2 + 0.5) & %11111
                .redef error newfreq / 2 - bestfreq
                .redef bestinst 0
            .endif
            .if (newfreq / 6 <= 32)
                .redef possiblebestfreq (newfreq / 6 + 0.5)  & %11111
                .redef possibleerror (newfreq / 6 - bestfreq)
                .if possibleerror < error
                    .redef bestfreq possiblebestfreq
                    .redef error possibleerror
                    .redef bestinst 1
                .endif
            .endif
            .if (newfreq / 15 <= 32)
                .redef possiblebestfreq (newfreq / 15 + 0.5) & %11111
                .redef possibleerror newfreq / 15 - bestfreq
                .if (possibleerror < error)
                    .redef bestfreq possiblebestfreq
                    .redef error possibleerror
                    .redef bestinst 2
                .endif
            .endif

            .print "bestfreq is ", bestfreq, "\n"
            .print "bestinst is ", bestinst, "\n\n"
            ; now write the byte representing the compromised note
            ;.db bestinst << 5 + bestfreq - 1
        .endif
    .endif 
.ENDM
*/

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



    lda #$6
    sta AUDC0
    rts
.ENDS

.SECTION "interval tables", FREE, ALIGN 128
IntervalTables:
.INCBIN	"res/intervaltables.bin"
.ENDS
