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
; Address of SSD1306 is 0x3c
; SLA_W is ADDRESS of SSD1306 shifted left by 1 bit
; SLA_R is address of SSD1306 shifted left by 1 bit and or-ed with 0x01
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
;   Отрправка команды по TWI
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
;   tmp0 = 0x00 - empty (black) screen
;   tmp0 = 0xFF - filled (white) screen
    push tmp0
    rcall i2c_start
    ldi tmp0, SLA_W
    rcall i2c_send
    ldi tmp0, DATA
    rcall i2c_send
    pop tmp0

    ldi tmp3, 8
s0: ldi tmp4, 128
s1: rcall i2c_send
    dec tmp4
    brne s1
    dec tmp3
    brne s0

    rcall i2c_stop
    ret


;LCD_Init:
; Инициализация LCD    
;    LCD_Command COMMAND, SSD1306_DISPLAYOFF
;    LCD_Command COMMAND, SSD1306_SETDISPLAYCLOCKDIV
;    LCD_Command COMMAND, $80
;    LCD_Command COMMAND, SSD1306_SETMULTIPLEX
;    LCD_Command COMMAND, $3F
;    LCD_Command COMMAND, SSD1306_SETDISPLAYOFFSET
;    LCD_Command COMMAND, $00
;    LCD_Command COMMAND, SSD1306_SETSTARTLINE | $00
;    LCD_Command COMMAND, SSD1306_CHARGEPUMP
;    LCD_Command COMMAND, $14
;    LCD_Command COMMAND, SSD1306_MEMORYMODE   
;    LCD_Command COMMAND, $00
;    LCD_Command COMMAND, SSD1306_SEGREMAP | $01
;    LCD_Command COMMAND, SSD1306_COMSCANDEC
;    LCD_Command COMMAND, SSD1306_SETCOMPINS
;    LCD_Command COMMAND, $12
;    LCD_Command COMMAND, SSD1306_SETCONTRAST
;    LCD_Command COMMAND, $CF
;    LCD_Command COMMAND, SSD1306_SETPRECHARGE
;    LCD_Command COMMAND, $F1
;    LCD_Command COMMAND, SSD1306_SETVCOMDETECT
;    LCD_Command COMMAND, $40
;    LCD_Command COMMAND, SSD1306_DISPLAYALLOW_RESUME 
;    LCD_Command COMMAND, SSD1306_DISPLAYON
;    ret

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
    LCD_Command COMMAND, SSD1306_SEGREMAP|$00
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

