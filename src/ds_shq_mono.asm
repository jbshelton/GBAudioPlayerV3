INCLUDE "hardware.inc"

SECTION "Timer interrupt", ROM0[$50]
TimerInterrupt:
playSample:
	bit 7, h 			;2
	jr z, contSample 	;2/3
	ld h, $4001 		;3
	inc bc 				;2
contSample:
	push bc 			;4
	; 13 m cycles max

	ld a, [hli]			;2
	ld e, a 			;1
	or $0f				;2
	ldh [rNR12], a 		;3
	ld a, e 			;1
	and $0f 			;2
	ld e, a 			;1
	swap e 				;2
	or e 				;1
	; this part is 15 m cycles

	; e goes to NR50 and d goes to NR51

	ld sp, $ff26 		;3
	ld a, [hli] 		;2
	ld d, a 			;1
	ld a, $80 			;2
	ldh [rNR50], a 		;3
	ldh [rNR14], a 		;3
	push de 			;4
	ld sp, $3003 		;3
	ei 					;1
	; 22 m cycles
	; Total: 50 m cycles
	; Plus 5 m cycles for entry is 55 m cycles
	; this allows a maximum sample rate of 262144/14 = ~18725Hz on GB and 524288/14 = ~37449Hz on GBC

waitSample:
	jr waitSample

SECTION "Header", ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Game code", ROM0[$150]

Start:
	di	
	ld a, $01
	ldh [rKEY1], a
	stop
	nop
	xor a
	ldh [rNR52], a
	cpl
	ldh [rNR52], a

	xor a
	ldh [rNR30], a

	ld c, $30
	ld b, 16
	ld a, $ff
writeWave:
	ldh [c], a
	inc c
	dec b
	jr nz, writeWave

	ld a, $ff
	ldh [rNR33], a
	ld a, $0f
	ldh [rNR42], a

	ld a, $80
	ldh [rNR30], a
	ld a, $20
	ldh [rNR32], a
	ld a, $87
	ldh [rNR34], a

	ld hl, $4000
	ld bc, $0001
	ld sp, $fffe

	ld a, $e0
	ldh [rNR13], a

	ld a, $c0
	ldh [rNR11], a

	ld a, $0f
	ldh [rNR12], a

	ld a, $87
	ldh [rDIV], a
	ldh [rNR14], a

stallPulse1:
	ldh a, [rDIV]
	cp 19
	jr nz, stallPulse1

	xor a
	ldh [rNR13], a

	ld a, $80
	ldh [rNR14], a

	ld a, $11
	ldh [rNR51], a
	ld a, $77
	ldh [rNR50], a
