
; -------------------------------------------------------------------------
;
;	Conway's Game of Life On Sega Genesis
;		By Ralakimus 2018
;
;	File:		config.asm
;	Contents:	Build configuration
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; Header definitions (required)
; -------------------------------------------------------------------------

; Game name
GAME_NAME	equs	"CONWAY'S GAME OF LIFE ON GENESIS"
; I/O support
IO_SUPPORT	equs	"J"
; SRAM support
SRAM_SUPPORT	equ	$20202020
; SRAM start address
SRAM_START	equ	$20202020
; SRAM end address
SRAM_END	equ	$20202020
; Region
REGION		equs	"JUE"
; Notes
NOTES		equs	""

; -------------------------------------------------------------------------
; User defined
; -------------------------------------------------------------------------

; Insert user defined flags here

; -------------------------------------------------------------------------
