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
;   tmp0    - рабочий регистр
;   tmp1    - содержит ControlByte
;   tmp2    - содержит DataByte

    ; Отправка сигнала START
    rcall i2c_start

    ; Отправка SLA_W
    ldi tmp0, SLA_W
    rcall i2c_send

    ; Отправка ControlByte
    mov tmp0, tmp1
    rcall i2c_send

    ; Отправка DataByte
    mov tmp0, tmp2
    rcall i2c_send

    ; Отправка STOP
    rcall i2c_stop

    ret

_LCD_Clear:
;   tmp0 - clear pattern
;   tmp0 = $00 - empty (black) screen
;   tmp0 = $FF - filled (white) screen
;   так как подпрограммы работы с TWI активно используют регистр tmp0
;   сохрпняем его в стекеTWCR
    push tmp0
    rcall i2c_start
    ldi tmp0, SLA_W
    rcall i2c_send
    ldi tmp0, DATA
    rcall i2c_send

;   и вытаскиваем его оттуда, когда потребуется
    pop tmp0

    ldi tmp3, 8
s0: 
    ldi tmp4, 128
s1: 
;   забиваем паттерном tmp0 всю видеопамять SSD1306
    rcall i2c_send
    dec tmp4
    brne s1
    dec tmp3
    brne s0

    rcall i2c_stop
    ret


_LCD_PutChar:
;   выводит символ на экран
;   регистр tmp1 содержит символ для вывода на экран
;   подпрограмма ищет в таблице символов номер знака,
;   далее, копирует байты символа в память экрана
;   использует и модифицирует регистры X, tmp0, tmp1, r0, r1, tmp2    

    subi tmp1, ASTART

;   найдем теперь номер байта начаа картинки символа, для этого умножим tmp1
;   на ширину символа FONT_W
    ldi tmp2, FONT_W
    mul tmp1, tmp2

;сохраняем регистры
    push ZL
    push ZH 

;   регистровая пара r1:r0 содержит результат перемножения
;   загрузим в регистр Z адрес начала таблицы




    ldi ZL, low(symtbl)
    ldi ZH, high(symtbl)

;   добавим смещение в байтах с учетом возможного переноса разряда
    add ZL, r0
    adc ZH, r1

;   теперь Z указывает на начало изображения символа
    rcall i2c_start
    ldi tmp0, SLA_W
    rcall i2c_send
    ldi tmp0, DATA
    rcall i2c_send
    
    ldi tmp1, FONT_W

_loop_put_char:
    lpm tmp0, Z+
    rcall i2c_send

    dec tmp1
    brne _loop_put_char
    

;   insert 1 pixel separator line
    clr tmp0
    rcall i2c_send

    rcall i2c_stop
; восстанавливаем регистры
    pop ZH
    pop ZL

    ret
    

_LCD_PutStringPZ:
; печатает строку из FLASH
put_str_looppz:
    lpm r16, Z+
    cpi r16, 0

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

