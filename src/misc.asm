.include "defines.asm"

.slot "RAM"
.orga $80
.RAMSECTION "scratchpad" SLOT "RAM" FORCE
wScratchpad: ds 10
.ENDS
