.include "defines.asm"
.SECTION "main loop", FREE






NextFrame

	

	;start a timer to wait until VSYNC time
	;thats such a long time that we have to use the 1024 divider. 
	;Because of that inaccuracy, we'll shorten the VBLANK time by a few scanlines
	lda #17
	sta.w T1024T ;start the timer
	; the timer will last 17 * 1024 cycles / 76 cycles/scanline = 229.05 scanlines
	sta WSYNC	
	;this spot here is the start of the drawing phase
	
	jsr RenderScreen

FinishFrame
	lda #%10 ;enable blanking
	sta VBLANK
@waitTimer
	sta WSYNC
	lda #%10
	;check if the timer has expired. When it has, then it's time for VSYNC.
	bit.w TIMINT ; N flag will be set if the timer has expired
	bpl @waitTimer
	sta WSYNC
@vsync 
	sta VSYNC
	sta WSYNC
	sta WSYNC
	sta WSYNC ;3 scanlines of VSYNC
	lda #0
	sta VSYNC
	;with our modified timings, we now need only 27 lines of VBLANK
	;to have 262 total lines
	lda #32
	sta.w TIM64T ;this will last 32 * 64 cycles / 76 cycles/scanline = 26.9 scanlines


	;now we need to wait for the timer to expire
FinishFrontPorch
	lda #0
	; check if the timer has expired. When it has, then we can start drawing
@waitTimer
	sta WSYNC
	bit.w TIMINT ; N flag will be set if the timer has expired
	bpl @waitTimer
	;go back to the top and start drawing!
	jmp NextFrame










.ENDS
