.ifndef __SSD1306_ROUTINES__
.define __SSD1306_ROUTINES__

; =====================================================================
;	SD1306 128x64 asembler driver
;		
;	List of subroutines
;	~~~~~~~~~~~~~~~~~~~
;	1. LCD_Init
;	2. LCD_Command
;	3. LCD_Clear
;	4. LCD_Goto
;	5. LCD_Mode
;	6. LCD_Sleep
;
; =====================================================================
; Address of SSD1306 is $3c
; SLA_W is ADDRESS of SSD1306 shifted left by 1 bit
; SLA_R is address of SSD1306 shifted left by 1 bit and or-ed with $01
.equ    SSD1306_ADDR            =   $3c
.equ    SLA_W                   =   SSD1306_ADDR << 1
.equ    SLA_R                   =   (SSD1306_ADDR << 1)|$01   

.equ    TRUE                    =   $01
.equ    FALSE                   =   $00

.equ    SSD1306_LCDWIDTH        =   128
.equ    SSD1306_LCDHEIGHT       =   64
.equ    SSD1306_DEFAULT_SPACE   =   5

.equ    SSD1306_DISPLAYOFF      =   $AE
.equ    SSD1306_DISPLAYON       =   $AF
.equ    SSD1306_SETDISPLAYCLOCKDIV= $D5
.equ    SSD1306_SETMULTIPLEX    =   $A8
.equ    SSD1306_SETDISPLAYOFFSET=   $D3
.equ    SSD1306_SETSTARTLINE    =   $40
.equ    SSD1306_CHARGEPUMP      =   $8D
.equ    SSD1306_MEMORYMODE      =   $20
.equ    SSD1306_SEGREMAP        =   $A0
.equ    SSD1306_COMSCANDEC      =   $C8
.equ    SSD1306_SETCOMPINS      =   $DA
.equ    SSD1306_SETCONTRAST     =   $81
.equ    SSD1306_SETPRECHARGE    =   $D9
.equ    SSD1306_SETVCOMDETECT   =   $DB
.equ    SSD1306_DISPLAYALLOW_RESUME=$A4
.equ    SSD1306_NORMALDISPLAY   =   $A6
.equ    SSD1306_INVERTDISPLAY   =   $A7
.equ    SSD1306_PAGEADDR        =   $22
.equ    SSD1306_COLUMNADDR      =   $12
.equ    COMMAND                 =   $00
.equ    DATA                    =   $40

; ================= LCD_Command =============================================
_LCD_Command: 
;   Отрправка команды в LCD по TWI
;   temp    - рабочий регистр
;   temp1    - содержит ControlByte
;   temp2    - содержит DataByte

    ; Отправка сигнала START
    rcall i2c_start

    ; Отправка SLA_W
    ldi temp, SLA_W
    rcall i2c_send_byte

    ; Отправка ControlByte
    mov temp, temp1
    rcall i2c_send_byte

    ; Отправка DataByte
    mov temp, temp2
    rcall i2c_send_byte

    ; Отправка STOP
    rcall i2c_stop

    ret

_LCD_Clear:
;   temp - clear pattern
;   temp = $00 - empty (black) screen
;   temp = $FF - filled (white) screen
;   так как подпрограммы работы с TWI активно используют регистр temp
;   сохрпняем его в стекеTWCR
    push temp
    rcall i2c_start
    ldi temp, SLA_W
    rcall i2c_send_byte
    ldi temp, DATA
    rcall i2c_send_byte

;   и вытаскиваем его оттуда, когда потребуется
    pop temp

    ldi temp3, 8
s0: 
    ldi temp4, 128
s1: 
;   забиваем паттерном temp всю видеопамять SSD1306
    rcall i2c_send_byte
    dec temp4
    brne s1
    dec temp3
    brne s0

    rcall i2c_stop
    ret


_LCD_PutChar:
;   выводит символ на экран
;   регистр temp1 содержит символ для вывода на экран
;   подпрограмма ищет в таблице символов номер знака,
;   далее, копирует байты символа в память экрана
;   использует и модифицирует регистры X, temp, temp1, r0, r1, temp2    
;   temp - регистр для отправки данных по i2c
;   temp1 - временный регистр содержит выводимый символ, а также 
;          используется как индекс в цикле
;   temp2 - хранит ширину символа (FONT_W)
;   XL, XH - адрес таблицы символов в памяти FLASH  
;   ZH, ZL - зарезервировано, не должно изменяться по завершению подпрограммы
    subi temp1, ASTART

