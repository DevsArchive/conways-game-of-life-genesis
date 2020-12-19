
; -------------------------------------------------------------------------
;
;	Conway's Game of Life On Sega Genesis
;		By Ralakimus 2018
;
;	File:		main.asm
;	Contents:	Main source
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; RAM
; -------------------------------------------------------------------------

	rsset RAM_START+$FF000200

	; Maps

r_Map		rs.b	$4000			; Current map
r_Map_Modify	rs.b	$4000			; Modified map

	; Variables

r_Cur_X		rs.w	1			; Cursor X
r_Cur_Y		rs.w	1			; Cursor Y
r_Move_Timers	rs.b	2			; Movement timers

r_Update_Map	rs.b	1			; Update map flag
r_Mode		rs.b	1			; Edit mode
r_Delay		rs.b	1			; Delay timer

; -------------------------------------------------------------------------

CUR_MOVE	EQU	8-1			; Cursor move timer

; -------------------------------------------------------------------------
; V-INT routine
; -------------------------------------------------------------------------

VInt_Normal:
	tst.b	r_Mode.w			; Draw mode?
	bne.s	.GameOfLife			; If not, branch

	move.b	r_P1_Press+1.w,d0		; Check for movement timer reset
	move.b	d0,d1
	andi.b	#3,d1
	beq.s	.ChkLR
	clr.b	r_Move_Timers.w

.ChkLR:
	andi.b	#$C,d0
	beq.s	.NoTimerReset
	clr.b	r_Move_Timers+1.w

.NoTimerReset:
	bsr.w	MoveCursor			; Draw the cursor
	bsr.w	DrawTile			; Draw tiles
	bra.s	.Cont

.GameOfLife:
	bsr.w	DrawCursor			; Draw cursor

.Cont:
	tst.b	r_P1_Press+1.w			; Was the start button pressed?
	bpl.s	.NoStart			; If not, branch
	not.b	r_Mode.w			; Switch modes
	clr.b	r_Delay.w			; Reset delay timer

.NoStart:
	dma68k	r_Sprites,$F800,$280,VRAM	; Transfer sprites
	rts

; -------------------------------------------------------------------------
; V-INT routine with no graphical functions
; -------------------------------------------------------------------------

VInt_NoGfxUpdate:
	tst.b	r_P1_Press+1.w			; Was the start button pressed?
	bpl.s	.NoStart			; If not, branch
	not.b	r_Mode.w			; Switch modes
	clr.b	r_Delay.w			; Reset delay timer

.NoStart:
	rts

; -------------------------------------------------------------------------
; Main
; -------------------------------------------------------------------------

Main:
	intsOff					; Disable interrupts
	setVInt	#VInt_Normal			; Set V-INT routine
	
	lea	VDP_CTRL,a1
	move.w	#$8400|($A000/$2000),(a1)	; Plane B at $A000
	move.w	#$8134,(a1)			; Disable display
	move.w	#$9003,(a1)			; 128x32 plane

	lea	Pal_Map,a0			; Load palette
	move.l	#$C0000000,(a1)
	move.l	(a0)+,-4(a1)
	move.w	(a0),-4(a1)

	lea	Art_Tiles,a0			; Load tiles
	move.l	#$40200000,(a1)
	rept	$40/4
		move.l	(a0)+,-4(a1)
	endr

	bsr.w	MoveCursor			; Draw the cursor

	move.w	#$8174,(a1)			; Enable display

; -------------------------------------------------------------------------

MainLoop:
	bsr.w	VSync				; VSync

	tst.b	r_Mode.w			; Are we in draw mode?
	beq.s	.DrawMap			; If so, branch
	bsr.w	ChkNeighbors			; Check neighbors

.DrawMap:
	bsr.w	VSync				; VSync

	tst.b	r_Update_Map.w			; Should we update the map?
	beq.s	MainLoop			; If not, branch

	clr.b	r_Update_Map.w			; Clear map updae flag
	intsOff					; Disable V-INT graphical functions
	setVInt	#VInt_NoGfxUpdate
	intsOn

	dma68k	r_Map,$C000,$2000,VRAM		; Copy map to VRAM

	intsOff					; Enable V-INT graphical functions
	setVInt	#VInt_Normal
	intsOn

	bra.s	MainLoop			; Loop

