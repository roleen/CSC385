
# void play_audio(char *audio_ptr);


.equ ADDR_AUDIODACFIFO, 0xFF203040

.global play_audio
play_audio:
    addi sp, sp, -16
    stw r16, 0(sp)
    
    movia r8, ADDR_AUDIODACFIFO
    ldw r9, 0(r4) # load the first sample
    movia r16, 0x10000 # length counter TODO: read actual value

waitforspace:
    ldwio r10, 4(r8)
    andhi r11, r10, 0xFF00 # check for if there is space in FIFO queue
    beq r11, r0, waitforspace
    andhi r11, r10, 0xFF # another channel?
    beq r11, r0, waitforspace

writesamples:
    beq r16, r0, end
    stwio r9, 8(r8) # write to left FIFO
	addi r9, r9, 4
    stwio r9, 12(r8) # write to right FIFO
    subi r16, r16, 1 # decrement length counter
    addi r4, r4, 8
    ldw r9, 0(r4) # move up the pointer
    br waitforspace

end:
    ldw r16, 0(sp)
    addi sp, sp, 16
    ret
    
