.equ ADDR_AUDIODACFIFO, 0xFF203040

.global play_audio

# subroutine that reads the samples at the pointer in the store location,
# writes the samples to the left a right output FIFO of the audio codec
# a returns the pointer to the next sample (0 if at the end of recording).
# arguments:
#   r4: pointer to store location
#   r5: pointer to header
# return:
#   r2: pointer to the next sample
play_audio:
    # save registers used on the stack
    addi sp, sp, -16
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
	stw r19, 12(sp)

    movia r16, ADDR_AUDIODACFIFO

waitforspace:
    ldwio r18, 4(r16)
    andhi r17, r18, 0xFF00 # check for if there is space in FIFO queue
    beq r17, r0, waitforspace
    andhi r17, r18, 0xFF # another channel?
    beq r17, r0, waitforspace

    # write the sample to the left and right output FIFOs
    ldw r17, 0(r4)
    stwio r17, 8(r16)
	addi r17, r17, 4
    stwio r17, 12(r16)
    
    # get the next sample's potential pointer
    addi r2, r4, 8

    # get the address of the end of this recording using header's length
    addi r17, r5, 16
    ldw r18, 4(r5)
    add r17, r17, r18
	
	sub r18, r17, r2
	movi r19, 8
	div r18, r18, r19
	movia r19, 44000
	div r18, r18, r19
	
    # set next pointer to 0 if potential next pointer goes beyond this recording
    ble r2, r17, restore_registers
    mov r2, r0

restore_registers:
    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
	ldw r19, 12(sp)
    addi sp, sp, 16

    ret
