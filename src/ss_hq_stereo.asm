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
