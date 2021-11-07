INCLUDE "hardware.inc"

SECTION "Timer interrupt", ROM0[$50]
TimerInterrupt:
playSample:
	ld a, [hli]
	ld d, a
	or $0f
	ldh [rNR12], a
	swap d
	ld a, d
	or $0f
	ldh [rNR22], a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	ld a, $80
	ldh [rNR50], a
	ldh [rNR14], a
	ldh [rNR24], a
	ld a, e
	ldh [rNR51], a
	ld a, d
	ldh [rNR50], a
	;41 m cycles

	bit 7, h
	jr z, sampleEnd
	ld h, $2f
	inc bc
	ld [hl], c
	inc h
	ld [hl], b
	ld h, $40
	inc l
sampleEnd:
	pop af
	ei
	;all of bank switch takes max 20 m cycles
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
