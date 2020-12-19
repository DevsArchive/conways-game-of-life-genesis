
; -------------------------------------------------------------------------
;
;	Mega Drive Library
;		By Ralakimus 2018
;
;	File:		md.asm
;	Contents:	Mega Drive base source
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; ASM68K build options
; -------------------------------------------------------------------------

	opt	l.				; Use "." for local labels
	opt	op+				; Optimize to PC relative addressing
	opt	os+				; Optimize short branches
	opt	ow+				; Optimize absolute long addressing
	opt	oz+				; Optimize zero displacements
	opt	oaq+				; Optimize to addq
	opt	osq+				; Optimize to subq
	opt	omq+				; Optimize to moveq
	opt	ae-				; Disable automatic evens

; -------------------------------------------------------------------------
; Mega Drive related includes
; -------------------------------------------------------------------------

	include	"../md/constants.asm"		; Constants
	include	"../md/macros.asm"		; Macros
	include	"../md/ram.asm"			; Engine RAM definitions

; -------------------------------------------------------------------------
; Set an interrupt pointer
; -------------------------------------------------------------------------
; PARAMETERS:
;	ptr	- Routine pointer
; -------------------------------------------------------------------------

setEInt macros &				; EXT-INT
	ptr

	move.l	\ptr,r_ExtInt+2.w

setHInt macros &				; H-INT
	ptr

	move.l	\ptr,r_HInt+2.w

setVInt macros &				; V-INT
	ptr

	move.l	\ptr,r_VInt+2.w

; -------------------------------------------------------------------------
; Reset the EXT-INT to the default routine
; -------------------------------------------------------------------------

resetEInt macros &

	setEInt	#Exception

; -------------------------------------------------------------------------
; Reset the H-INT to the default routine
; -------------------------------------------------------------------------

resetHInt macros &

	setHInt	#Exception

; -------------------------------------------------------------------------
; Reset the V-INT to the default routine
; -------------------------------------------------------------------------

resetVInt macros &

	setVInt	#VInt_Common

; -------------------------------------------------------------------------
; Other includes
; -------------------------------------------------------------------------

	include	"config.asm"			; Configuration

; -------------------------------------------------------------------------
; Vector table
; -------------------------------------------------------------------------

	org	0

	dc.l	r_Stack_Base			; Stack pointer
	dc.l	StartMD				; Entry point

	dc.l	Exception			; Bus error
	dc.l	Exception			; Address error
	dc.l	Exception			; Illegal instruction
	dc.l	Exception			; Division by zero
	dc.l	Exception			; CHK exception
	dc.l	Exception			; TRAPV exception
	dc.l	Exception			; Privilege violation
	dc.l	Exception			; TRACE exception
	dc.l	Exception			; Line A emulator
	dc.l	Exception			; Line F emulator

	dcb.l	$C, Exception			; Reserved

	dc.l	Exception			; Spurious exception
	dc.l	Exception			; Interrupt request level 1
	dc.l	r_ExtInt			; External interrupt
	dc.l	Exception			; Interrupt request level 3
	dc.l	r_HInt				; Horizontal interrupt
	dc.l	Exception			; Interrupt request level 5
	dc.l	VInt				; Vertical interrupt
	dc.l	Exception			; Interrupt request level 7

	dcb.l	$10, Exception			; TRAPs 0-15

	dcb.l	$10, Exception			; Reserved

