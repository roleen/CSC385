.equ JTAG_UART_ADDR, 0x10001020

.global _start
_start:
    movia sp, 0x4000000 # init sp

    movia r4, 0x00
    call WriteOneByteToUART
	
    movia r4, 0x04
    call WriteOneByteToUART
    movia r4, 127
    call WriteOneByteToUART 
    movia r4, 10000000
    call timeout # accelerate at 100 for at least 1 seconds, change it maybe 



main_loop:
	call ReadSensorsAndSpeed
	
	movi r8, 50
	blt r3, r8, turns
	movia r4, 0x04
    call WriteOneByteToUART
    movia r4, -80
    call WriteOneByteToUART  	
	
turns:
    movi r8, 0x1f
    beq r2, r8, steer_straight     
    movi r8, 0x1e
    beq r2, r8, steer_right    
    movi r8, 0x1c
    beq r2, r8, steer_hardright     
    movi r8, 0x0f
    beq r2, r8, steer_left    
    movi r8, 0x07
    beq r2, r8, steer_hardleft    
    br main_loop

steer_straight:
	movia r4, 0
    call steer
	
	movi r9, 40
	blt r3, r9, speed_up
	br main_loop

steer_right:
    movia r4, 80
    call steer

	movi r9, 25
	bgt r3, r9, slow_down
	br main_loop	

steer_hardright:
    movia r4, 127
    call steer

	movi r9, 20
	bgt r3, r9, slow_down
	br main_loop

steer_left:
    movia r4, -80
    call steer

	movi r9, 25
	bgt r3, r9, slow_down 
	br main_loop

steer_hardleft:
    movi r4, -127
    call steer

	movi r9, 20
	bgt r3, r9, slow_down
	br main_loop	

steer:
    addi sp, sp, -8
    stw ra, 0(sp)
    stw r16, 4(sp)
    mov r16, r4

    movia r4, 0x05
    call WriteOneByteToUART 
    mov r4, r16
    call WriteOneByteToUART 

    ldw ra, 0(sp)
    ldw r16, 4(sp)
    addi sp, sp, 4
    ret

ReadSensorsAndSpeed:
    addi sp, sp, -12
    stw ra, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)

valid_data_poll:
    movia r4, 0x02
    call WriteOneByteToUART
    call ReadOneByteFromUART
    bne r2, r0, valid_data_poll

    call ReadOneByteFromUART
    mov r17, r2
    call ReadOneByteFromUART
    mov r18, r2
    
    mov r2, r17 # save to return value
    mov r3, r18

    ldw ra, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    addi sp, sp, 12
    ret

ReadOneByteFromUART:
    movia r10, JTAG_UART_ADDR
    ldwio r8, 0(r10)
    andi r9, r8, 0x8000 # check if valid
    beq r9, r0, ReadOneByteFromUART
    andi r2, r8, 0xFF # mask other bits
    ret

WriteOneByteToUART:
    movia r10, JTAG_UART_ADDR
    ldwio r8, 4(r10) 
    srli  r8, r8, 16 # check if there is space
    beq   r8, r0, WriteOneByteToUART /* If this is 0 (branch true), data cannot be sent */
    andi  r9, r4, 0xFF # make sure only a byte got send  
    stwio r9, 0(r10) 
    ret

speed_up:
	movia r4, 0x04
    call WriteOneByteToUART
    movia r4, 127
    call WriteOneByteToUART
	br main_loop 

slow_down:
	movia r4, 0x04
    call WriteOneByteToUART
    movia r4, -50
    call WriteOneByteToUART 
	br main_loop
	
timeout:
    movia r8, 0xFF202000  # timer 1 addr
    srli r9, r4, 16 # get the higher 16 bits of arugment by shift right 16 bits
    slli r10, r4, 16 
    srli r10, r10, 16 # get the lower 16 bits of arugment by shift left than shift right 16 bits

    stwio r10, 8(r8)                          # Set the period to be 1000 clock cycles 
    stwio r9, 12(r8)

    stwio r0, 0(r8) # clear timeout bit 
    movui r11, 4
    stwio r11, 4(r8)                          # Start the timer without continuing or interrupts 

LOOP:
    ldwio r12, 0(r8)
    andi r12, r12, 1 # only check bit 0
    movi r13, 1
    bne r12, r13, LOOP

    stwio r0, 0(r8) # clear timeout bit 
    ret 
