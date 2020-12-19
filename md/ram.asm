
; -------------------------------------------------------------------------
;
;	Mega Drive Library
;		By Ralakimus 2018
;
;	File:		ram.asm
;	Contents:	Engine RAM definitions
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Global engine RAM
; We define everything backwards because it's to be defined
; at the end of work RAM
; -------------------------------------------------------------------------

	rsreset

	; Stack

r_Stack_Base	rs.b	-$100			; Stack
r_Stack		rs.b	0

	; Misc. variables

		rs.w	-1
r_Sys_Ver	rs.b	0			; System version

	; Interrupt data

		rs.b	-6
r_VInt		rs.b	-6			; Vertical interrupt
r_HInt		rs.b	-6			; Horizontal interrupt
r_ExtInt	rs.b	0			; External interrupt

		rs.l	-1
r_Frame_Cnt	rs.w	-1			; Frame count
r_Lag_Cnt	rs.b	-1			; Lag frame count
r_VSync		rs.b	0			; VSync flag

	; Controller data

		rs.b	-1	
r_Ctrl_Chg	rs.b	-1			; Poll controller change flag (nonzero to enable)
r_P2_State	rs.b	-1			; P2 controller state (0 = 3-button, $FF = 6-button)
r_P1_State	rs.b	0			; P1 controller state (0 = 3-button, $FF = 6-button)
r_Ctrl_States	rs.w	-1			; Controller states
r_P2_Press	rs.w	-1			; P2 pressed controller data
r_P2_Hold	rs.b	0			; P2 held controller data
r_P2_Ctrl	rs.w	-1			; P2 controller data
r_P1_Press	rs.w	-1			; P1 pressed controller data
r_P1_Hold	rs.b	0			; P1 held controller data
r_P1_Ctrl	rs.b	0			; P1 controller data
r_Ctrl		rs.b	0			; Controller data

	; VDP buffers

r_Sprites_End	rs.b	-$280
r_Sprites	rs.b	0			; Sprite data buffer

		rs.b	-$80
r_Palette	rs.b	0			; Palette buffer

r_VScrl_End	rs.b	-$50
r_VScrl		rs.b	0			; VScroll buffer
r_VScrl_FG	EQU	r_VScrl			; VScroll FG value
r_VScrl_BG	EQU	r_VScrl+2		; VScroll BG value

r_HScrl_End	rs.b	-$380
r_HScrl		rs.b	0			; HScroll buffer
r_HScrl_FG	EQU	r_HScrl			; HScroll FG value
r_HScrl_BG	EQU	r_HScrl+2		; HScroll BG value

SYS_RAM		equ	__rs&$FFFFFF		; Start of system RAM

	if r_Stack_Base<>0
		inform 3,"Base of stack MUST be 0"
	endif

; -------------------------------------------------------------------------
