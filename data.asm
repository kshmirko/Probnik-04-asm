.cseg
;.org		(FLASHEND-400)
buildtime:	.db 'R','E','L','E','A','S','E',' ','D','A','T','E',0,0,0,0
;header:		.db "This program is Probnik-04 firmware",10,13, 0
;author:		.db "Ph.D. Shmirko K.A. ",10,13,0


.dseg
; Integral DH, Decimal RF, Integral T, Decimal T, CRC
DHT_RESPONSE:	.byte	DHT_SIZE
i_index:        .byte   1
j_index:        .byte   1
CRC:            .byte   1
DHT_OK:         .byte   1

DATUM:          .byte   1
LCD_X:          .byte   1
LCD_Y:          .byte   1

.eseg