; -------------------------------------------------------------------------
; Handle movement of the cursor
; -------------------------------------------------------------------------

MoveCursor:
	btst	#JbU,r_P1_Hold+1.w		; Was up pressed?
	beq.s	.ChkDown			; If not, branch

	subq.b	#1,r_Move_Timers.w		; Decrement move timer
	bpl.s	.ChkDown			; If it hasn't run out, branch
	move.b	#CUR_MOVE,r_Move_Timers.w	; Reset it
	tst.w	r_Cur_Y.w			; Are we already at the top?
	beq.s	.ChkDown			; If so, branch
	subq.w	#1,r_Cur_Y.w			; Go up

.ChkDown:
	btst	#JbD,r_P1_Hold+1.w		; Was down pressed?
	beq.s	.ChkLeft			; If not, branch

	subq.b	#1,r_Move_Timers.w		; Decrement move timer
	bpl.s	.ChkLeft			; If it hasn't run out, branch
	move.b	#CUR_MOVE,r_Move_Timers.w	; Reset it
	cmpi.w	#27,r_Cur_Y.w			; Are we already at the bottom?
	beq.s	.ChkLeft			; If so, branch
	addq.w	#1,r_Cur_Y.w			; Go down

.ChkLeft:
	btst	#JbL,r_P1_Hold+1.w		; Was left pressed?
	beq.s	.ChkRight			; If not, branch

	subq.b	#1,r_Move_Timers+1.w		; Decrement move timer
	bpl.s	.ChkRight			; If it hasn't run out, branch
	move.b	#CUR_MOVE,r_Move_Timers+1.w	; Reset it
	tst.w	r_Cur_X.w			; Are we already at the left?
	beq.s	.ChkRight			; If so, branch
	subq.w	#1,r_Cur_X.w			; Go left

.ChkRight:
	btst	#JbR,r_P1_Hold+1.w		; Was right pressed?
	beq.s	DrawCursor			; If not, branch

	subq.b	#1,r_Move_Timers+1.w		; Decrement move timer
	bpl.s	DrawCursor			; If it hasn't run out, branch
	move.b	#CUR_MOVE,r_Move_Timers+1.w	; Reset it
	cmpi.w	#39,r_Cur_X.w			; Are we already at the right?
	beq.s	DrawCursor			; If so, branch
	addq.w	#1,r_Cur_X.w			; Go right

; -------------------------------------------------------------------------
; Draw the cursor
; -------------------------------------------------------------------------

DrawCursor:
	lea	r_Sprites.w,a0			; Sprite buffer
	move.w	r_Cur_Y.w,d0			; Cursor Y
	lsl.w	#3,d0
	addi.w	#128,d0
	move.w	d0,(a0)+
	clr.b	(a0)+				; Size
	addq.w	#1,a0				; Skip link data
	move.w	#$8002,(a0)+			; Base tile
	tst.b	r_Mode.w			; Are we in draw mode?
	beq.s	.SetX				; If so, branch
	clr.w	-2(a0)				; Make sprite invisible

.SetX:
	move.w	r_Cur_X.w,d0			; Cursor X
	lsl.w	#3,d0
	addi.w	#128,d0
	move.w	d0,(a0)
	rts

; -------------------------------------------------------------------------
; Handle tile drawing
; -------------------------------------------------------------------------

DrawTile:
	btst	#JbC,r_P1_Press+1.w		; Was C pressed?
	beq.w	.ChkA				; If not, branch

	lea	r_Map,a0			; Clear the entire map
	lea	r_Map_Modify,a1
	move.w	#$2000/4,d0

.ClearMap:
	clr.l	(a0)+
	clr.l	(a1)+
	dbf	d0,.ClearMap

	st	r_Update_Map.w
	rts

