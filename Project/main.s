.equ PS2_CONTROLLER1, 0xFF200100
.equ PS2_IRQ7, 0x80
.equ R_KEY, 0x2D
.equ V_KEY, 0x2A
.equ D_KEY, 0x23
.equ P_KEY, 0x4D
.equ S_KEY, 0x1B
.equ audio_location, 0x100000 # TODO: temporary location
.equ LED, 0xFF200000

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
    addi sp, sp, -44 # allocate stack space 
    stw r2, 0(sp)
	stw r8, 4(sp)
    stw r9, 8(sp)
	stw r10, 12(sp)
	stw r11, 16(sp)
	stw r12, 20(sp)
	stw r13, 24(sp)
	stw r14, 28(sp)
	stw r15, 32(sp)
    stw ra, 36(sp)
	stw r4, 40(sp)

    rdctl et, ctl4
    andi et, et, PS2_IRQ7 # check if interrupt pending from IRQ7
    beq et, r0, IntrExit # if not, exit

    call keypresshandler
    mov r4, r2
	call keypressactions

IntrExit:

    ldw r2, 0(sp)
	ldw r8, 4(sp)
    ldw r9, 8(sp)
	ldw r10, 12(sp)
	ldw r11, 16(sp)
	ldw r12, 20(sp)
	ldw r13, 24(sp)
	ldw r14, 28(sp)
	ldw r15, 32(sp)
    ldw ra, 36(sp)
	ldw r4, 40(sp)

	addi sp, sp, 44 # restore registers
	subi ea, ea, 4 # adjust exception address (where we should return) and return with eret
	eret 


keypresshandler:
    movia r8, PS2_CONTROLLER1

waitforvalid:
    ldwio r9, 0(r8) # read input data (also ack interrupt autmatically)

    movia r10, 0x8000
    add r9, r9, r10 # check if valid
    beq r9, r0, waitforvalid # if not, loop

    andi r2, r9, 0xFF
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
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw ra, 8(sp)

    movia r16, R_KEY
    movia r17, V_KEY
    
    beq r4, r16, recordmode 
    beq r4, r17, playbackmode

keypressactions_end:
	ldw r16, 0(sp)
	ldw r17, 4(sp)	
	ldw ra, 8(sp)
    addi sp, sp, 20 # allocate stack space 
    ret 

recordmode:
	movia r16, LED
	movia r17, 0b1
	stwio r0, 0(r16)
	stwio r17, 0(r16)

	movia r4, audio_location
    call record
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    br keypressactions_end

playbackmode:
	movia r16, LED
	movia r17, 0b10
	stwio r0, 0(r16)
	stwio r17, 0(r16)

	movia r4, audio_location
    call play_audio
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    br keypressactions_end
