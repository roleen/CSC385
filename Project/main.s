.equ PS2_CONTROLLER1, 0xFF200100
.equ PS2_IRQ7, 0x80
.equ audio_location, 0x100000 # TODO: temporary location
.equ LED, 0xFF200000

.data

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
    .word recordings # seleted recording, store pointer to it

.align 2
recordings: # allocate space for storing recordings
    .skip 1000000 # 16MB

.align 2
free_ptr: # pointer to the free space
    .word recordings

.align 2
id: # id of a recording, keep incrementing
    .word 0    

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

    call create_hdear # create the first header

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
    stw r0, 0(r8) # set cur_state to playbackstop

    mov r4, r0
    call display_state_LED

    movia r8, key_pressed
    movi r9, 1
    stw r9, 4(r8) # set key_pressed as read

playback_stop_mode_loop:
    movia r10, selected
    ldw r4, 0(r10)
    call display_number
    
    ldw r10, 0(r8)
    ldw r11, 4(r8)
    
    movi r9, 'D'
    beq r10, r9, playback_mode

    movi r9, 'R'
    beq r10, r9, recording_stop_mode

    movi r9, '+'
    beq r10, r9, call_next_selected

    movi r9, '-'
    beq r10, r9, call_prev_selected

    br playback_stop_mode_loop

call_next_selected:
    bne r0, r11, playback_stop_mode_loop
    call next_selected
    br playback_stop_mode_loop

call_prev_selected:
    bne r0, r11, playback_stop_mode_loop
    call prev_selected
    br playback_stop_mode_loop

playback_mode:   
    movia r8, cur_state
    movi r9, 1
    stw r9, 0(r8) # set cur_state to playback_mode

    mov r4, r9
    call display_state_LED

    movia r8, key_pressed
    movi r9, 1
    stw r9, 4(r8) # set key_pressed as read

	movia r4, selected
    
playback_loop:    
    beq r4, r0, playback_stop_mode

    call play_audio

    mov r4, r2 # move up the pointer using return value from play_audio

    ldw r17, 0(r8)
    movia r18, 'P' # if pressed key not resume, then keep pausing
    beq r17, r18, playback_call_pasue
    
    ldw r17, 0(r8)
    movia r18, 'S' # if pressed key not resume, then keep pausing
    beq r17, r18, playback_stop_mode 

    br playback_loop

playback_call_pasue:
    call pause_mode
    br playback_loop

record_mode:   
    addi sp, sp, -4

    movia r8, cur_state
    movi r9, 3
    stw r9, 0(r8) # set cur_state to playback_mode

    mov r4, r9
    call display_state_LED

    movia r8, key_pressed
    movi r9, 1
    stw r9, 4(r8) # set key_pressed as read

	movia r4, free_ptr
    mov r10, r4
    stw r10, 0(sp) # store header pointer in stack
    call create_hdear
    mov r4, r2
record_loop:    
    call record

    mov r4, r2 # move up the pointer using return value from play_audio

    ldw r17, 0(r8)
    movia r18, 'P' # if pressed key not resume, then keep pausing
    beq r17, r18, record_call_pasue
    
    ldw r17, 0(r8)
    movia r18, 'S' # if pressed key not resume, then keep pausing
    beq r17, r18, record_stopping # TODO: update header and free space

    br playback_loop

record_call_pasue:
    call pause_mode
    br record_loop

record_stopping:
    movia r8, free_ptr
    ldw r10, 0(sp) # get header pointer from stack
    
    stw r8, 12(r10) # update header prev
    stw r2, 8(r10) # update header next
    stw r2, 0(r8) # update free pointer

    addi sp, sp, 4
    br recording_stop_mode


pause_mode: # it's actually a function
    addi sp, sp, -12
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)

    movia r16, cur_state
    movi r17, 4
    stw r17, 0(r16) # set cur_state to pasue

    mov r4, r9
    call display_state_LED
    
    movia r16, key_pressed
