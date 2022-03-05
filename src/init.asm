.include "defines.asm"
.SECTION "init", FREE


; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START
	lda #$ff
	sta.w SWACNT
	lda #%11101110 ;bottom row of both keypads
    sta.w SWCHA


    jmp NextFrame

.ENDS


.orga $fffc
.SECTION "vectors", FORCE
	.word Start
	.word Start
.ENDS