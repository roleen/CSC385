.equ ADDR_JP1, 0xFF200060 

.global _start
_start:
    movia sp, 7FFFFFFF # init sp

    movia r16, ADDR_JP1
    movia r10, 0x07f557ff     # set direction for motors and sensors to output and sensor data register to inputs
    stwio r10, 4(r16)
    movia r10, 0xfffffffc # turn motor on and forward
    stwio r10, 0(r16)

LOOP:   
    call read_0
    addi r17, r2, 0
    call read_4
    addi r18, r2, 0
    beq r17, r18, LOOP
    bgt r17, r18, TURN_FORWARD # TODO: figure out the actual direciton
    bgt r18, r17, TURN_REVERSE

TURN_FORWARD:
    movia r10, 0xfffffffc
    stwio r10, 0(r16)
    br LOOP

TURN_REVERSE:
    movia r10, 0xfffffffd
    stwio r10, 0(r16)
    br LOOP

turn_off_sensors:
    movia  r8, ADDR_JP1
    movia r11, 0x55400
    stwio  r12, 0(r8)
    and r12, r12, r11 # turn all sensors off
    stwio  r12, 0(r8)
    ret 

read_0:
    addi sp, sp, -4
    stw ra, 0(sp)      # save ra

    call turn_off_sensors

    movia  r8, ADDR_JP1
    movia  r12, 0xFFFFFBFF
    ldwio  r11, 0(r8)  

    and r12, r12, r11 # turn sensor 0 on
    stwio  r12, 0(r8)
    ldwio  r13, 0(r8)          # checking for valid data sensor 0
    srli   r14,  r13, 11          # bit 11 is valid bit for sensor 0        
    andi   r14,  r14, 0x1
    bne r0,  r6, read_0        # wait for valid bit to be low: sensor 3 needs to be valid
    srli   r15, r15, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
    andi   r2, r15, 0x0f # mask rest of bits and return 
    
    addi sp, sp, 4
    ldw ra, 0(sp)      # restore ra
    ret

read_4:
    addi sp, sp, -4
    stw ra, 0(sp)      # save ra

    call turn_off_sensors

    movia  r8, ADDR_JP1
    movia  r12, 0xFFFBFFFF
    ldwio  r11, 0(r8)  

    and r12, r12, r11 # turn sensor 4 on
    stwio  r12, 0(r8)
    ldwio  r13, 0(r8)          # checking for valid data sensor 4
    srli   r14, r13, 19          # bit 19 is valid bit for sensor 4           
    andi   r14, r14, 0x1
    bne r0,  r6, read_0        # wait for valid bit to be low: sensor 3 needs to be valid
    srli   r15, r15, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
    andi   r2, r15, 0x0f # mask rest of bits and return 
    
    addi sp, sp, 4
    ldw ra, 0(sp)      # restore ra
    ret