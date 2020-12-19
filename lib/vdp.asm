
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
; Clear the screen
; -------------------------------------------------------------------------

ClearScreen:
	lea	VDP_CTRL,a0
	move.w	#$8F01,(a0)			; Set autoincrement to 1
	dmaFill	0,$A000,$6000,(a0),-4(a0)	; Clear planes, sprites, and HScroll
	move.w	#$8F02,(a0)			; Set autoincrement to 2

	clrRAM	r_HScrl, r_VScrl_End		; Clear scroll RAM
	rts

; -------------------------------------------------------------------------
