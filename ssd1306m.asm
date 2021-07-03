.ifndef __SSD1306__MACRO__
.define __SSD1306__MACRO__


.macro LCD_Command
; отправка команды по twi в ssd1306
; LCD_Command <ControlByte> <DataByte>
; макрос прогружает стэк на 2 байта
	;push tmp1
	;push tmp2
	ldi tmp1, @0
	ldi tmp2, @1
	rcall _LCD_Command
	;pop tmp2
	;pop tmp1
.endm


.macro LCD_Sleep
; tmp0 - register contains set patameter
; tmp1 - temporary register
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
    LCD_Command COMMAND, 0xB0 | y
    LCD_Command COMMAND, x & 0xf
    LCD_Command COMMAND, 0x10 | (x >> 4)
    SETMEM LCD_X, x
    SETMEM LCD_y, y
.endm


.macro LCD_Clear
    .set pattern=@0
    ldi tmp0, pattern

    rcall _LCD_Clear
.endm


.macro LCD_Mode
    .set mode = @0
    .if mode = 0
        LCD_Command COMMAND, SSD1306_NORMALDISPLAY
    .endif

    .if mode = 0x01
        LCD_Command COMMAND, SSD1306_INVERTDISPLAY
    .endif
.endm



.endif
