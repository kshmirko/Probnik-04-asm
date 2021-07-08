.nolist
.includepath "/usr/local/Cellar/avra/1.4.2/include/avr/"
.include "m32def.inc"
.include "macros.asm"
.include "ssd1306m.asm"
.list
.include "constants.asm"

;=============== собственно сама программа ============================
.cseg
Reset:
    ; Start from the beginning
    .org $0000
    ; and jump to the init section
    rjmp Init
    .include "int_vectors.asm"  ; определяем векторы прерываний
    .include "int_routines.asm" ; процедуры обработки прерываний

Init:
    UARTINIT BAUDRATE           ; настройка UART 9600, 8, 1, None
    TWIINIT						; настройка TWI, 400kHz

    
; =============== Write Intro to UART =================================
;    UARTWriteStrPZ buildtime
;    UARTWriteStrPZ header
;    UARTWriteStrPZ author
; =============== Super Loop ==========================================

    rcall LCDInit
    LCD_Clear $FF
    LCD_Goto 0, 0
    LCD_PutChar 'Q'
Loop:
    rcall Read1WireData
    rcall Delay_18ms
    rjmp Loop

;================ End Program =========================================
.include "uart.asm"     ; определяем обработчики прерываний UART
.include "twi.asm"      ; и TWI	
.include "ssd1306.asm"  ; SSD1306 128x64 driver
.include "dht11_22.asm" ; подключение подпрограмм для работы с dht11/dht22
.include "symbol.asm"
.include "data.asm"     ; опредеделине глобальных переменных
