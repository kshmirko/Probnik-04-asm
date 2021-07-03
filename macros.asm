; различные макросы на все случаи жизни

.macro outi
	ldi r16, @1

.if @0<0x40
	out @0, r16
.else
	sts @0, r16
.endif

.endm

.macro UARTINIT
	.set BDIV = XTAL/(16*@0)-1
	outi UBRRH, High(BDIV)
	outi UBRRL, Low(BDIV)
	
	; Enable read and write UART
	outi UCSRB, (1<<RXEN)|(1<<TXEN)						
	outi UCSRC, (1<<URSEL)|(0<<UMSEL)|(0<<USBS)|(0<<UCSZ2)|(1<<UCSZ1)|(1<<UCSZ0)
.endm

.macro TWIINIT
	outi TWBR, 0x48
	outi TWSR, (0<<TWPS1)|(0<<TWPS0)
.endm

.macro UARTWriteByte
	ldi r16, @0
	rcall UART_Send_Byte
.endm

; Send to output UART variable from program memory
.macro UARTWriteStrPZ ;var
	ldi ZL, low(2*@0)
	ldi ZH, High(2*@0)
	rcall UART_Send_StringPZ
.endm

.macro SETMEM ;var, const
    push r16
    ldi r16, @1
    sts @0, r16
    pop r16
.endm

