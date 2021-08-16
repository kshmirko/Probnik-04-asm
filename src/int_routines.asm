.dseg
; UART variables
rx_buffer:      .byte   RX_BUFFER_SIZE
rx_wr_index:    .byte   1
rx_rd_index:    .byte   1
rx_counter:     .byte   1
rx_buffer_overflow: .byte 1


.cseg

.equ FRAMING_ERROR      =   (1<<FE)
.equ PARITY_ERROR       =   (1<<UPE)
.equ DATA_OVERRUN       =   (1<<DOR)



UART_RX_ISR:
    ; read status and data from UART
    PUSHF
    push R17
    push R18
    push R19
    push XL
    push XH

    in R17, UCSRA
    in R18, UDR

    
    andi R17, FRAMING_ERROR|PARITY_ERROR|DATA_OVERRUN
    ; if any of errors occurs - exit isr
    brne uart_rx_exit

    ; save byte to buffer
    ldi XL, low(rx_buffer)
    ldi XH, high(rx_buffer)

    ldi R19, rx_wr_index
    
    clr R17
    add XL, R19
    adc XH, R17

    st X, R18

    inc R19
    sts rx_wr_index, R19


;   test if index at the end of a buffer
    cpi R19, RX_BUFFER_SIZE
    brne uart_rx_l1
    ; if true, clear rx_wr_index
    sts rx_wr_index, R17
uart_rx_l1:
    ldi R19, rx_counter
    inc R19
;   test for rx_counter==RX_BUFFER_SIZE
    cpi R19, RX_BUFFER_SIZE
    brne uart_rx_exit
;   if true, clear rx_counter
    sts rx_counter, R17
    ldi R17, 1
;   set overflow byte
    sts rx_buffer_overflow, R17
uart_rx_exit:

    pop XH
    pop XL
    pop R19
    pop R18
    pop R17
    POPF
    reti


.include "src/int_twi_handler.asm"