; -------------------------------------------------------------------------
; Store a string with a character limit for the header with alignment
; (also pads to that limit if it doesn't exceed it)
; -------------------------------------------------------------------------
; PARAMETERS:
;	limit	- Character limit
;	right	- Set to nonzero to align the text to the right
;	string	- The string
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

headStr macro &
	limit, right, string

	local	cutstr
cutstr	substr	1, \limit, \string

	if \right
		dcb.b	\limit-strlen("\cutstr"), " "
		dc.b	"\cutstr"
	else
		dc.b	"\cutstr"
		dcb.b	\limit-strlen("\cutstr"), " "
	endif

	endm

; -------------------------------------------------------------------------
; Header
; -------------------------------------------------------------------------

	dc.b	"SEGA MEGA DRIVE "		; Hardware name
	
	dc.b	"(C)T-IT "			; Company
yr	=	(_year+1900)%10000
mth	substr	1+((_month-1)*3), 3+((_month-1)*3), &
	"JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC"
	headStr	5, 1, "\#yr\."			; Year
	dc.b	"\mth"				; Month

	headStr	$30, 0, "\GAME_NAME"		; Domestic game name
	headStr	$30, 0, "\GAME_NAME"		; Overseas game name

mth	equs	"\#_month"
	if _month<10
mth	equs	"0\#_month"
	endif
day	equs	"\#_day"
	if _day<10
day	equs	"0\#_day"
	endif
hr	equs	"\#_hours"
	if _hours<10
hr	equs	"0\#_hours"
	endif
min	equs	"\#_minutes"
	if _minutes<10
min	equs	"0\#_minutes"
	endif
	dc.b	"GM "				; Game type
	dc.b	"\mth\\day\\hr\\min\-00"	; Game version

	dc.w	0				; Checksum

	headStr	$10, 0, "\IO_SUPPORT"		; Control data

	dc.l	ROM_START, ROM_END-1		; ROM addresses
	dc.l	RAM_START, RAM_END-1		; RAM addresses
	dc.l	SRAM_SUPPORT			; SRAM support
	dc.l	SRAM_START, SRAM_END		; SRAM addresses

	dc.b	"            "			; Modem information
	dc.b	"        "

	headStr	$20, 0, "\NOTES"		; Notes
	headStr	$10, 0, "\REGION"		; Region

	purge	headStr

; -------------------------------------------------------------------------
; General exception routine
; -------------------------------------------------------------------------

Exception:
	rte

; -------------------------------------------------------------------------
; Initialization
; -------------------------------------------------------------------------

MDRegSet:
	; --- Register data ---

	dc.w	$2000-2-1			; d5 - Size of Z80 RAM to clear
	dc.w	$8000				; d6 - VDP register base
	dc.w	$100				; d7 - VDP register increment/Z80 bus request/Z80 reset off

	dc.l	Z80_RAM				; a0 - Z80 RAM
	dc.l	Z80_BUS				; a1 - Z80 bus request
	dc.l	Z80_RESET			; a2 - Z80 reset
	dc.l	VDP_DATA			; a3 - VDP data port
	dc.l	VDP_CTRL			; a4 - VDP control port

	; --- VDP register data ---

	dc.b	%00000100			; Disable H-INT
	dc.b	%00110100			; Enable V-INT, disable display
	dc.b	$C000/$400			; Plane A
	dc.b	$D000/$400			; Window plane
	dc.b	$E000/$2000			; Plane B
	dc.b	$F800/$200			; Sprite table
	dc.b	$00				; Sprite pattern generator
	dc.b	$00				; Background color
	dc.b	$00, $00			; Unused
	dc.b	$FF				; H-INT counter
	dc.b	%00000000			; Scroll by screen
	dc.b	%10000001			; H40 resolution
	dc.b	$FC00/$400			; HScroll table
	dc.b	$00				; Nametable pattern generator
	dc.b	$01				; Autoincrement
	dc.b	$01				; Plane size 64x32
	dc.b	$00, $00			; Disable window
	dc.b	$FF, $FF			; DMA length
	dc.b	$00, $00, $80			; DMA source

	; --- PSG channel volumes ---

	dc.b	$9F, $BF, $DF, $FF		; PSG silence data

; -------------------------------------------------------------------------

StartMD:
	; --- Set up registers ---

	movea.w	0.w,sp				; Set SP
	move	#$2700,sr			; Disable interrupts

	lea	MDRegSet(pc),a5			; Register set table
	movem.w	(a5)+,d5-d7			; d5-d7
	movem.l	(a5)+,a0-a4			; a0-a4

	; --- Do security check ---

	move.b	-$10FF(a1),d0			; Get hardware version
	andi.b	#$F,d0
	beq.s	.ver0				; If it's version 0, branch
	move.l	$100.w,$2F00(a1)		; Enable VDP

.ver0:
	move.w	(a4),d0				; VDP status dummy read
	moveq	#0,d0				; Set D0 to 0
	move.l	d0,a6				; Set SP to 0
	move.l	a6,usp				; Clear user stack pointer

	; --- Initialize VDP registers ---

	moveq	#24-1,d1			; VDP register count

.r_ini1:
	move.b	(a5)+,d6			; Set register data
	move.w	d6,(a4)
	add.w	d7,d6				; Next register
	dbf	d1,.r_ini1

	vdpCmd	move.l,0,VRAM,DMA,(a4)		; DMA fill (clear VRAM)
	move.w	d0,(a3)

	; --- Initialize Z80 ---

	move.w	d7,(a1)				; Request Z80 bus
	move.w	d7,(a2)				; Reset Z80 off

.z801:
	btst	d0,(a1)				; Check bus access
	bne.s	.z801				; Wait until granted

	move.b	#$F3,(a0)+			; DI
	move.b	#$C3,(a0)+			; JP XXXX

.z802:
	move.b	d0,(a0)+			; Clear Z80 RAM
	dbf	d5,.z802

	move.w	d0,(a2)				; Z80 reset on
	move.w	d0,(a1)				; Give bus back to Z80
	move.w	d7,(a2)				; Z80 reset off

	; --- Reset CRAM ---

	move.w	#$8F02,(a4)			; VDP autoincrement 2

	vdpCmd	move.l,0,CRAM,WRITE,(a4)	; CRAM write
	moveq	#$80/4-1,d1			; CRAM size

.c_col1:
	move.l	d0,(a3)				; Clear CRAM
	dbf	d1,.c_col1

	; --- Reset VSRAM ---

	vdpCmd	move.l,0,VSRAM,WRITE,(a4)	; VSRAM write
	moveq	#$50/4-1,d1			; VSRAM size

.c_vsc1:
	move.l	d0,(a3)				; Clear VSRAM
	dbf	d1,.c_vsc1

	; --- Reset PSG ---

	moveq	#4-1,d1				; PSG channel count

.c_psg1:
	move.b	(a5)+,$11(a3)			; Silence PSG
	dbf	d1,.c_psg1

	; --- Wait for DMA to finish ---

	waitDMA	(a4)				; Wait for DMA to finish

	; --- Clear user work RAM ---

	clrRAM	RAM_START, SYS_RAM

	; --- Set up important variables ---

	movem.l	RAM_START,d0-a6			; Clear registers
	clrRAM	SYS_RAM, RAM_END		; Clear system RAM

	move.b	HW_VERSION,r_Sys_Ver.w		; Get hardware version

	move.w	#$4EF9,d0			; JMP opcode
	move.w	d0,r_VInt.w			; Set for V-INT
	move.w	d0,r_HInt.w			; Set for H-INT
	move.w	d0,r_ExtInt.w			; Set for EXT-INT

	resetVInt				; Reset V-INT routine
	resetHInt				; Reset H-INT routine
	resetEInt				; Reset EXT-INT routine

	; --- Misc. initializations ---

	bsr.s	InitCtrls			; Initialize controllers
	bsr.w	ClearScreen			; Clear the screen

	jmp	Main				; Go to main

; -------------------------------------------------------------------------
; Libraries
; -------------------------------------------------------------------------

	include	"../lib/ctrl.asm"		; Controller library
	include	"../lib/vdp.asm"		; VDP library
	include	"../lib/int.asm"		; Interrupt library

; -------------------------------------------------------------------------
; Vertical interrupt
; -------------------------------------------------------------------------

VInt:
	pusha					; Save registers

	intsOff					; Disable interrupts
	
	bsr.w	ReadCtrls			; Read controller data
	
	addq.w	#1,r_Lag_Cnt.w			; Increment lag frame counter
	tst.b	r_VSync.w			; Was the VSync flag set?
	beq.s	.DoRoutine			; If not, branch
	clr.w	r_Lag_Cnt.w			; Clear lag frame counter
	
.DoRoutine:
	jsr	r_VInt.w			; Go to V-INT routine

	clr.b	r_VSync.w			; Clear VSync flag
	addq.l	#1,r_Frame_Cnt.w		; Increment frame counter

	popa					; Restore registers
	rte

; -------------------------------------------------------------------------
; Main program
; -------------------------------------------------------------------------

	include	"main.asm"

; -------------------------------------------------------------------------
