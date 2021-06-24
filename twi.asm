; Работа с TWI

.equ    START           =   0x08
.equ    RSTART          =   0x10
.equ    SLA_W_ACK       =   0x18
.equ    SLA_W_NACK      =   0x20
.equ    DATA_ACK        =   0x28
.equ    DATA_NACK       =   0x30
.equ    SLA_W_LOST      =   0x38

; Address of SSD1306 is 0x3c
; SLA_W is ADDRESS of SSD1306 shifted left by 1 bit
; SLA_R is address of SSD1306 shifted left by 1 bit and or-ed with 0x01
.equ    SSD1306_ADDR    =   0x3c
.equ    SLA_W           =   SSD1306_ADDR << 1
.equ    SLA_R           =   (SSD1306_ADDR << 1)|0x01   

.equ    TRUE            =   0x01
.equ    FALSE           =   0x00

.equ    SSD1306_LCDWIDTH        =   128
.equ    SSD1306_LCDHEIGHT       =   64
.equ    SSD1306_DEFAULT_SPACE   =   5

.equ    SSD1306_DISPLAYOFF      =   0xAE
.equ    SSD1306_DISPLAYON       =   0xAF

.equ    COMMAND                 =   0x00
.equ    DATA                    =   0x40


;======= Стартовая посылка по шине i2c ======================================

 i2c_start:
    push    r16					
    ldi     r16,(1<<TWINT)|(1<<TWSTA)|(1<<TWEN)  ; Выполняем посылку стартовой комбинации
    out     TWCR,r16      ; Посылаем полученный байт в TWCR
    rcall   i2c_wait      ; Ожидание формирования start в блоке TWI
    pop     r16           ; Возвращаем данные в r16 из стека
	ret
 ;======= Стоповая посылка по шине i2c ======================================
 i2c_stop:
    push    r16					
    ldi     r16,(1<<TWINT)|(1<<TWSTO)|(1<<TWEN)  ; Отправляем стоповую посылку
    out     TWCR,r16      ; Посылаем полученный байт в TWCR
    pop     r16           ; Возвращаем данные в r16 из стека
    ret
 ;======= Посылка байта информации по шине i2c ==============================
 i2c_send:
    push    r16					
    out     TWDR,r16      ; Записываем передаваемый байт в регистр TWDR
    ldi     r16,(1<<TWINT)|(1<<TWEN)  ; Формируем байт, отвечающий 
                                      ; за пересылку информационного байта
    out     TWCR,r16      ; Посылаем полученный байт в TWCR
    rcall   i2c_wait      ; Ожидание окончания пересылки байта
    pop     r16           ; Возвращаем данные в r16 из стека
    ret
 ;======= Приём информационного байта по шине i2c ===========================
 i2c_receive:
 ; Принятый байт помещается в регистр r16, поэтому рекомендуется	
 ; продумать программу так, чтобы в этот момент в нём не было 
 ; важной информации, байт не сохраняется в стеке в коде данной 
 ; процедуры
    ldi     r16,(1<<TWINT)|(1<<TWEN)|(1<<TWEA)  ; Формируем байт, отвечающий за прием 
    out     TWCR,r16      ; Посылаем полученный байт в TWCR
    rcall   i2c_wait      ; Ожидание окончания приёма байта
    in      r16,TWDR      ; Считываем полученную информацию из TWDR
    ret
 ;======= Приём последнего байта (NACK) =====================================
 i2c_receive_last:
 ; Принятый байт помещается в регистр r16, поэтому рекомендуется	
 ; продумать программу так, чтобы в этот момент в нём не было 
 ; важной информации, байт не сохраняется в стеке в коде данной 
 ; процедуры
    ldi     r16,(1<<TWINT)|(1<<TWEN) ; Формируем байт, отвечающий за прием информационного байта
    out	    TWCR,r16      ; Посылаем полученный байт в TWCR
    rcall   i2c_wait      ; Ожидание окончания приёма байта
    in      r16,TWDR      ; Считываем полученную информацию из TWDR
    ret
 ;======= Ожидание готовности TWI ===========================================
 i2c_wait:
    in      r16,TWCR      ; Загружаем значение из TWCR в r16
    sbrs    r16,TWINT     ; Функция ожидания выполняется до тех пор, пока поднят флаг 
                          ; прерывания в 1
    rjmp    i2c_wait
    ret
 ;===========================================================================
; ================= LCD_Command =============================================
LCD_Command:
;   Отрправка команды по TWI
;   tmp0    - рабочий регистр
;   CByte   - содержит ControlByte
;   DByte   - содержит DataByte

    ; Сохраняем tmp0
    push tmp0
    
    ; Отправка сигнала START
    rcall i2c_start

    ; Отправка SLA_W
    ldi tmp0, SLA_W
    rcall i2c_send

    ; Отправка ControlByte
    lds tmp0, CByte
    rcall i2c_send

    ; Отправка DataByte
    lds tmp0, DByte
    rcall i2c_send

    ; Отправка STOP
    rcall i2c_stop

    ; восстанавливаем его
    pop tmp0
    ret

LCD_Sleep:
; tmp0 - register contains set patameter
; tmp1 - temporary register
    push tmp1
    
    ldi tmp1, COMMAND
    sts CByte, tmp1
    ldi tmp1, SSD1306_DISPLAYON
    sts DByte, tmp1
    
    cpi tmp0, TRUE
    breq send0
    ldi tmp1, SSD1306_DISPLAYOFF 
    sts DByte, tmp1

send0:
    rcall LCD_Command
    pop tmp1
    ret

LCD_Clear:
;   tmp0 - clear pattern
;   tmp0 = 0x00 - empty (black) screen
;   tmp0 = 0xFF - filled (white) screen
    push tmp0
    rcall i2c_start
    ldi tmp0, SLA_W
    rcall i2c_send
    ldi tmp0, DATA
    rcall i2c_send
    

    pop tmp0
    ;ldi tmp0, 0x00
    ldi tmp3, 8
s0: ldi tmp4, 128
s1: rcall i2c_send
    dec tmp4
    brne s1
    dec tmp3
    brne s0

    rcall i2c_stop
    ret

LCD_Char:
    ret
