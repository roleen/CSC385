.equ PS2_CONTROLLER1, 0xFF200100
.equ PS2_IRQ7, 0x80
.equ R_KEY, 0x2D
.equ V_KEY, 0x2A
.equ D_KEY, 0x23
.equ P_KEY, 0x4D
.equ S_KEY, 0x1B
.equ audio_location, 0x100000 # TODO: temporary location


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
    call keypressactions
    br loop


.section .exceptions, "ax"

interrupthandler:
    addi sp, sp, -20 # allocate stack space 
    stw r2, 0(sp)
	stw r8, 4(sp)
    stw r9, 8(sp)
	stw r10, 12(sp)
    stw ra, 16(sp)

    rdctl et, ctl4
    andi et, et, PS2_IRQ7 # check if interrupt pending from IRQ7
    beq et, r0, IntrExit # if not, exit

    call keypresshandler
    mov et, r2

IntrExit:

    ldw r2, 0(sp)
	ldw r8, 4(sp)
    ldw r9, 8(sp)
	ldw r10, 12(sp)
    ldw ra, 16(sp)

	addi sp, sp, 20 # restore registers
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
    

# define a list of keymappings for 
# Recording mode -- R
# Start recording -- D 
# Pause recording -- P
# Stop recording -- S
# Playback mode -- V
# Start playback -- D
# Pause playback -- P
# Stop (return to the beginning point) play back -- S
keypressactions:
    addi sp, sp, -20 # allocate stack space 

    movia r8, R_KEY
    movia r9, V_KEY
    
    beq r4, r8, recordmode 
    beq r4, r9, playbackmode

keypressactions_end:
    addi sp, sp, 20 # allocate stack space 
    ret 

recordmode:
    stw r8, 0(sp)
    stw r9, 4(sp)
    call record
    ldw r8, 0(sp)
    ldw r9, 4(sp)
    br keypressactions_end

playbackmode:
    stw r8, 0(sp)
    stw r9, 4(sp)
    call play_audio
    ldw r8, 0(sp)
    ldw r9, 4(sp)
    br keypressactions_end