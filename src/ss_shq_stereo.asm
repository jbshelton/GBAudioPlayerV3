INCLUDE "hardware.inc"

SECTION "Timer interrupt", ROM0[$50]
TimerInterrupt:
playSample:
	bit 7, h 			;2
	jr z, contSample 	;2/3
	ld hl, $4001 		;3
	inc bc 				;2
contSample:
	push bc 			;4
	; 13 m cycles max

	ld a, [hli]			;2
	ld d, a 			;1
	or $0f				;2
	ldh [rNR12], a 		;3
	swap d 				;2
	ld a, d 			;1
	or $0f 				;2
	ldh [rNR22], a 		;3
	; this part is 16 m cycles

	; e goes to NR50 and d goes to NR51

	ld sp, $ff26 		;3
	ld a, [hli] 		;2
	ld e, a 			;1
	ld a, [hli] 		;2
	ld d, a 			;1
	ld a, $80 			;2
	ldh [rNR50], a 		;3
	ldh [rNR24], a 		;3
	ldh [rNR14], a 		;3
	push de 			;4
	ld sp, $3003 		;3
	ei 					;1
	; 28 m cycles
	; Total: 57 m cycles
	; Plus 5 m cycles for entry is 62 m cycles
	; still no reliable way to go over 16384Hz on GB and 32768Hz on GBC, but will slightly decrease noise 
	; because writing to NR50 and NR51 is reduced from 8 m cycles to 4 m cycles

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

	ld hl, $4001
	ld bc, $0001
	ld sp, $fffe

	ld a, $e0
	ldh [rNR13], a
	ldh [rNR23], a

	ld a, $c0
	ldh [rNR11], a
	ldh [rNR21], a

	ld a, $0f
	ldh [rNR12], a
	ldh [rNR22], a

	ld a, $87
	ldh [rDIV], a
	ldh [rNR14], a

stallPulse1:
	ldh a, [rDIV]
	cp 9
	jr nz, stallPulse1

	xor a
	ldh [rNR13], a

	ld a, $80
	ldh [rNR14], a

	ld a, $87
	ldh [rDIV], a
	ldh [rNR24], a

stallPulse2:
	ldh a, [rDIV]
	cp 9
	jr nz, stallPulse2

	xor a
	ldh [rNR23], a

	ld a, $80
	ldh [rNR24], a
	ldh [rNR14], a

	ld e, $0f

	ld a, $12
	ldh [rNR51], a
	ld a, $77
	ldh [rNR50], a
