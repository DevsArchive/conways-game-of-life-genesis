
; -------------------------------------------------------------------------
;
;	Mega Drive Library
;		By Ralakimus 2018
;
;	File:		vdp.asm
;	Contents:	VDP library
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Perform VSync
; -------------------------------------------------------------------------

VSync:
	intsOn					; Enable interrupts
	tst.b	r_VSync.w			; Was the VSync flag already set?
	bne.s	.Wait				; If so, branch
	st	r_VSync.w			; Set VSync flag

.Wait:
	tst.b	r_VSync.w			; Has the V-INT run yet?
	bne.s	.Wait				; If not, wait
	rts

; -------------------------------------------------------------------------
; Do common V-INT updates
; -------------------------------------------------------------------------

VInt_Common:
	lea	VDP_CTRL,a0			; VDP control port
	dma68k	r_Palette,0,$80,CRAM,(a0)	; Transfer palette data
	dma68k	r_HScrl,$FC00,$380,VRAM,(a0)	; Transfer HScroll data
	dma68k	r_VScrl,0,$50,VSRAM,(a0)	; Transfer VScroll data
	dma68k	r_Sprites,$F800,$280,VRAM,(a0)	; Transfer sprites

	rts

; -------------------------------------------------------------------------
