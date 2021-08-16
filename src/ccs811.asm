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
.equ    APP_START           =   $F4     ; write 0 bytes

.equ    HW_ID_VALUE         =   $81

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

.equ    STARTUP_OK          =   $00
.equ    STARTUP_WRONG_HWID  =   $01
.equ    STARTUP_APP_INVALID =   $02
.equ    STARTUP_FW_INVALID  =   $04

.equ    CCS811_STATUS_ERROR =   $01
.equ    CCS811_STATUS_DATA_RDY =    $08
.equ    CCS811_STATUS_DATA_RDY_BIT = 3
.equ    CCS811_STATUS_APP_VALID=    $10
.equ    CCS811_STATUS_FW_MODE   =   $80


;==================== Startup CCS811
ccs811_startup:
; R18 return status
    ;read HWID 
    I2C_READ_BUFFER CCS811_ADDR,  HW_ID, CCS811_DATA, 1
    lds R16, CCS811_DATA
    ; if HWID!=HW_ID_VALUE return wrong_HWID
    cpi R16, HW_ID_VALUE
    brne ccs811_wrong_hwid
    
    ;read status
    I2C_READ_BUFFER CCS811_ADDR, STATUS, CCS811_DATA, 1
    lds R16, CCS811_DATA
    andi R16, CCS811_STATUS_APP_VALID
    ; if !(STATUS & (1<<CCS811_STATUS_APP_VALID))
    breq ccs811_app_invalid

    I2C_WRITE_BUFFER CCS811_ADDR, APP_START,  CCS811_DATA, 0
    I2C_READ_BUFFER CCS811_ADDR, STATUS, CCS811_DATA, 1
    
    lds R16, CCS811_DATA

    ; if !(STATUS&(1<<CCS811_STATUS_FW_MODE)
    andi R16, 1<<CCS811_STATUS_FW_MODE
    breq ccs811_fw_invalid

    ldi R16, DRIVE_MODE_60SEC
    I2C_WRITE_BUFFER CCS811_ADDR, MEAS_MODE, CCS811_DATA, 1
    ldi R18, STARTUP_OK 
    rjmp do_exit

ccs811_wrong_hwid:
    ldi R18, STARTUP_WRONG_HWID 
    rjmp do_exit
ccs811_app_invalid:
    ldi R18, STARTUP_APP_INVALID
    rjmp do_exit
ccs811_fw_invalid:
    ldi R18, STARTUP_FW_INVALID
    rjmp do_exit
do_exit:    
    ret


;==================== pooling data from CCS811
ccs811_pooldata:
; when returns from subroutine R16 contain return code
; R16 = 0 - data is not ready
; R16 = 1 - data is ready and successfully read from CCS811 into CCS811_DATA
; testing status register for CCS811_STATUS_DATA_RDY_BIT is set
; if false exit with R16=1
; else readout measuremens and exit with R16=0
    I2C_READ_BUFFER CCS811_ADDR, STATUS, CCS811_DATA, 1
    lds R16, CCS811_DATA

    ; test for CCS811_STATUS_DATA_RDY_BIT is set
    ; if it is not set, zero flag will set
    andi R16, CCS811_STATUS_DATA_RDY
    
    breq pooling_exit
    I2C_READ_BUFFER CCS811_ADDR, ALG_RESULT_DATA, CCS811_DATA, 8
    ldi R16, $01
pooling_exit:
    ret

.endif


sw_reset_code: .db $11, $E5, $72, $8A

;==================== Send software reset sequence
ccs811_swreset:
    ; Send software reset command to CCS811
    ; first of all load sw reset sequence into ccs811_data
    ; need to be optimized

    ldi ZL, Low(sw_reset_code<<1)
    ldi ZH, High(sw_reset_code<<1)

    ldi XL, Low(CCS811_DATA)
    ldi XH, High(CCS811_DATA)

    ; load 4 bytes from program memory to SRAM
    ldi R16, SW_RESET_CODE_LEN

_sw_reset_load:
    lpm R17, Z+
    st X+, R17
    dec R17
    brne _sw_reset_load
    
    ; sent sw reset command to CCS811
    I2C_WRITE_BUFFER CCS811_ADDR, SW_RESET, CCS811_DATA, SW_RESET_CODE_LEN

    ret


