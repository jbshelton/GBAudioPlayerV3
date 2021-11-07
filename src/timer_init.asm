
	ldh [rTMA], a
	ld a, %00000101
	ldh [rTAC], a
	xor a
	ldh [rTIMA], a
	ld a, $04
	ldh [rIE], a
	ei
	jp waitSample
	;jp playSample