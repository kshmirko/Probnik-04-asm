.dseg
; Integral DH, Decimal RF, Integral T, Decimal T, CRC
dht_response:	.byte	DHT_SIZE
i_index:        .byte   1
j_index:        .byte   1
crc:            .byte   1
dht_ok:         .byte   1

datum:          .byte   1
lcd_x:          .byte   1
lcd_y:          .byte   1

bme280_data:    .byte   1
sym_table:      .byte   2
str_addr:       .byte   2   ; address of string in FLASH (str_addr+0 - high, str_addr+1 - low)
ccs811_data:    .byte   CCS811_BUFSIZE   ; space for CCS811 data





