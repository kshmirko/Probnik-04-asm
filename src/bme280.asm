; Subroutines for interfacing with bme280
;

.equ    BME280_ADDR =   $77
.equ    BME280_W    =   (BME280_ADDR<<1)|0
.equ    BME280_R    =   (BME280_ADDR<<1)|1


BME280_ReadID:
    rcall i2c_start
    ldi tmp0, BME280_W
    rcall i2c_send_byte
    ldi tmp0, $D0
    rcall i2c_send_byte
    rcall i2c_start

    ldi tmp0, BME280_R
    rcall i2c_send_byte
    rcall i2c_receive_lastbyte
    rcall i2c_stop
    sts BME280_Data, r16
    ret
    
