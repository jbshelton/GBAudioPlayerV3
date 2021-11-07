INCLUDE "hardware.inc"

SECTION "Timer interrupt", ROM0[$50]
TimerInterrupt:
	ld a, [hli]
	ld d, a
	and $0f
	ld e, a
	swap a
	or e
	ld e, a
	ld a, d
	or $0f
	ldh [rNR12], a
	ld a, $80
	ldh [rNR50], a
	ldh [rNR14], a
	ld a, e
	ldh [rNR50], a

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

	ld hl, $4000
	ld bc, $0001
	ld sp, $fffe

	ld e, $0f

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
	cp 19
	jr nz, stallPulse

	xor a
	ldh [rNR13], a

	ld a, $80
	ldh [rNR14], a

	ld a, $11
	ldh [rNR51], a
	ld a, $77
	ldh [rNR50], a
