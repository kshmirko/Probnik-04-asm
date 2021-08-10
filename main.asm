.nolist
.includepath "/usr/local/Cellar/avra/1.4.2/include/avr/"
.include "m32def.inc"
.include "src/macros.asm"
.include "src/ssd1306m.asm"
.list
.include "src/constants.asm"

;=============== собственно сама программа ============================
.cseg
Reset:
    ; Start from the beginning
    .org $0000
    ; and jump to the init section
    rjmp Init
    .include "src/int_vectors.asm"  ; определяем векторы прерываний
    .include "src/int_routines.asm" ; процедуры обработки прерываний

Init:
    UARTINIT BAUDRATE           ; настройка UART 9600, 8, 1, None
    TWIINIT						; настройка TWI, 100kHz

    
; =============== Write Intro to UART =================================
;    UARTWriteStrPZ buildtime
;    UARTWriteStrPZ header
;    UARTWriteStrPZ author
; =============== Super Loop ==========================================

    rcall LCDInit
Loop:
    rcall Read1WireData
    rcall Delay_18ms
    rjmp Loop

;================ End Program =========================================
.include "src/uart.asm"     ; определяем обработчики прерываний UART
.include "src/twi.asm"      ; и TWI	
.include "src/ssd1306.asm"  ; SSD1306 128x64 driver
.include "src/dht11_22.asm" ; подключение подпрограмм для работы с dht11/dht22
.include "src/bme280.asm"   ; подключение BME280
.include "src/ccs811.asm"   ; CCs811 Driver
.include "src/symbol.asm"   ; symbol table
.include "src/data.asm"     ; global variables in SRAM
