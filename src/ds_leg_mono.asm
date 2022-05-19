; MIT License
;
; Copyright (c) 2022 Jackson Shelton <jacksonshelton8@gmail.com>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

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
	ld h, $30
	inc bc
	ld [hl], b
	dec h
	ld [hl], c
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

	ld e, 2

	ld a, $77
	ldh [rNR50], a
	ld a, $11
	ldh [rNR51], a
