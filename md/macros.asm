
; -------------------------------------------------------------------------
;
;	Mega Drive Library
;		By Ralakimus 2018
;
;	File:		macros.asm
;	Contents:	Macros for the 68000
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Align
; -------------------------------------------------------------------------
; PARAMETERS:
;	bound	- Size boundary
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

align macros &
	bound
	
	cnop	0,\bound

; -------------------------------------------------------------------------
; Push all registers to the stack
; -------------------------------------------------------------------------

pusha macros &

	movem.l	d0-a6,-(sp)

; -------------------------------------------------------------------------
; Pop all registers from the stack
; -------------------------------------------------------------------------

popa macros &

	movem.l	(sp)+,d0-a6

; -------------------------------------------------------------------------
; Pad RS to even address
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

rsEven macros &
	
	rs.b	__rs&1

; -------------------------------------------------------------------------
; Clear a section of memory
; -------------------------------------------------------------------------
; PARAMETERS:
;	saddr	- Address to start clearing memory at
;	eaddr	- Address to finish clearing memory at
;		  (not required if [saddr]_end exists)
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

clrRAM macro &
	saddr, eaddr
	
	local	endaddr
	if narg<2
endaddr		EQUS	"\saddr\_end"		; Use [saddr]_end
	else
endaddr		EQUS	"\eaddr"		; Use eaddr
	endif

	moveq	#0,d0

	if (((\saddr)&$8000)&((\saddr)<0))=0	; Optimise setting saddr to a1
		lea	\saddr,a1
	else
		lea	(\saddr).w,a1
	endif

	move.w	#((\endaddr)-(\saddr))>>2-1,d1	; Size of data in longwords

.Clear\@:
	move.l	d0,(a1)+			; Clear data
	dbf	d1,.Clear\@

	if ((\endaddr)-(\saddr))&2
		move.w	d0,(a1)+		; Clear remaining word of data
	endif
	if ((\endaddr)-(\saddr))&1
		move.b	d0,(a1)+		; Clear remaining byte of data
	endif

	endm

; -------------------------------------------------------------------------
; Disable SRAM access
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

sramOff macros &

	move.b	#0,SRAM_ACCESS			; Disable SRAM access

; -------------------------------------------------------------------------
; Enable SRAM access
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

sramOn macros &

	move.b	#1,SRAM_ACCESS			; Enable SRAM access

; -------------------------------------------------------------------------
; Disable interrupts
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

intsOff macros &

	move	#$2700,sr			; Disable interrupts

; -------------------------------------------------------------------------
; Enable interrupts
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

intsOn macros &

	move	#$2300,sr			; Enable interrupts

; -------------------------------------------------------------------------
; Stop the Z80
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

doZ80Stop macros &

	move.w	#$100,Z80_BUS			; Send stop command to Z80

; -------------------------------------------------------------------------
; Wait for the Z80 to stop
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

waitZ80 macro &

.Wait\@:
	btst	#0,Z80_BUS			; Has the Z80 stopped?
	bne.s	.Wait\@				; If not, branch

	endm

; -------------------------------------------------------------------------
; Stop the Z80 and wait for it to
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

stopZ80 macro &

	doZ80Stop				; Send Z80 stop command
	waitZ80					; Wait for Z80 stop

	endm

; -------------------------------------------------------------------------
; Start the Z80
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

startZ80 macros &

	move.w	#0,Z80_BUS			; Send start command to Z80

; -------------------------------------------------------------------------
; Cancel Z80 reset
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

resetZ80Off macros &

	move.w	#$100,Z80_RESET			; Cancel Z80 reset

; -------------------------------------------------------------------------
; Reset the Z80
; -------------------------------------------------------------------------
; PARAMETERS:
;	Nothing
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

resetZ80 macro &

	move.w	#0,Z80_RESET			; Reset the Z80
	moveq	#$80-1,d1			; Wait
	dbf	d1,*

	endm

; -------------------------------------------------------------------------
; Wait for DMA finish
; -------------------------------------------------------------------------
; PARAMETERS:
;	port	- VDP control port (default is VDP_CTRL)
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------	

waitDMA macro &
	port

.Wait\@:
	if narg>0
		move.w	\port,ccr	; Get VDP status
	else
		move.w	VDP_CTRL,ccr	; Get VDP status
	endif
	bvs.s	.Wait\@			; If there's a DMA, wait

	endm

; -------------------------------------------------------------------------
; VDP command instruction
; -------------------------------------------------------------------------
; PARAMETERS:
;	addr	- Address in VDP memory
;	type	- Type of VDP memory
;	rwd	- VDP command
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

