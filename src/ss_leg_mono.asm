INCLUDE "hardware.inc"

SECTION "Timer interrupt", ROM0[$50]
TimerInterrupt:
    dec e
    jp z, contSample

    ld a, [hli]
	ld d, a
	or $0f
	ldh [rNR12], a
	ld a, $80
	ldh [rNR14], a
	reti

contSample:
	ld e, 2
	ld a, d
	swap d
	or $0f
	ldh [rNR12], a
	ld a, $80
	ldh [rNR14], a

	bit 7, h
	jr z, sampleEnd
	ld h, $2f
	inc bc
	ld [hl], c
	inc h
	ld [hl], b
	ld h, $40

sampleEnd:
	reti

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

	ld a, $e0
	ldh [rNR13], a

	ld a, $c0
	ldh [rNR11], a

	ld a, $0f
	ldh [rNR12], a

	ld a, $87
	ldh [rDIV], a
	ldh [rNR14], a

stallPulse:
	ldh a, [rDIV]
	cp 9
	jr nz, stallPulse

	xor a
	ldh [rNR13], a

	ld a, $80
	ldh [rNR14], a

	ld e, 2

	ld a, $11
	ldh [rNR51], a
