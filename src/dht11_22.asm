;=================== 1-wire routines to read DHT11/DHT22 data
; read 40 bits via 1wire interface from dht11/dht22 device
; and store data to DHT_RESPONSE variable
;
;
.equ	DHT_PORT		=	PORTB
.equ	DHT_BIT			=	PINB0
.equ	DHT_DDR			=	DDRB
.equ	DHT_PIN			=	PINB


dht_read_byte:
    ;читаем 1 байт по шине 1-wire
    ;используемые регистры
    ; r16 - возвращаемые данные
    ; r17 - dht_counter
    ; r18 - переменная цикла
    ; r19 - битовая маска получаемого бита
    ; эти регистры модифицируются и не исправляются
    eor r16, r16; dht_data = 0
    eor r17, r17; dht_counter = 0

    cbi DHT_DDR, DHT_BIT; DHT_DDR &= ~(1<<DHT_BIT)

    ldi r19, 0x01
    ldi r18, 7; i=7
dht_l0:
    eor r17, r17 ; dht_counter = 0

dht_l1: ;while(!(DHT_PIN & (1<<DHT_BIT)) && (dht11_counter<10)){
    sbic DHT_PIN, DHT_BIT
    rjmp dht_l1_exit
    cpi r17, 10
    brge dht_l1_exit
    rcall Delay_10us
    inc r17
    rjmp dht_l1
dht_l1_exit:
    eor r17, r17 ; dht_counter = 0

dht_l2: ;while((DHT_PIN & (1<<DHT_BIT)) && (dht11_counter<15)){
    sbis DHT_PIN, DHT_BIT
    rjmp dht_l2_exit
    cpi r17, 15
    brge dht_l2_exit
    rcall Delay_10us
    inc r17
    rjmp dht_l2
dht_l2_exit:
    cpi r17, 5
    brlt dht_l3_exit
    or r16, r19 
dht_l3_exit:
    lsl r19; r19<<1
    dec r18
    brne dht_l0
    ret
    
    

; Read 40 bits from 1wire bus dht11/dht22
; used registers:
;	temp, temp1, temp2, temp3, temp4
; used variable:
;	DHT_RESPONSE[5]
;
;
Read1WireData:
    ; Шина 1-wire зависит от задержек, поэтому важно, чтобы во время 
    ; взаимодействия с этой шиной, никакие прерывания не останавливали 
    ; выполнение подпрограммы
    ; sbi - установка бита в регистре ввода-вывода
    ; cbi - очистка бита в регистре ввода-вывода
    ; sbic - пропуск следующей инструкции, если указанный бит в порту 
    ;        ввода/вывода снят (равен 0)
    ; sbis - пропуск следующей инструкции, если указанный бит в порту 
    ;        ввода/вывода установлен (равен 1)
    ; чтобы случайно  не уйти в прерывание и не потерять посылку мы запрещаем 
    ; прерывания
    cli
	
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

	clr temp
	sts i_index, temp

; for tmp=0; tmp<5; tmp++    
B0: 
	;X[tmp] = 0
	clr temp1
;	st X, temp1
	
	ldi temp3, 0x01
	clr temp4
	; for temp2=0; temp2<8; temp2++
	clr temp
	sts j_index, temp
B1: 
	;while (!(DHT_PIN&(1<<DHT_BIT)));
C0:	sbis DHT_PIN, DHT_BIT
	rjmp C0
	
	rcall Delay_30us
	
	;if (DHT_PIN&(1<<DHT_BIT))
    ;        data[j]|=1<<(7-i);
	sbic DHT_PIN, DHT_BIT
	or temp4, temp3
	lsl temp3
	
	;while (DHT_PIN&(1<<DHT_BIT));
C1: sbic DHT_PIN, DHT_BIT
	rjmp C1

    lds temp, j_index
	inc temp
	sts j_index, temp
	cpi temp, BITS
	brne B1
	
; Rotate bits in register
	clr temp5
	ldi temp6, BITS
W0: rol temp4
	ror temp5
	dec temp6
	brne W0
	mov  temp4,temp5   

;	DHT_RESPONSE[tmp++] = temp4
	st X+, temp4
;	
    lds temp, i_index
	inc temp
	sts i_index, temp
	cpi temp, DHT_SIZE
	brne B0


; Расчет CRC = (DHT[0]+DHT[1]+DHT[2]+DHT[3])&0xFF
    clr temp
    ldi XL, low(DHT_RESPONSE)
    ldi XH, High(DHT_RESPONSE)
    ldi temp2, DHT_SIZE-1
; for temp2=DHT_SIZE-1 to 0
P0: ld temp1, X+
    add temp, temp1
    dec temp2
    brne P0
    sts CRC, temp

; проверка CRC
; DHT_OK = 1
    ldi temp1, 1
    sts DHT_OK, temp1

    lds temp1, DHT_RESPONSE+4
    cp temp, temp1
    breq Exit_DHT
; if CRC!=DHT[4] DHT_OK=0
    clr temp1
    sts DHT_OK, temp1

Exit_DHT:
    ; разрешаем прерывания
    sei
	ret


Delay_10us:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 149 cycles
; 9us 312 1/2 ns
; at 16 MHz
; 7+4 cycles
    push r18
    ldi  r18, 49
L6: dec  r18
    brne L6
    rjmp PC+1
    pop r18


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