VRAM		EQU	%100001		; VRAM
CRAM		EQU	%101011		; CRAM
VSRAM		EQU	%100101		; VSRAM
READ		EQU	%001100		; VDP read
WRITE		EQU	%000111		; VDP write
DMA		EQU	%100111		; VDP DMA

; -------------------------------------------------------------------------

vdpCmd macro &
	ins, addr, type, rwd, end, end2
	
	if narg=5
		\ins	#((((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14)), \end
	elseif narg>=6
		\ins	#((((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14))\end, \end2
	else
		\ins	((((\type&\rwd)&3)<<30)|((\addr&$3FFF)<<16)|(((\type&\rwd)&$FC)<<2)|((\addr&$C000)>>14))
	endif

	endm

; -------------------------------------------------------------------------
; VDP DMA from 68000 memory to VDP memory
; -------------------------------------------------------------------------
; PARAMETERS:
;	src	- Source address in 68000 memory
;	dest	- Destination address in VDP memory
;	len	- Length of data in bytes
;	type	- Type of VDP memory
;	port	- Representation of VDP control port
;		  (If left blank, this just uses the address instead)
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

dma68k macro &
	src, dest, len, type, port

	if narg>4
		move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),\port
		move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),\port
		move.w	#$9700|(((\src)>>17)&$7F),\port
		vdpCmd	move.w,\dest,\type,DMA,>>16,\port
		vdpCmd	move.w,\dest,\type,DMA,&$FFFF,-(sp)
		move.w	(sp)+,\port
	else
		move.l	#$94009300|((((\len)/2)&$FF00)<<8)|(((\len)/2)&$FF),VDP_CTRL
		move.l	#$96009500|((((\src)/2)&$FF00)<<8)|(((\src)/2)&$FF),VDP_CTRL
		move.w	#$9700|(((\src)>>17)&$7F),VDP_CTRL
		vdpCmd	move.w,\dest,\type,DMA,>>16,VDP_CTRL
		vdpCmd	move.w,\dest,\type,DMA,&$FFFF,-(sp)
		move.w	(sp)+,VDP_CTRL
	endif

	endm

; -------------------------------------------------------------------------
; Fill VRAM with byte
; Auto-increment should be set to 1 beforehand
; -------------------------------------------------------------------------
; PARAMETERS:
;	byte	- Byte to fill VRAM with
;	addr	- Address in VRAM
;	len	- Length of fill in bytes
;	ctrl	- Representation of VDP control port
;		  (If left blank, this just uses the address instead)
;	dat	- Representation of VDP data port
;		  (If left blank, this just uses the address instead)
;	(Both ctrl and dat must either be defined or left blank)
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

dmaFill macro &
	byte, addr, len, ctrl, dat

	if narg>3
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),\ctrl
		move.w	#$9780,\ctrl
		move.l	#$40000080|(((\addr)&$3FFF)<<16)|(((\addr)&$C000)>>14),\ctrl
		move.w	#(\byte)<<8,\dat
		waitDMA	\ctrl
	else
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),VDP_CTRL
		move.w	#$9780,VDP_CTRL
		move.l	#$40000080|(((\addr)&$3FFF)<<16)|(((\addr)&$C000)>>14),VDP_CTRL
		move.w	#(\byte)<<8,VDP_DATA
		waitDMA
	endif

	endm

; -------------------------------------------------------------------------
; Copy a region of VRAM to a location in VRAM
; Auto-increment should be set to 1 beforehand
; -------------------------------------------------------------------------
; PARAMETERS:
;	src	- Source address in VRAM
;	dest	- Destination address in VRAM
;	len	- Length of copy in bytes
;	port	- Representation of VDP control port
;		  (If left blank, this just uses the address instead)
; RETURNS:
;	Nothing
; -------------------------------------------------------------------------

dmaCopy macro &
	src, dest, len, port
	
	if narg>3
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),\port
		move.l	#$96009500|(((\src)&$FF00)<<8)|((\src)&$FF),\port
		move.w	#$97C0,\port
		move.l	#$000000C0|(((\dest)&$3FFF)<<16)|(((\dest)&$C000)>>14),\port
		waitDMA	\port
	else
		move.l	#$94009300|((((\len)-1)&$FF00)<<8)|(((\len)-1)&$FF),VDP_CTRL
		move.l	#$96009500|(((\src)&$FF00)<<8)|((\src)&$FF),VDP_CTRL
		move.w	#$97C0,VDP_CTRL
		move.l	#$000000C0|(((\dest)&$3FFF)<<16)|(((\dest)&$C000)>>14),VDP_CTRL
		waitDMA
	endif

	endm

; -------------------------------------------------------------------------
