INCLUDE "hardware.inc"

SECTION "Timer interrupt", ROM0[$50]
TimerInterrupt:
	ld a, [hli]
	ld d, a
	or e
	ldh [rNR12], a
	swap d
	ld a, d
	or e
	ldh [rNR22], a
	ld a, [hli]
	ld d, a
	ld a, $80
	ldh [rNR50], a
	ldh [rNR24], a
	ldh [rNR14], a
	ld a, d
	ldh [rNR50], a

	bit 7, h
	jr z, endSample
	ld h, $2f
	inc bc
	ld [hl], c
	inc h
	ld [hl], b
	ld h, $40
endSample:
	reti
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

	ld hl, $4000
	ld bc, $0001
	ld sp, $3003

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
