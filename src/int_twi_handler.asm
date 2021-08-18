.ifndef __I2C_INT_HANDLER__
.define __I2C_INT_HANDLER__

.dseg
; TWI variables
i2c_slave_addr: .byte   1           ; device address
i2c_err:        .byte   1           ; error var
do_i2c:         .byte   1           ; i2c task
i2c_index_data: .byte   1           ; shift from the beginning of transmitted 
                                    ; data (input or output)
i2c_index_data_end: .byte 1         ; number of bytes to send/receive
i2c_index_PageAddrL: .byte 1        ; 
i2c_index_PageAddrH: .byte 1        ;
i2c_busy:       .byte 1             ; if i2c_busy==1 TWI bus is busy
i2c_buffer_addr_in:  .byte 2        ; address of the buffer to receve data 
                                    ;           0-byte - low byte of address, 
                                    ;           1-byte - high byte of address
i2c_buffer_addr_out: .byte 2        ; address of the buffer to send data

.cseg


TWI_HANDLER:
    PUSHF
    push temp2
    PUSHXYZ

    ldi ZH, high(twi_table)
    ldi ZL, low(twi_table)

    clr r0
    INR temp, TWSR
    ; right shift 3 bits (remove TWPS0 and TWPS1 bits and reserved one)
    lsr temp
    lsr temp 
    lsr temp

    ADZR temp

    ; call routine at address ZH:ZL
    icall

    ; restore temp register and SREG
    POPXYZ
    pop temp2
    POPF
    reti

;=============================================================================
; Table of redirection according to TWSR
;=============================================================================
twi_table:  
    rjmp twi_00; $00 = FAIL
    rjmp twi_08; $08 = START
    rjmp twi_10; $10 = RESTART
    rjmp twi_18; $18 = SLA+W ACK
    rjmp twi_20; $20 = SLA+W NACK
    rjmp twi_28; $28 = SEND ACK
    rjmp twi_30; $30 = SEND NACK
    rjmp twi_38; $38 = COLLISION
    rjmp twi_40; $40 = SLA+R ACK
    rjmp twi_48; $48 = SLA+R NACK
    rjmp twi_50; $50 = RECV ACK
    rjmp twi_58; $58 = RECV NACK


;=============================================================================
;I2C subroutines
; twi_08, twi_10 - main entrance points
;=============================================================================
twi_00: ; FAIL
    ldi temp, I2C_ERR_BF
    sts i2c_err, temp
    sts i2c_busy, r0
    OUTI TWCR, 0<<TWSTA|1<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    ret
twi_08: ; Start
twi_10: ; Restart

    INR temp2, i2c_slave_addr
    lsl temp2
    INR temp, do_i2c
    tst temp
    brne twi_10_1
    ori temp, $01
    twi_10_1:
        out TWDR, temp2
    OUTI TWCR, 0<<TWSTA|0<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    
    ret

twi_18:
    RAM_DATA_IN_Z i2c_buffer_addr_out
    lds temp, i2c_index_data
    ADZR temp
    ld temp2, Z
    inc temp
    sts i2c_index_data, temp
    out TWDR, temp2
    OUTI TWCR, 0<<TWSTA|0<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    ret

; SLA+W has been send, NACK received
twi_20:
    sts i2c_busy, r0
    OUTI i2c_err, I2C_ERR_NA
    OUTI TWCR, 0<<TWSTA|1<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    ret

; SLA+W has been send, ACK received
twi_28:
    lds temp, i2c_index_data
    lds temp2, i2c_index_data_end
    cp temp, temp2
    brne send_out_28

    OUTI TWCR, 0<<TWSTA|1<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<TWIE
    sts i2c_busy, r0
    ret

    send_out_28:
        rjmp twi_18
    ret


twi_30:
    OUTI i2c_err, I2C_ERR_NK
    sts i2c_busy, r0
    OUTI TWCR, 0<<TWSTA|1<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    ret

twi_38:
    OUTI i2c_err, I2C_ERR_LP
    sts i2c_busy, r0
    OUTI TWCR, 0<<TWSTA|1<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    ret

twi_40:
    lds temp, i2c_index_data_end
    cpi temp, $01
    brne send_ack_twi_40
    OUTI TWCR, 0<<TWSTA|0<<TWSTO|1<<TWINT|0<<TWEA|1<TWEN|1<<TWIE
    ret
    send_ack_twi_40:
        OUTI TWCR, 0<<TWSTA|0<<TWSTO|1<<TWINT|1<<TWEA|1<TWEN|1<<TWIE

    ret

twi_48:
    OUTI i2c_err, I2C_ERR_NA
    sts i2c_busy, r0
    OUTI TWCR, 0<<TWSTA|1<<TWSTO|1<<TWINT|0<<TWEA|1<TWEN|1<<TWIE
    ret

twi_50:
    in temp2, TWDR
    RAM_DATA_IN_Z i2c_buffer_addr_in
    lds temp, i2c_index_data
    ADZR temp
    st Z, temp2
    inc temp
    sts i2c_index_data, temp
    inc temp
    lds temp2, i2c_index_data_end
    cp temp, temp2
    brne send_ack_twi_50
    OUTI TWCR, 0<<TWSTA|0<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    ret
    send_ack_twi_50:
        OUTI TWCR, 0<<TWSTA|0<<TWSTO|1<<TWINT|1<<TWEA|1<<TWEN|1<<TWIE
    ret

twi_58:
    in temp2, TWDR
    RAM_DATA_IN_Z i2c_buffer_addr_in
    lds temp, i2c_index_data
    ADZR temp
    st Z, temp2
    OUTI TWCR, 0<<TWSTA|1<<TWSTO|1<<TWINT|0<<TWEA|1<<TWEN|1<<TWIE
    sts i2c_busy, r0
    ret

.endif

