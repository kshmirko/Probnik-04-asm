;=================== 1-wire routines to read DHT11/DHT22 data
; read 40 bits via 1wire interface from dht11/dht22 device
; and store data to DHT_RESPONSE variable
;
;
.equ	DHT_PORT		=	PORTB
.equ	DHT_BIT			=	PINB0
.equ	DHT_DDR			=	DDRB
.equ	DHT_PIN			=	PINB

;
; Read 40 bits from 1wire bus dht11/dht22
; used registers:
;	tmp0, tmp1, tmp2, tmp3, tmp4
; used variable:
;	DHT_RESPONSE[5]
;
;
Read1WireData:

	; устанавливаем низкий уровень на 18 мс
	sbi DHT_DDR, DHT_BIT
	cbi	DHT_PORT, DHT_BIT
	nop	;	For syncro
	
	; задержка 18 мс
	rcall Delay_18ms
	
	; переводим порт во вход
	sbi DHT_PORT, DHT_BIT
	cbi	DHT_DDR, DHT_BIT
	nop

	; От датчика должен последовать ответ
    ; 54us низкийи 80us высокий уровень	
	rcall Delay_54us
	
	;if (DHT_PIN&(1<<DHT_BIT))
    ;{
    ;return 0;
    ;}
	sbic DHT_PIN, DHT_BIT
	rjmp Exit_DHT
	
	; Delau 80us
	rcall Delay_80us
	
	;if (!(DHT_PIN&(1<<DHT_BIT)))
    ;{
    ;return 0;
    ;}
	sbis DHT_PIN, DHT_BIT
	rjmp Exit_DHT
	
	;===============receive 40 data bits ==============================
	;while (DHT_PIN&(1<<DHT_BIT));
A0: sbic DHT_PIN, DHT_BIT
	rjmp A0
	
	ldi XL, low(DHT_RESPONSE)
	ldi XH, High(DHT_RESPONSE)

	clr tmp0
	sts i_index, tmp0

; for tmp=0; tmp<5; tmp++    
B0: 
	;X[tmp] = 0
	clr tmp1
	st X, tmp1
	
	ldi tmp3, 0x01
	ldi tmp4, 0x00
	; for tmp2=0; tmp2<8; tmp2++
	ldi tmp0, 0
	sts j_index, tmp0
B1: 
	;while (!(DHT_PIN&(1<<DHT_BIT)));
C0:	sbis DHT_PIN, DHT_BIT
	rjmp C0
	
	rcall Delay_30us
	
	;if (DHT_PIN&(1<<DHT_BIT))
    ;        data[j]|=1<<(7-i);
	sbic DHT_PIN, DHT_BIT
	or tmp4, tmp3
	lsl tmp3
	
	;while (DHT_PIN&(1<<DHT_BIT));
C1: sbic DHT_PIN, DHT_BIT
	rjmp C1

    lds tmp0, j_index
	inc tmp0
	sts j_index, tmp0
	cpi tmp0, BITS
	brne B1
	
; Rotate bits in register
	clr tmp5
	ldi tmp6, BITS
W0: rol tmp4
	ror tmp5
	dec tmp6
	brne W0
	mov  tmp4,tmp5   

;	DHT_RESPONSE[tmp++] = tmp4
	st X+, tmp4
;	
    lds tmp0, i_index
	inc tmp0
	sts i_index, tmp0
	cpi tmp0, DHT_SIZE
	brne B0
    
    clr tmp0
    ldi XL, low(DHT_RESPONSE)
    ldi XH, High(DHT_RESPONSE)
    ldi tmp2, DHT_SIZE

P0: ld tmp1, X+
    add tmp0, tmp1
    dec tmp2
    brne P0
    sts CRC, tmp0
    nop
Exit_DHT:    
	ret


Delay_18ms:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 287 993 cycles
; 17ms 999us 562 1/2 ns
; at 16 MHz
; 7+12 cycles overhead
	push r18
	push r19
	push r20
	
    ldi  r18, 2
    ldi  r19, 118
    ldi  r20, 254
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
    nop
    
    pop r20
    pop r19
    pop r18
    ret


Delay_54us:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 849 cycles
; 53us 62 1/2 ns
; at 16 MHz
; 7+8cycles  overhead
	push r18
	push r19
	
    ldi  r18, 2
    ldi  r19, 25
L2: dec  r19
    brne L2
    dec  r18
    brne L2
    nop
    pop r19
    pop r18
    
    ret
    
Delay_80us:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 1 265 cycles
; 79us 62 1/2 ns
; at 16 MHz
	push r18
	push r19
	
    ldi  r18, 2
    ldi  r19, 164
L3: dec  r19
    brne L3
    dec  r18
    brne L3
    
    pop r19
    pop r18
    
    ret
    
Delay_30us:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 469 cycles
; 29us 312 1/2 ns
; at 16 MHz
	push r18
	
    ldi  r18, 156
L5: dec  r18
    brne L5
    nop
    
    pop r18
    
    ret
