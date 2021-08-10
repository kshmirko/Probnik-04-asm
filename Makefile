MK=m32
LFuse=
HFuse=

# Более глобальные переменные. 
ASM=avra
ISP=avrdude
INCLUDEDIR=/usr/local/Cellar/avra/1.4.2/include/avr/
FILE=main

compile:
		$(ASM) -I $(INCLUDEDIR) -l $(FILE).lst -d $(FILE).dhex $(FILE).asm 2>&1|grep -v PRAGMA
program: $(FILE).hex
		$(ISP) -c usbasp -p $(MK)  -U flash:w:$(FILE).hex:i 
		#-U lfuse:w:$(LFuse):m -U hfuse:w:$(HFuse):m
clean:
		rm -f $(FILE).cof $(FILE).eep.hex $(FILE).hex $(FILE).obj *~
size:
		avr-size  $(FILE).hex

