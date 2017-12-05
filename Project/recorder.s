.equ ADDR_AUDIODACFIFO, 0xFF203040

.global record

## subroutine that reads one sample & stores it at the address given 
# store location & increments the length in the header accordingly
# arguments:
#  r4: pointer to store location
#  r5: pointer to header

record:
    # save registers used on the stack
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    # get one sample from input FIFO

recording_loop:
    movia r16, ADDR_AUDIODACFIFO
    ldwio r17, 4(r16)      # Read fifospace register
    andi  r17, r17, 0xff    # Extract # of samples in Input Right Channel FIFO
	beq r17, r0, recording_loop
    
    # store left and right FIFO's input sample to store location
    ldwio r17, 8(r16)
    stw r17, 0(r4)
    ldwio r17, 12(r16)
    stw r17, 4(r4)

    # increment length of header by 8 bytes
    ldw r17, 4(r5)
    addi r17, r17, 8
    stw r17, 4(r5)

	addi r2, r4, 8

    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8

    ret
