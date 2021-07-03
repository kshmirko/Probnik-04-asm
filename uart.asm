; UART routines


;=============== Send byte to UART ===================================
; Data to send in R16 
; Input R16 - byte to send
;=====================================================================
UART_Send_Byte:
	sbis UCSRA, UDRE		; Wait for UDRE bit is set
	rjmp UART_Send_Byte		; 
	out UDR, r16			; and put new data to UDR
	ret
	
;=============== Read byte to UART ===================================
; Received data in R16
; Output R16 - received byte 
UART_Receive_Byte:
	; Wait for data to be received
	sbis UCSRA, RXC
	rjmp UART_Receive_Byte
	; Get and return received data from buffer
	in r16, UDR
	ret


;=============== Read byte to UART ===================================
; Send zero terminated string to uart
; data address in Z
; string is located in flash memory (in code segment)
; Example:
; ldi ZL, Low(string_in_ram)
; ldi ZH, High(string_in_ram) 
; or
; ldi ZL, Low(2*string_in_flash)
; ldi ZH, High(2*string_in_flash)
; rcall UART_Send_StringZ
; ====================================================================	
UART_Send_StringPZ:
l_0:
	lpm r16, Z+
	cpi r16,0
	breq e_0
	rcall UART_Send_Byte
	rjmp l_0
e_0:
	ret
