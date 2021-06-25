.nolist
.includepath "/usr/local/Cellar/avra/1.4.2/include/avr/"
.include "m32def.inc"
.include "macros.asm"
.list
.include "constants.asm"
;=============== собственно сама программа ============================
.cseg
Reset:
	; Start from the beginning 
	.org 0x0000
	; and jump to the init section
	rjmp Init
	.include "int_vectors.asm"	; определяем векторы прерываний
	.include "int_routines.asm"	; процедуры обработки прерываний

Init:
	
	UARTINIT BAUDRATE			; настройка UART 9600, 8, 1, None
	TWIINIT						; настройка TWI, 400kHz
; =============== Write Intro to UART =================================
	UARTWriteStrZ buildtime
	UARTWriteStrZ header
	UARTWriteStrZ author
; =============== Super Loop ==========================================

    SETMEM CByte, COMMAND
    rcall LCD_Init
    ldi tmp0, 170
    rcall LCD_Clear
Loop:
	rcall Read1WireData
	rcall Delay_18ms
	rjmp Loop

;================ End Program =========================================
.include "uart.asm"		 	; определяем обработчики прерываний UART
.include "twi.asm"			; и TWI	
.include "dht11_22.asm" ; подключение подпрограмм для работы с dht11/dht22
.include "data.asm"