;   найдем теперь номер байта начала картинки символа, для этого умножим temp1
;   на ширину символа FONT_W с использованием промежуточного регистра temp2
    ldi temp2, FONT_W
    mul temp1, temp2

;   сохраняем адрес таблицы в стеке
    mov ZL, XL
    mov ZH, XH 

;   добавим смещение в байтах с учетом возможного переноса разряда
    add ZL, r0
    adc ZH, r1

;   теперь Z указывает на начало изображения символа
    rcall i2c_start
    ldi temp, SLA_W
    rcall i2c_send_byte
    ldi temp, DATA
    rcall i2c_send_byte
    
    ldi temp1, FONT_W

_loop_put_char:
    lpm temp, Z+
    rcall i2c_send_byte

    dec temp1
    brne _loop_put_char
    

;   insert 1 pixel separator line
    clr temp
    rcall i2c_send_byte

    rcall i2c_stop

    ret
    

_LCD_PutStringPZ:
;   печатает строку из FLASH
;   загружаем таблицу символов в регистр Z
    ldi XL, low(2*symtbl)
    ldi XH, high(2*symtbl)
put_str_looppz:
    lds ZH, str_addr+0
    lds ZL, str_addr+1
    lpm r17, Z+
    sts str_addr+0, ZH
    sts str_addr+1, ZL
    cpi r17, 0

    breq exit_put_strpz

    rcall _LCD_PutChar

    rjmp put_str_looppz

exit_put_strpz:
    ret

_LCD_PutStringZ:
; печатает строку из SRAM
; строка должна заканчиваться символом с кодом 0.
; строка помещается в регистр X.
put_str_loop:
    ld r16, X+
    cpi r16, 0

    breq exit_put_str
    
    rcall _LCD_PutChar
    
    rjmp put_str_loop

exit_put_str:
    ret


LCDInit:
    LCD_Command COMMAND, SSD1306_DISPLAYOFF
    LCD_Command COMMAND, SSD1306_SETDISPLAYCLOCKDIV
    LCD_Command COMMAND, $80
    LCD_Command COMMAND, SSD1306_SETMULTIPLEX
    LCD_Command COMMAND, $3F
    LCD_Command COMMAND, SSD1306_SETDISPLAYOFFSET
    LCD_Command COMMAND, $00
    LCD_Command COMMAND, SSD1306_SETSTARTLINE|$00
    LCD_Command COMMAND, SSD1306_CHARGEPUMP
    LCD_Command COMMAND, $14
    LCD_Command COMMAND, SSD1306_MEMORYMODE
    LCD_Command COMMAND, $00
    LCD_Command COMMAND, SSD1306_SEGREMAP|$01
    LCD_Command COMMAND, SSD1306_COMSCANDEC
    LCD_Command COMMAND, SSD1306_SETCOMPINS
    LCD_Command COMMAND, $12
    LCD_Command COMMAND, SSD1306_SETCONTRAST
    LCD_Command COMMAND, $CF
    LCD_Command COMMAND, SSD1306_SETPRECHARGE
    LCD_Command COMMAND, $F1
    LCD_Command COMMAND, SSD1306_SETVCOMDETECT
    LCD_Command COMMAND, $40
    LCD_Command COMMAND, SSD1306_DISPLAYALLOW_RESUME
    LCD_Command COMMAND, SSD1306_NORMALDISPLAY
    LCD_Command COMMAND, SSD1306_DISPLAYON
    ret

Delay_10ms:
; Assembly code auto-generated
; by utility from Bret Mulvey
; Delay 159 993 cycles
; 9ms 999us 562 1/2 ns
; at 16 MHz

    ldi  r20, 208
    ldi  r21, 200
K1: dec  r21
    brne K1
    dec  r20
    brne K1

    ret
   

.endif


;--A---  0
;-A-A--  1
;A---A-  2
;A---A-  3
;A---A-  4
;AAAAA-  5
;A---A-  6
;A---A-  7
;$FC,$22,$1,$22,$FC,$0

