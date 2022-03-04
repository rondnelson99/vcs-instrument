.include "defines.asm"
.SECTION "init", FREE


; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START



    jmp NextFrame

.ENDS


.orga $fffc
.SECTION "vectors", FORCE
	.word Start
	.word Start
.ENDS