.ChkA:
	btst	#JbA,r_P1_Press+1.w		; Was A pressed?
	beq.s	.End				; If not, branch

	lea	r_Map,a0			; Modify the current tile
	lea	r_Map_Modify,a1
	move.w	r_Cur_Y.w,d0			; Get offset in map from cursor
	lsl.w	#8,d0
	move.w	r_Cur_X.w,d1
	add.w	d1,d1
	add.w	d1,d0
	adda.w	d0,a0				; Add offset to map
	adda.w	d0,a1
	st	r_Update_Map.w			; Set to update the map
	eori.w	#1,(a0)				; Draw or clear tile
	eori.w	#1,(a1)

.End:
	rts

; -------------------------------------------------------------------------
; Check a tiles neighbors and affect the tile depending on
; the neighbor count
; -------------------------------------------------------------------------

ChkNeighbors:
	subq.b	#1,r_Delay.w			; Decrement delay timer
	bmi.s	.Update				; If it has run out, branch
	rts

.Update:
	move.b	#1,r_Delay.w			; Reset delay timer
	st	r_Update_Map.w			; Set to update the map

	lea	r_Map,a0			; Current map
	lea	r_Map_Modify,a2			; Modified map

	moveq	#28-1,d0			; Number of rows

.ChkRow:
	movea.l	a0,a1				; Copy map pointer
	movea.l	a2,a3

	moveq	#40-1,d1			; Number of tiles per row

.ChkTile:
	moveq	#0,d7				; Get neighbord count
	add.w	-$100-2(a1),d7			; Add in top left tile
	add.w	-$100+0(a1),d7			; Add in top middle tile
	add.w	-$100+2(a1),d7			; Add in top right tile
	add.w	$100-2(a1),d7			; Add in bottom left tile
	add.w	$100+0(a1),d7			; Add in bottom middle tile
	add.w	$100+2(a1),d7			; Add in bottom right tile
	add.w	-2(a1),d7			; Add in middle left tile
	add.w	2(a1),d7			; Add in middle right tile

	tst.w	(a1)				; Is this tile alive?
	beq.s	.ChkRevive			; If not, branch
	cmpi.w	#2,d7				; Does this tile have less than 2 neighbors?
	blo.s	.Die				; If so, branch
	cmpi.w	#3,d7				; Does this tile have more than 3 neighbors?
	bls.s	.ChkNext			; If not, branch

.Die:
	clr.w	(a3)				; Die
	bra.s	.ChkNext			; Continue

.ChkRevive:
	cmpi.w	#3,d7				; Does this tile have 3 neighbors?
	bne.s	.ChkNext			; If not, branch
	move.w	#1,(a3)				; Revive

.ChkNext:
	addq.w	#2,a1				; Next tile
	addq.w	#2,a3
	dbf	d1,.ChkTile			; Loop until finished

	adda.w	#$100,a0			; Next row
	adda.w	#$100,a2
	dbf	d0,.ChkRow			; Loop until finished

	lea	r_Map,a0			; Copy the modifed map over to the current map
	lea	r_Map_Modify,a2
	move.w	#$2000/4,d0

.CopyMap:
	move.l	(a2)+,(a0)+
	dbf	d0,.CopyMap

	rts

; -------------------------------------------------------------------------
; Data
; -------------------------------------------------------------------------

Art_Tiles:
	dc.l	$11111111			; "Alive" tile
	dc.l	$11111111
	dc.l	$11111111
	dc.l	$11111111
	dc.l	$11111111
	dc.l	$11111111
	dc.l	$11111111
	dc.l	$11111111

	dc.l	$20202020			; Cursor
	dc.l	$02020202
	dc.l	$20202020
	dc.l	$02020202
	dc.l	$20202020
	dc.l	$02020202
	dc.l	$20202020
	dc.l	$02020202

Pal_Map:					; Color palette
	dc.w	$EEE, $000, $888
Pal_Map_End:

; -------------------------------------------------------------------------
