; различные макросы на все случаи жизни

.macro OUTI
; send constant to a memory/port
	ldi r16, @1
.if @0<$40
	out @0, r16
.else
	sts @0, r16
.endif

.endmacro

.macro OUTR
; out register to a memory/port
    .if @0<$40
        out @0, @1
    .else
        sts @0, @1
    .endif
.endmacro

.macro INR
; read value from port/memory into register
    .if @1<$40
        in @0, @1
    .else
        lds @0, @1
    .endif
.endmacro

.macro SETB
; set bit via register
; temp is used and not restored at the end
    .if @0<$20
        sbi @0, @1
    .elif @0<$40
        in temp, @0
        ori temp, (1<<@1)
        out @0, temp
    .else   
        lds temp, @1
        ori temp, (1<<@1)
        sts @1, temp
    .endif
.endmacro

.macro CLRB
; clear bit via register
; temp is used and not restored at the end
    .if @0<$20
        cbi @0, @1
    .elif @0<$40
        in temp, @0
        andi temp, ~(1<<@1)
        out @0, temp
    .else   
        lds temp, @1
        andi temp, ~(1<<@1)
        sts @1, temp
    .endif
.endmacro

.macro INVB
; invert bit via register
; uses temp and temp1
; these registers corrupted at the end if a macro
.if @0<$40
    in temp, @0
    ldi temp1, @1
    eor temp, temp1
    out @0, temp
.else
    lds temp, @0
    ldi temp1, @1
    eor temp, temp1
    sts @0, temp1
.endif
.endmacro

;=============================================================================
;==================== these macro help using BRTS, BRTC
;=============================================================================
.macro STOREB
; store @1 bit of @0 in T flag of SREG
.if @0<$20
    in temp, @0
    bst temp, @1
.else
    lds temp, @0
    bst temp, @1
.endif
.endmacro

.macro LOADB
; store T flag of SREG in @1 bit of @0
.if @0<$40
    in temp, @0
    bld temp, @1
    out @0, temp
.else
    lds temp, @0
    bld temp, @1
    sts @0, temp
.endif
.endmacro
;=============================================================================

;=============================================================================
; Initialize Stack Pointer to the end of RAM
; Stack grows from the end of RAM towards beginning
;=============================================================================
.macro StackInit
    OUTI SPL, LOW(@0)
    OUTI SPH, HIGH(@0)
.endmacro

;=============================================================================
; Working with UART 
;=============================================================================
.macro UARTINIT_Syncro; BAUD_RATE,'N',1
	.set BDIV = XTAL/(16*@0)-1
	OUTI UBRRH, High(BDIV)
	OUTI UBRRL, Low(BDIV)
	
	; Enable read and write UART
	OUTI UCSRB, (1<<RXEN)|(1<<TXEN)

    .set UCSRC0 = 0

    .if @1=='N'
    .set UCSRC0 |= (0<<UPM1)|(0<<UPM0)
    .endif
    .if @1=='E'
    .set UCSRC0 |= (1<<UPM1)|(0<<UPM0)
    .endif
    .if @1=='O'
    .set UCSRC0 |= (1<<UPM1)|(1<<UPM0)
    .endif

    .if @2==2
    .set UCSRC0 |= (1<<USBS)
    .endif

	OUTI UCSRC, UCSRC0|(1<<UCSZ1)|(1<<UCSZ0)

    ; Init variables
;    OUTI rx_wr_index, 0
;    OUTI rx_rd_index, 0
;    OUTI rx_counter, 0

.endmacro

.macro TWIINIT
	OUTI TWBR, 0x48
	OUTI TWSR, (0<<TWPS1)|(0<<TWPS0)
.endmacro

.macro UARTWriteByte
	ldi r16, @0
	rcall UART_Send_Byte
.endmacro

; Send to output UART variable from program memory
.macro UARTWriteStrPZ ;var
	ldi ZL, low(2*@0)
	ldi ZH, High(2*@0)
	rcall UART_Send_StringPZ
.endmacro


;=============================================================================
; push working register and SREG into stack
;=============================================================================
.macro PUSHF
    push temp
    in temp, SREG
    push temp
.endmacro

.macro POPF
    pop temp
    out SREG, temp
    pop temp
.endmacro


;=============================================================================
;=============================================================================
.macro RAMFLUSH
;   Empty whole RAM
;   Z register points to the beginning if the RAM,
;   then sequentally clears each byte towards RAMEND
    ldi ZL, low(SRAM_START)
    ldi ZH, high(SRAM_START)
    clr temp

LRF_%:
    st Z+, temp
    cpi ZL, low(RAMEND)
    brne LRF_%

    cpi ZH, high(RAMEND+1)
    brne LRF_%
.endmacro

.macro GPRFLUSH
    ldi	ZL, 30	; +-----------------------------+
	clr	ZH	    ; | Empty   registers (R00-R31) |
	dec	ZL	    ; |                             |
	st	Z, ZH	; | [всего 10 байт кода!]       |
	brne PC-2   ; +-----------------------------+
.endm

;=============================================================================
; Increment and decrement variables in memory
;=============================================================================

.macro INC8M
    lds temp, @0
    subi temp, (-1)
    sts @0, temp
.endmacro


.macro DEC8M
    lds temp, @0
    subi temp, (1)
    sts @0, temp
.endmacro


.macro CLR8M
    clr temp
    sts @0, temp
.endmacro

; increment 2 byte variable in memory
; @0+1  - high byte
; @0    - lower byte
.macro INC16M
    lds temp, @0
    subi temp, (-1)
    sts @0, temp

    lds temp, @0+1
    sbci temp, (-1)
    sts @0+1, temp
.endmacro

; adds register @0 to Z register
.macro ADZR
    add ZL, @0
    adc ZH, r0
.endmacro

; loads address from memory @0 into Z
; memory has following layout: ZL, ZH
.macro RAM_DATA_IN_Z
    lds ZL, @0+0
    lds ZH, @0+1
.endmacro

.macro PUSHXYZ
    push XH
    push XL
    push YH
    push YL
    push ZH
    push ZL
.endmacro

.macro POPXYZ
    pop ZL
    pop ZH
    pop YL
    pop YH
    pop XL
    pop XH
.endmacro

;=============================================================================
; Macroses to use with I2C
;=============================================================================

.macro TWI_WRITE_ASYNC
; @0 - address
; @1 - variable
; @2 - num bytes to write
    OUTI i2c_busy, 1
    OUTI i2c_slave_addr, @0
    OUTI do_i2c, I2C_SAWP 
    OUTI i2c_buffer_addr_out+0, low(@1)
    OUTI i2c_buffer_addr_out+1, high(@1)
    OUTI i2c_index_data+0, 0
    OUTI i2c_index_data_size, @2

    OUTI TWCR, 1<<TWSTA|0<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
.endmacro


.macro TWI_READ_ASYNC
; @0 - address
; @1 - variable
; @2 - num bytes to write

    OUTI i2c_busy, 1
    OUTI i2c_slave_addr, @0
    OUTI do_i2c, I2C_SARP 
    OUTI i2c_buffer_addr_in+0, low(@1)
    OUTI i2c_buffer_addr_in+1, high(@1)
    OUTI i2c_index_data+0, 0
    OUTI i2c_index_data_size, @2

    OUTI TWCR, 1<<TWSTA|0<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
.endmacro
