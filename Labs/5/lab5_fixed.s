# we use sensor port 4, sensor port 0 also motor port 0
.equ ADDR_JP1, 0xFF200060 
.equ LED, 0xff200000
.equ ADDR_JP1_IRQ, 0x800 
.equ RED_LEDS, 0xFF200000
.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ HIGH_FREQ, 64
.equ LOW_FREQ, 128

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
	addi sp, sp, -28 # store registers
	stw r16, 4(sp)
	stw r17, 8(sp)
	stw r18, 12(sp)
	stw r19, 16(sp)
	stw r20, 20(sp)
	stw r21, 24(sp)

	rdctl et, ctl4
	andi et, et, 0x800 # check if interrupt pending from IRQ11	
	movia r16, ADDR_JP1_IRQ
	and r16, r16, et 
	beq r16, r0, IntrExit # if not the one we want, exit


SensorIntrHandle:
	movia r16, ADDR_JP1
	ldwio et, 12(r16) 
	movia r17, 0x8000000
	and et, et, r17 # check if it's sensor 0
	bne et, r0, Sensor0Action
	
	ldwio et, 12(r16) 
	movia r17, 0x10000000
	and et, et, r17 # check if it's sensor 1
	bne et, r0, Sensor1Action

IntrExit:
	movia r16, ADDR_JP1
	movia r17, 0xFFFFFFFF 
	stwio r17, 12(r16) # ACK intrupt

	ldw r16, 4(sp)
	ldw r17, 8(sp)
	ldw r18, 12(sp)
	ldw r19, 16(sp)
	ldw r20, 20(sp)
	ldw r21, 24(sp)
	addi sp, sp, 28 # store registers
	subi ea, ea, 4 # adjust exception address (where we should return) and return with eret
	eret 

Sensor0Action:
	
	movia et, 0x1 # LED action: first LED on
	movia r19, HIGH_FREQ # audio action
	br sound_and_led

Sensor1Action:
	movia et, 0x2 # LED action: second LED on
	movia r19, LOW_FREQ # audio action
	br sound_and_led

sound_and_led:
	movia r16, RED_LEDS 
	stwio et, 0(r16) # turn on LED

    movia r16, ADDR_AUDIODACFIFO
    movia et, 0x10000000 # volumn

	movia r17, 50000 # timer counter
    mov r18, r19

waitforspace:
	ldwio r20, 4(r16)
    andhi r21, r20, 0xFF00 # check for if there is space in FIFO queue
    beq r21, r0, waitforspace
    andhi r21, r20, 0xFF # same as above
    beq r21, r0, waitforspace
    
writesample:
	beq r17, r0, end
	stwio et, 8(r16) # write to FIFO queue
    stwio et, 12(r16)
    subi r18, r18, 1 # decrement frequency counter
	subi r17, r17, 1 # decrement overall counter
    bne r18, r0, waitforspace

inverted:
	mov r18, r19 # reset frequency counter
    sub et, r0, et # reverse the volume, for a sound save
    br waitforspace
    
end:
	movia r16, RED_LEDS
	stwio r0, 0(r16) # turn off LED
	br IntrExit

