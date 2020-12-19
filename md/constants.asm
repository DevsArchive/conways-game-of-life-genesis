
; -------------------------------------------------------------------------
;
;	Mega Drive Library
;		By Ralakimus 2018
;
;	File:		constants.asm
;	Contents:	Constant definitions
;
; -------------------------------------------------------------------------

; -------------------------------------------------------------------------
; ROM
; -------------------------------------------------------------------------

ROM_START		EQU	$000000		; ROM start address
ROM_END			EQU	$400000		; ROM end address

; -------------------------------------------------------------------------
; Z80
; -------------------------------------------------------------------------

Z80_RAM			EQU	$A00000		; Z80 RAM start address
Z80_END			EQU	$A02000		; Z80 RAM end address
Z80_BUS			EQU	$A11100		; Z80 bus request
Z80_RESET		EQU	$A11200		; Z80 reset

; -------------------------------------------------------------------------
; Sound
; -------------------------------------------------------------------------

YM2612_A0		EQU	$A04000		; YM2612 register port 0
YM2612_D0		EQU	$A04001		; YM2612 data port 0
YM2612_A1		EQU	$A04002		; YM2612 register port 1
YM2612_D1		EQU	$A04003		; YM2612 data port 1
PSG_INPUT		EQU	$C00011		; PSG input

; -------------------------------------------------------------------------
; I/O
; -------------------------------------------------------------------------

HW_VERSION		EQU	$A10001		; Hardware version
PORT_A_DATA		EQU	$A10003		; Port A data
PORT_B_DATA		EQU	$A10005		; Port B data
PORT_C_DATA		EQU	$A10007		; Port C data
PORT_A_CTRL		EQU	$A10009		; Port A control
PORT_B_CTRL		EQU	$A1000B		; Port B control
PORT_C_CTRL		EQU	$A1000D		; Port C control
PORT_A_TX		EQU	$A1000F		; Port A Tx data
PORT_A_RX		EQU	$A10011		; Port A Rx data
PORT_A_SCTRL		EQU	$A10013		; Port A S control
PORT_B_TX		EQU	$A10015		; Port B Tx data
PORT_B_RX		EQU	$A10017		; Port B Rx data
PORT_B_SCTRL		EQU	$A10019		; Port B S control
PORT_C_TX		EQU	$A1001B		; Port C Tx data
PORT_C_RX		EQU	$A1001D		; Port C Rx data
PORT_C_SCTRL		EQU	$A1001F		; Port C S control
SRAM_ACCESS		EQU	$A130F1		; SRAM access port
TMSS_PORT		EQU	$A14000		; TMSS port

; -------------------------------------------------------------------------
; VDP
; -------------------------------------------------------------------------

VDP_DATA		EQU	$C00000		; VDP data port
VDP_CTRL		EQU	$C00004		; VDP control port
VDP_HV			EQU	$C00008		; VDP H/V counter
VDP_DEBUG		EQU	$C0001C		; VDP debug register

; -------------------------------------------------------------------------
; RAM
; -------------------------------------------------------------------------

RAM_START		EQU	$FF0000		; RAM start address
RAM_END			EQU	$1000000	; RAM end address

; -------------------------------------------------------------------------
; Controller
; -------------------------------------------------------------------------

	rsreset
JbU			rs.b	1		; Bit up
JbD			rs.b	1		; Bit down
JbL			rs.b	1		; Bit left
JbR			rs.b	1		; Bit right
JbB			rs.b	1		; Bit B
JbC			rs.b	1		; Bit C
JbA			rs.b	1		; Bit A
JbS			rs.b	1		; Bit start
JbZ			rs.b	1		; Bit Z
JbY			rs.b	1		; Bit Y
JbX			rs.b	1		; Bit X
JbM			rs.b	1		; Bit mode

J_U			EQU	(1<<JbU)	; Up
J_D			EQU	(1<<JbD)	; Down
J_L			EQU	(1<<JbL)	; Left
J_R			EQU	(1<<JbR)	; Right
J_B			EQU	(1<<JbB)	; B
J_C			EQU	(1<<JbC)	; C
J_A			EQU	(1<<JbA)	; A
J_S			EQU	(1<<JbS)	; Start
J_Z			EQU	(1<<JbZ)	; Z
J_Y			EQU	(1<<JbY)	; Y
J_X			EQU	(1<<JbX)	; X
J_M			EQU	(1<<JbM)	; Mode

CTRLbTH			EQU	6		; TH pin bit
CTRLbTR			EQU	5		; TR pin bit
CTRLbTL			EQU	4		; TL pin bit
CTRL_TH			EQU	1<<CTRLbTH	; TH pin
CTRL_TR			EQU	1<<CTRLbTR	; TR pin
CTRL_TL			EQU	1<<CTRLbTL	; TL pin

; -------------------------------------------------------------------------
