.cseg
;.org		(FLASHEND-400)
buildtime:	.db "RELEASE DATE %YEAR%%MONTH%%DAY%%HOUR%%MINUTE%",0


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

BME280_Data:    .byte   1
sym_table:      .byte   2
str_addr:       .byte   2   ; address of string in FLASH (str_addr+0 - high, str_addr+1 - low)
CCS811_DATA:    .byte   CCS811_BUFSIZE   ; space for CCS811 data
.eseg

