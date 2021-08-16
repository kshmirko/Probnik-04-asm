.nolist
.includepath "/usr/local/Cellar/avra/1.4.2/include/avr/"
.include "m32def.inc"
.include "src/macros.asm"
.include "src/ssd1306m.asm"
.list
.include "src/constants.asm"

;=============== собственно сама программа ============================
.cseg
; Start from the beginning
    .org $0000
Reset:
   ; and jump to the init section
    rjmp Init
    .include "src/int_vectors.asm"  ; interupt vectors
    .include "src/int_routines.asm" ; and routines

Init:
    RAMFLUSH 
    GPRFLUSH
    StackInit RAMEND
    UARTINIT_Syncro BAUDRATE, 'N', 1           ; настройка UART 9600, 8, 1, None
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
.include "src/uart.asm"     ; UART driver
.include "src/twi.asm"      ; TWIi driver	
.include "src/ssd1306.asm"  ; SSD1306 128x64 driver
.include "src/dht11_22.asm" ; driver for dht11/dht22
.include "src/bme280.asm"   ; driver for BME280
.include "src/ccs811.asm"   ; CCS811 Driver
.include "src/symbol.asm"   ; symbol table
.include "src/data.asm"     ; global variables in SRAM

