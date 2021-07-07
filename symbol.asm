.equ	ACODE=0x41
.equ	SYMBWIDTH=5
.cseg
	ldi ZL, low(symtbl)
	ldi ZH, high(symtbl)
	push ZL
	push ZH
	
	; idx = (ACODE-ch)*SYMBWIDTH
	ldi r17, 'D'
	subi r17, ACODE
	ldi r16, SYMBWIDTH
	mul r16, r17
	add ZL, r0
	adc ZH, r1
	
	ldi r17, 5
display:	
	lpm r16, Z+
	dec r17
	brne display
	
	pop ZH
	pop ZL
	
	
symtbl:	.db	0x7E, 0x11, 0x11, 0x11, 0x7E ; 41 A
		.db	0x7F, 0x49, 0x49, 0x49, 0x36 ; 42 B
		.db	0x3E, 0x41, 0x41, 0x41, 0x22 ; 43 C
		.db	0x7F, 0x41, 0x41, 0x22, 0x1C ; 44 D
		.db	0x7F, 0x49, 0x49, 0x49, 0x41 ; 45 E
		.db	0x7F, 0x09, 0x09, 0x09, 0x01 ; 46 F
		.db	0x3E, 0x41, 0x49, 0x49, 0x7A ; 47 G
		.db	0x7F, 0x08, 0x08, 0x08, 0x7F ; 48 H
		.db	0x00, 0x41, 0x7F, 0x41, 0x00 ; 49 I
		.db	0x20, 0x40, 0x41, 0x3F, 0x01 ; 4a J
		.db	0x7F, 0x08, 0x14, 0x22, 0x41 ; 4b K
		.db	0x7F, 0x40, 0x40, 0x40, 0x40 ; 4c L
		.db	0x7F, 0x02, 0x0C, 0x02, 0x7F ; 4d M
		.db	0x7F, 0x04, 0x08, 0x10, 0x7F ; 4e N
		.db	0x3E, 0x41, 0x41, 0x41, 0x3E ; 4f O
		.db	0x7F, 0x09, 0x09, 0x09, 0x06 ; 50 P
		.db	0x3E, 0x41, 0x51, 0x21, 0x5E ; 51 Q
		.db	0x7F, 0x09, 0x19, 0x29, 0x46 ; 52 R
		.db	0x46, 0x49, 0x49, 0x49, 0x31 ; 53 S
		.db	0x01, 0x01, 0x7F, 0x01, 0x01 ; 54 T
		.db	0x3F, 0x40, 0x40, 0x40, 0x3F ; 55 U
		.db	0x1F, 0x20, 0x40, 0x20, 0x1F ; 56 V
		.db	0x3F, 0x40, 0x38, 0x40, 0x3F ; 57 W
		.db	0x63, 0x14, 0x08, 0x14, 0x63 ; 58 X
		.db	0x07, 0x08, 0x70, 0x08, 0x07 ; 59 Y
		.db	0x61, 0x51, 0x49, 0x45, 0x43 ; 5a Z