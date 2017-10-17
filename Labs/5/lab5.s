


# we use sensor port 4, sensor port 0 also motor port 0
.equ ADDR_JP1, 0xFF200060 
.equ LED, 0xff200000
.equ ADDR_JP1_IRQ, 0x800 
.equ RED_LEDS, 0xFF200000

.global _start
_start: 	
    movia sp, 4000000 # init sp

    movia r16, ADDR_JP1
    movia r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs 
    stwio r10, 4(r16)
  
    movia r10, 0xffffffff # stop everything
	stwio r10, 0(r16)
	
	# and set sensor 0 to threshold to 5 and enable motor
	movia r10, 0xfabffbfe
	stwio r10, 0(r16)

	# and set sensor 1 to threshold to 5 and enable motor
	movia r10, 0xfabfeffe
	stwio r10, 0(r16)

	# turn to state mode
	movia r11, 0xfadffffe
	stwio r11, 0(r16)
	
	movia r11, 0xFFFFFFFF 
	stwio r11, 12(r16) # ACK intrupt 
	
	movia r9, 0x18000000 # enable interrupt
	stwio r9, 8(r16)

	movia r8, ADDR_JP1_IRQ # enable interrupt 
	wrctl ctl3, r8

	movia r8, 1
	wrctl ctl0, r8 # enable global interrupts 

LOOP:
	br LOOP

.section .exceptions, "ax"

HANDLER:
	addi sp, sp, -8 # store registers
	stw r2, 0(sp)
	stw r3, 4(sp)

	rdctl et, ctl4
	andi et, et, 0x800 # check if interrupt pending from IRQ11	
	movia r2, ADDR_JP1_IRQ
	and r2, r2, et 
	beq r2, r0, IntrExit # if not the one we want, exit


SensorIntrHandle:
	movia r2, ADDR_JP1
	ldwio et, 12(r2) 
	movia r3, 0x8000000
	and et, et, r3 # check if it's sensor 0
	bne et, r0, Sensor0Action
	
	ldwio et, 12(r2) 
	movia r3, 0x10000000
	and et, et, r3 # check if it's sensor 1
	bne et, r0, Sensor1Action

IntrExit:
	movia r2, ADDR_JP1
	movia r3, 0xFFFFFFFF 
	stwio r3, 12(r2) # ACK intrupt
 
	ldw r2, 0(sp)
	ldw r3, 4(sp) 
	addi sp, sp, 8 # restore registers
	subi ea, ea, 4 # adjust exception address (where we should return) and return with eret
	eret 

Sensor0Action:
	movia et, 0xFFFFFFFF
	movia r2, RED_LEDS 
	stwio et, 0(r2) # turn on LED
	movia r3, 100000 # timer counter
	br sleep

Sensor1Action:
	movia et, 0xFFFF
	movia r2, RED_LEDS
	stwio et, 0(r2) # turn on LED
	movia r3, 100000 # timer counter
	br sleep

sleep:
	subi r3, r3, 1
	bne r3, r0, sleep
	stwio r0, 0(r2) # turn off LED
	br IntrExit
