;.nolist
;.includepath "/usr/local/Cellar/avra/1.4.2/include/avr/"
.include "m32def.inc"
.include "macros.asm"
;.list
.include "constants.asm"
;=============== ���������� ���� ��������� ============================
.cseg
Reset:
	; Start from the beginning 
	.org 0x0000
	; and jump to the init section
	rjmp Init
	.include "int_vectors.asm"	; ���������� ������� ����������
	.include "int_routines.asm"	; ��������� ��������� ����������

Init:
	
	UARTINIT BAUDRATE			; ��������� UART 9600, 8, 1, None
;	TWIINIT						; ��������� TWI, 400kHz
; =============== Write Intro to UART =================================
	UARTWriteStrZ buildtime
	UARTWriteStrZ header
	UARTWriteStrZ author
; =============== Super Loop ==========================================
Loop:
	rcall Read1WireData
	rcall Delay_18ms
	rjmp Loop

;================ End Program =========================================
.include "uart.asm"		 	; ���������� ����������� ���������� UART
.include "twi.asm"			; � TWI	
.include "dht11_22.asm" ; ����������� ����������� ��� ������ � dht11/dht22
.include "data.asm"
