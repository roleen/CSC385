.equ PS2_CONTROLLER1, 0xFF200100
.equ PS2_IRQ7, 0x80

.global _start

_start: 
    movia sp, 4000000 # init sp

    movi r8, 1
    movia r9, PS2_CONTROLLER1
    stwio r8, 4(r9)

    movi r8, PS2_IRQ7 # enable ps/2 controller 1 IRQ
    wrctl ctl3, r8

	movi r8, 1
	wrctl ctl0, r8 # enable global interrupts 

loop:
    br loop


.section .exceptions, "ax"

interrupthandler:
    addi sp, sp, -8 # allocate stack space

    rdctl et, ctl4
    andi et, et, PS2_IRQ7 # check if interrupt pending from IRQ7
    beq et, r0, IntrExit # if not, exit
    call keypresshandler
    mov r10, r4

IntrExit:
	addi sp, sp, 8 # restore registers
	subi ea, ea, 4 # adjust exception address (where we should return) and return with eret
	eret 


keypresshandler:

    movia r8, PS2_CONTROLLER1

waitforvalid:
    ldwio r9, 0(r8) # read input data (also ack interrupt autmatically)

    movia r10, 0x8000
    add r9, r9, r10 # check if valid
    beq r9, r0, waitforvalid # if not, loop

    addi r2, r9, 0xFF
    ret
    

    



