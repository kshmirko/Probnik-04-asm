.ifndef __TWI__
.define __TWI__

; Работа с TWI

.equ    START           =   $08
.equ    RSTART          =   $10
.equ    SLA_W_ACK       =   $18
.equ    SLA_W_NACK      =   $20
.equ    DATA_ACK        =   $28
.equ    DATA_NACK       =   $30
.equ    SLA_W_LOST      =   $38

;==================== Start command i2c 
; Uses r16 register
i2c_start:
    outi TWCR, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
	                                            ; Clear interrupt flag (1<<TWINT)
                                                ; Set start condition (1<<TWSTA)
                                                ; Enable TWI (1<<TWEN)
                                                 
	ret

;-------------------- Restart command on the twi line
i2c_restart:
    outi TWCR, (1<<TWINT)|(1<<TWSTA)|(1<<TWEN)
    ret

;==================== send stop condition
i2c_stop:
    outi TWCR, (1<<TWINT)|(1<<TWSTO)|(1<<TWEN)
    ; Clear interrupt flag (1<<TWINT)
    ; Set stop condition (1<<TWSTO)
    ; Enable TWI (1<<TWEN)
    ret
 

;==================== Send byte over i2c
i2c_send_byte:
; A byte to send in r16
;
    out     TWDR,r16      ; Записываем передаваемый байт в регистр TWDR
    outi    TWCR, (1<<TWINT)|(1<<TWEN)
    rcall   i2c_wait_interrupt      ; Ожидание окончания пересылки байта
    ret
 
;==================== Receive byte with ack
i2c_receive_byte:
; Received byte in R16
    outi    TWCR, (1<<TWINT)|(1<<TWEN)|(1<<TWEA)
    rcall   i2c_wait_interrupt  
    in      r16,TWDR    
    ret

;==================== Receive byte with NACK (ie last byte) 
i2c_receive_lastbyte:
; received byte in R16
    outi    TWCR, (1<<TWEN)|(1<<TWINT)
    rcall   i2c_wait_interrupt      ; Ожидание окончания приёма байта
    in      r16,TWDR      ; Считываем полученную информацию из TWDR
    ret


;==================== Wait for TWINT flag setted in TWCR
i2c_wait_interrupt:
    ; постоянно опрашивает регистр TWCR на предмет установки флага TWINT

    in      r16,TWCR      ; 
    sbrs    r16,TWINT     ;  
                          ; 
    rjmp    i2c_wait_interrupt
    ret
;==================== i2c_write
i2c_write:
; R16 - SLA_ADDR
; R17 - MAILBOX
; Y -   ADDRESS OF A BUFFER
; R18 - BYTES TO WRITE
    rcall i2c_start
    lsl R16
    rcall i2c_send_byte
    mov R16, R17
    rcall i2c_send_byte
i2c_wr_l0:
    LD R16, Y+
    rcall i2c_send_byte
    dec R18
    brne i2c_wr_l0
    rcall i2c_stop
    ret


;==================== i2c_read
i2c_read:
; R16 - SLA_ADDR
; R17 - MAILBOX
; Y   - ADDRESS OF A BUFFER
; R18 - BYTES TO READ
    rcall i2c_start
    lsl R16
    rcall i2c_send_byte
    mov R16, R17
    rcall i2c_send_byte
    rcall i2c_restart
    ori R16, $01
    rcall i2c_send_byte
i2c_rd_l0:
    rcall i2c_receive_byte
    st Y+, R16
    dec R18
    brne i2c_rd_l0
    rcall i2c_stop
    ret
;===========================================================================
.endif

