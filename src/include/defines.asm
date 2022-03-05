.MEMORYMAP
	DEFAULTSLOT 0
	SLOT 0 START $F000 SIZE $1000 NAME "ROM"
	SLOT 1 START $80 SIZE $80 NAME "RAM"
.ENDME

.ROMBANKSIZE $1000
.ROMBANKS 1

.include "vcs.inc"
.include "macro.inc"

.MACRO incv2bpp ARGS FILE WIDTH ;include a 2bpp row-major image, but convert to column-major
	.fopen FILE HANDLE
	.fsize HANDLE SIZE
	.REPT WIDTH/8 INDEX X
		.REPT SIZE/(WIDTH/8) INDEX Y
			.fseek HANDLE (WIDTH/8*Y)+X START
			.ftell HANDLE LOC
			.printv LOC
			.print "\n"
			.fread HANDLE DATA 
			.db DATA
		.ENDR
	.ENDR
.ENDM

.MACRO incvr2bpp ARGS FILE WIDTH ;same as above but also store each character backwards
	.incbin FILE READ 0 FSIZE SIZE
	.redef HEIGHT SIZE/(WIDTH/8)
	.REPT WIDTH/8 INDEX X
		.REPT HEIGHT INDEX Y
			.incbin FILE SKIP SIZE-(WIDTH/8*(Y+1))+X READ 1
		.ENDR
	.ENDR
.ENDM

.MACRO bitReverse ;reverse the order of bits in the byte
	.redef _out 0
	.rept 8 INDEX i
		.redef _out (_out>>1)|((\1<<i)&$80)
	.endr
.ENDM

.MACRO lax_ind_y
	.db $b3
	.db \1
.endm


