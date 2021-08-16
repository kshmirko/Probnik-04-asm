.ifndef __SSD1306__MACRO__
.define __SSD1306__MACRO__


.macro LCD_Command
; отправка команды по twi в ssd1306
; LCD_Command <ControlByte> <DataByte>
; макрос прогружает стэк на 2 байта
	;push temp1
	;push temp2
	ldi temp1, @0
	ldi temp2, @1
	rcall _LCD_Command
	;pop temp2
	;pop temp1
.endm

.macro LCD_PutChar
    .set char=@0
    ldi temp1, char
    rcall _LCD_PutChar
.endmacro

.macro LCD_PutStrZ
    ldi XL, low(@0)
    ldi XH, high(@0)
    rcall _LCD_PutStringZ
.endmacro


.macro LCD_PutStrPZ

    ldi ZL, low(2*@0)
    ldi ZH, high(2*@0)

    rcall _LCD_PutStringPZ
.endmacro

.macro LCD_Sleep
; temp - register contains set patameter
; temp1 - temporary register
    .if @0=0
        LCD_Command COMMAND, SSD1306_DISPLAYOFF
    .endif

    .if @0=1
        LCD_Command COMMAND, SSD1306_DISPLAYON
    .endif
.endm

.macro LCD_Goto
    .set x=@0
    .set y=@1
    LCD_Command COMMAND, $B0 | y
    LCD_Command COMMAND, x & $f
    LCD_Command COMMAND, $10 | (x >> 4)
    SETMEM LCD_X, x
    SETMEM LCD_y, y
.endm


.macro LCD_Clear
    .set pattern=@0
    ldi temp, pattern

    rcall _LCD_Clear
.endm


.macro LCD_Mode
    .set mode = @0
    .if mode = 0
        LCD_Command COMMAND, SSD1306_NORMALDISPLAY
    .endif

    .if mode = $01
        LCD_Command COMMAND, SSD1306_INVERTDISPLAY
    .endif
.endm



.endif
