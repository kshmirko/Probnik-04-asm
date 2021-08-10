.ifndef __CCS811__
.define __CCS811__

;   Driver for CCS811 CO2 sensor
;   I2C interface
;  


; Mailboxes
.equ    STATUS              =   $00     ;Read 1 byte
.equ    MEAS_MODE           =   $01     ;Read/Write 1 byte
.equ    ALG_RESULT_DATA     =   $02     ;Read 8 bytes
.equ    RAW_DATA            =   $03     ;Read 2 bytes
.equ    ENV_DATA            =   $05     ;Write 4 bytes
.equ    THRESHOLD           =   $10     ;Write 5 bytes
.equ    BASELINE            =   $11     ;Read/Write 2 bytes
.equ    HW_ID               =   $20     ;REad 1 byte
.equ    HV_VERSION          =   $21     ;Read 1 byte
.equ    FW_Boot_Version     =   $23     ;Read 2 byte
.equ    FW_App_Version      =   $24     ;Read 2 byte
.equ    ERROR_ID            =   $E0     ;Read 1 byte
.equ    SW_RESET            =   $FF     ;Write 4 bytes

; ERROR_ID REgister description
.equ    MSG_INVALID         =   $01
.equ    READ_REG_INVALID    =   (MSG_INVALID<<1)
.equ    MEASMODE_INVALID    =   (MSG_INVALID<<2)
.equ    MAX_SESISTANCE      =   (MSG_INVALID<<3)
.equ    HEATER_FAULT        =   (MSG_INVALID<<4)
.equ    HEATER_SUPPLY       =   (MSG_INVALID<<5)

.equ    CCS811_ADDR         =   $5A
.equ    CCS811_SLA_W        =   (CCS811_ADDR<<1)
.equ    DRIVE_MODE_IDLE     =   $00
.equ    DRIVE_MODE_1SEC     =   $10
.equ    DRIVE_MODE_10SEC    =   $20
.equ    DRIVE_MODE_60SEC    =   $30
.equ    INTERRUPT_DRIVEN    =   $08
.equ    THRESHOLD_ENABLED   =   $04

.equ    CCS811_BUFSIZE      =   8

.endif

