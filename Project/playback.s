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
    addi sp, sp, -24
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
	stw r19, 12(sp)
    stw ra, 16(sp)
	stw r5, 20(sp)

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

	addi sp, sp, -36
	stw r8, 0(sp)	
	stw r9, 4(sp)	
	stw r10, 8(sp)	
	stw r11, 12(sp)	
	stw r12, 16(sp)	
	stw r13, 20(sp)	
	stw r14, 24(sp)	
	stw r15, 28(sp)
	stw r2, 32(sp)

    
	movia r8, period
	ldw r9, 0(r8)
	beq r9, r0, skip_display # do not play on every loop, play only timer is triggered
	stw r0, 0(r8)
	
	mov r4, r2
    mov r5, r17
    call display_time_left # to display time left for the recording
	
	ldw r4, 32(sp)
	ldw r4, 0(r4)
	call display_waveform	
	

skip_display:

	ldw r8, 0(sp)	
	ldw r9, 4(sp)	
	ldw r10, 8(sp)	
	ldw r11, 12(sp)	
	ldw r12, 16(sp)	
	ldw r13, 20(sp)	
	ldw r14, 24(sp)	
	ldw r15, 28(sp)	
	ldw r2, 32(sp)
	addi sp, sp, 36

    # set next pointer to 0 if potential next pointer goes beyond this recording
    ble r2, r17, restore_registers
    mov r2, r0

restore_registers:
    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
	ldw r19, 12(sp)
    ldw ra, 16(sp)
	ldw r5, 20(sp)
    addi sp, sp, 24

    ret
