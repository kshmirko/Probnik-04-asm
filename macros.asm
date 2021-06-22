;.macro outi
;.message "no parameters specified"
;.endm

.macro outi
	ldi r16, @1

.if @0<0x40
	out @0, r16
.else
	sts @0, r16
.endif

.endm


;.macro UARTINIT
;.message "no parameters specified"
;.endm

.macro UARTINIT
	.set BDIV = XTAL/(16*@0)-1
	outi UBRRH, High(BDIV)
	outi UBRRL, Low(BDIV)
	
	; Enable read and write UART
	outi UCSRB, (1<<RXEN)|(1<<TXEN)						
	outi UCSRC, (1<<URSEL)|(0<<UMSEL)|(0<<USBS)|(0<<UCSZ2)|(1<<UCSZ1)|(1<<UCSZ0)
.endm

.macro TWIINIT
	outi TWBR, (1<<TWBR3)|(1<<TWBR2)
	outi TWSR, (0<<TWPS1)|(0<<TWPS0)
.endm

;.macro UARTWriteByte
;.message "no parameters specified"
;.endm

.macro UARTWriteByte
	ldi r16, @0
	rcall UART_Send_Byte
.endm

;.macro UARTWriteStrZ
;.message "no parameters specified"
;.endm

.macro UARTWriteStrZ
	ldi ZL, low(2*@0)
	ldi ZH, High(2*@0)
	rcall UART_Send_StringZ
.endm
	