pause_mode_loop:
    ldw r17, 0(r16)
    movia r18, 'D' # if pressed key not resume, then keep pausing
    bne r17, r18, pause_mode_loop

    movi r17, 1
    stw r17, 4(r16) # set as read
    
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    addi sp, sp, 12
    ret


recording_stop_mode:
    movia r8, cur_state
    movi r9, 2
    stw r9, 0(r8) # set cur_state to 2

    mov r4, r9
    call display_state_LED
    
    movia r8, key_pressed
    movi r9, 1
    stw r9, 4(r8) # set key_pressed as read

recording_stop_mode_loop:
    ldw r10, 0(r8)
    
    movi r9, 'D'
    beq r10, r9, record_mode

    movi r9, 'R'
    beq r10, r9, playback_stop_mode

    br playback_stop_mode_loop

# ######Memory Management Below

# input a pointer, and return the pointer after the header
create_hdear:
    movia r8, id
    ldw r9, 0(r8)

    stw r9, 0(r4) # id
    addi r4, 4 
    stw r0, 0(r4) # length
    addi r4, 4 
    stw r0, 0(r4) # next pointer
    addi r4, 4
    stw r0, 0(r4) # prev pointer
    mov r2, r4 # rest to store audios
    
    addi r9, r9, 1 # increment id by 1 for next use
    stw r9, 0(r8)
    
    ret 
    
delete_current_selection:
    ret

# ######Additional Helper functions


next_selected:
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    movia r16, key_pressed
    movi r17, 1
    stw r17, 0(16) # set to readed

    movia r16, selected
    ldw r17, 8(r16) # get next from header pointer
    stw r17, 0(r16) # update current selected

    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 4
    ret 

prev_selected:
    ret

# ######Interrupt Handler and Helper Functions Below

# save the last key press in memory location FLAG
keypress_handler:
    addi sp, sp, -4
    stw ra, 0(sp)

    movia r8, PS2_CONTROLLER1

waitforvalid:
    ldwio r4, 0(r8) # read input data (also ack interrupt autmatically)
    ldwio r5, 0(r8) # second character

    movia r10, 0x8000
    and r9, r4, r10 # check if valid
    beq r9, r0, waitforvalid # if not, loop

    andi r4, r4, 0xFF
    andi r5, r5, 0xFF
    call keypress_actions

    ldw ra, 0(sp)
    addi sp, sp, 4
    ret

# define a list of keymappings for 
# Recording mode -- R
# Start/Resume recording -- D 
# Pause recording -- P
# Stop recording -- S
# Playback mode -- V
# Start/Resume playback -- D
# Pause playback -- P
# Stop (return to the beginning point) play back -- S
keypress_actions:
    addi sp, sp, -12 # allocate stack space 
	stw r16, 0(sp)
	stw r17, 4(sp)
    stw r18, 8(sp) 
    
    movi r16, 0x2D
    beq r4, r16, R_key

    movi r16, 0x2A
    beq r4, r16, V_key

    movi r16, 0x23
    beq r4, r16, D_key

    movi r16, 0x4D
    beq r4, r16, P_key

    movi r16, 0x1B
    beq r4, r16, S_key

    movi r16, 0xE0
    beq r4, r16, up_or_down
    
    br keypressactions_end

R_key:
    movi r17, 'R'
    br keypressactions_set_pressed

V_key:
    movi r17, 'V'
    br keypressactions_set_pressed

D_key:
    movi r17, 'D'
    br keypressactions_set_pressed

P_key:
    movi r17, 'P'
    br keypressactions_set_pressed

S_key:
    movi r17, 'S'
    br keypressactions_set_pressed

up_or_down:
    movi r16, 0x75
    beq r4, r16, up_key

    movi r16, 0x72
    beq r4, r16, down_key

    br keypressactions_end

up_key:
    movi r17, '+'
    br keypressactions_set_pressed

down_key:
    movi r17, '-'

keypressactions_set_pressed:
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

