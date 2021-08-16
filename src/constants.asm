.equ	XTAL				=	16000000
.equ	BAUDRATE		    =	9600
.equ	DHT_SIZE	    	=	5
.equ	BITS				=	8
.equ    ASTART              =   $20 ;- код символа пробел
.equ    FONT_W              =   5
.equ    SW_RESET_CODE_LEN   =   4
.equ    RX_BUFFER_SIZE      =   32




.def	temp	= R16
.def	temp1	= R17
.def	temp2	= R18
.def	temp3	= R19	; пока не используется данной библиотекой
.def	temp4	= R20	; пока не используется данной библиотекой
.def    temp5   = R21
.def    temp6   = R22

;.def	tmp0				=	R16
;.def	tmp1				=	R17
;.def	tmp2				=	R18
;.def	tmp3				=	R19
;.def	tmp4				=	R20
;.def	tmp5				=	R21
;.def	tmp6				=	R22


; I2C error codes
.equ    I2C_SAWP            =   0b10000000
.equ    I2C_SARP            =   0b00000000
.equ    I2C_ERR_BF          =   0b00000001
.equ    I2C_ERR_NA          =   0b00000010
.equ    I2C_ERR_NK          =   0b00000100
.equ    I2C_ERR_LP          =   0b00001000
