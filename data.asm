.cseg
.org		(FLASHEND-100)
buildtime:	.db "Release date %DAY%.%MONTH%.%YEAR% %HOUR%:%MINUTE%",10,13,0
header:		.db "This program is Probnik-04 firmware",10,13, 0
author:		.db "Ph.D. Shmirko K.A. ",10,13,0


.dseg
; Integral DH, Decimal RF, Integral T, Decimal T, CRC
DHT_RESPONSE:	.byte	DHT_SIZE


.eseg
