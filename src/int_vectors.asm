; Определение точек входа в прерывания
.org	INT0addr	; External Interrupt Request 0
RETI
.org	INT1addr	; External Interrupt Request 1
RETI
.org	INT2addr	; External Interrupt Request 2
RETI
.org	OC2addr		; Timer/Counter2 Compare Match
RETI
.org	OVF2addr	; Timer/Counter2 Overflow
RETI
.org	ICP1addr	; Timer/Counter1 Capture Event
RETI
.org	OC1Aaddr	; Timer/Counter1 Compare Match A
RETI
.org	OC1Baddr	; Timer/Counter1 Compare Match B
RETI
.org	OVF1addr	; Timer/Counter1 Overflow
RETI
.org	OC0addr		; Timer/Counter0 Compare Match
RETI
.org	OVF0addr	; Timer/Counter0 Overflow
RETI
.org	SPIaddr		; Serial Transfer Complete
RETI
.org	URXCaddr	; USART, Rx Complete
rjmp UART_RX_ISR
.org	UDREaddr	; USART Data Register Empty
RETI
.org	UTXCaddr	; USART, Tx Complete
RETI
.org	ADCCaddr	; ADC Conversion Complete
RETI
.org	ERDYaddr	; EEPROM Ready
RETI
.org	ACIaddr		; Analog Comparator
RETI
.org	TWIaddr		; 2-wire Serial Interface
rjmp TWI_HANDLER
.org	SPMRaddr	; Store Program Memory Ready
RETI
.org INT_VECTORS_SIZE
