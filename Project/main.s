.equ PS2_CONTROLLER1, 0xFF200100
.equ PS2_IRQ7, 0x80
.equ audio_location, 0x100000 # TODO: temporary location
.equ LED, 0xFF200000

.data
# define a list of keymappings for 
# Recording mode -- R
# Start/Resume recording -- D 
# Pause recording -- P
# Stop recording -- S
# Playback mode -- V
# Start/Resume playback -- D
# Pause playback -- P
# Stop (return to the beginning point) play back -- S
ACTIONS_LIST:
    .word 0x2D # R
    .word 'R'
    .word 0x2A # V
    .word 'V'
    .word 0x23 # D
    .word 'D'
    .word 0x4D # P
    .word 'P'
    .word 0x1B # S
    .word 'S'
    .word 0x00 # TODO: up
    .word '+'
    .word 0x00 # TODO: down
    .word '-'
    
    .word 0 # End of actions

BRANCH_ADDRESS:
    .skip 4

.align 2
cur_state:
    .word 0 # states:
            # 0 = playbackstop
            # 1 = playback playing
            # 2 = recordstop
            # 3 = recording
            # 4 = pause

.align 2
key_pressed: 
    .word 0 # pressed key
    .word 0 # read or not

.align 2
selected:
    .word 0 # seleted recording

.align 2
recordings: # allocate space for storing recordings
    .skip 1000000 # 16MB

.text

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

    br playback_stop_mode

# ############recoder states below
# Each state will be a loop, doing recording or waiting using the loop
# also polling the key_pressed to see if state need transistion
# stop/recording/playback modes are code snipets, 
# pause is a fucntion becasue it needs to return to the previous states
#
#

playback_stop_mode:
    movia r8, cur_state
    movi r9, 4
    stw r9, 0(r8) # set cur_state to playbackstop
    
    movia r8, key_pressed
    ldw r10, 0(r8)
    
    movi r9, 'D'
    beq r10, r9, playback_mode

    movi r9, 'R'
    beq r10, r9, recording_stop_mode

    br playback_stop_mode


record_mode:
	movia r16, LED
	movia r17, 0b1
	stwio r0, 0(r16)
	stwio r17, 0(r16)

	movia r4, audio_location
    call record
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    br recording_stop_mode

playback_mode:   
	movia r16, LED
	movia r17, 0b10
	stwio r0, 0(r16)
	stwio r17, 0(r16)

	movia r4, audio_location
    call play_audio
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    br playback_stop_mode

deletemode:
    # TODO: We need this mode? or we can just delete stuffs in stop mode
    br keypressactions_end

pause_mode: # it's actually a function
    addi sp, sp, -12
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)

    movia r16, cur_state
    movi r17, 4
    stw r17, 0(r16) # set cur_state to pasue
    
    movia r16, key_pressed
    ldw r17, 0(r16)
    movia r18, 'D' # if pressed key not resume, then keep pausing
    bne r17, r18, pause_mode

    movi r17, 1
    stw r17, 4(r16) # set as read
    
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    addi sp, sp, 12
    ret


recording_stop_mode:
    br recording_stop_mode


# ######Memory Management Below

# input a pointer, and return the pointer after the header
create_hdear:
    stw r0, 0(r4) # id
    addi r4, 4 
    stw r0, 0(r4) # length
    addi r4, 4 
    stw r0, 0(r4) # next pointer
    mov r2, r4 # rest to store audios
    ret 


# ######Additional Helper functions

delete_current_selection:
    ret


# ######Interrupt Handler and Helper Functions Below

# save the last key press in memory location FLAG
keypress_handler:
    addi sp, sp, -4
    stw ra, 0(sp)

    movia r8, PS2_CONTROLLER1

waitforvalid:
    ldwio r9, 0(r8) # read input data (also ack interrupt autmatically)

    movia r10, 0x8000
    add r9, r9, r10 # check if valid
    beq r9, r0, waitforvalid # if not, loop

    andi r4, r9, 0xFF
    call keypress_actions

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret
    
keypress_actions:
    addi sp, sp, -12 # allocate stack space 
	stw r16, 0(sp)
	stw r17, 4(sp)
    stw r18, 8(sp)
    movia r16, ACTIONS_LIST

findaction:
    ldw r17, 0(r16) # action key
    beq r17, r0, keypressactions_end # no valid key press mapping found
    
    addi r16, r16, 8
    bne r17, r4, findaction
    ldw r17, 4(r16) # get the key
    
    movia r18, key_pressed
    stw r17, 0(r18) # save the key into key_pressed
    stw r0, 4(r18) # set read to 0

keypressactions_end:
	ldw r16, 0(sp)
	ldw r17, 4(sp)
    ldw r18, 8(sp)	
    addi sp, sp, 12 # allocate stack space 
    ret 

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

    call keypress_handler

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

