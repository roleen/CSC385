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
recordings: # allocate space for storing recordings
    .skip 20000000 # 20MB

.align 2
last: # pointer to the last recording
    .word 0 

.align 2
selected:
    .word recordings # seleted recording, store pointer to it

.align 2
free_ptr: # pointer to the free space
    .word recordings

.align 2
id: # id of a recording, keep incrementing
    .word 1

.text

.global _start

_start: 
    movia sp, 25000000# init sp

	movia r20, recordings
	movia r21, selected
	ldw r21, 0(r21)
	movia r22, free_ptr
	ldw r22, 0(r22)
	movia r19, last
	ldw r19, 0(r19)

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
    stw r0, 0(r8) # set cur_state to playbackstop

    mov r4, r0
    call display_state_LED

    movia r8, key_pressed
    movi r9, 1
    stw r9, 4(r8) # set key_pressed as read
	
    movia r10, selected
    ldw r10, 0(r10)
	ldw r4, 0(r10)
	movi r5, 2
    call display_number	
	
playback_stop_mode_loop:
	movia r8, key_pressed
	ldw r10, 0(r8)
    ldw r11, 4(r8)	

 	bne r0, r11, playback_stop_mode_loop

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
    call next_selected
    br playback_stop_mode_loop

call_prev_selected:
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
    ldw r4, 0(r4)
    mov r5, r4

    addi r4, r4, 12 # move pointer to actual audio
    
playback_loop:    
    beq r4, r0, playback_stop_mode

    call play_audio

    mov r4, r2 # move up the pointer using return value from play_audio

	movia r8, key_pressed
    ldw r17, 0(r8)
    movia r18, 'P' # if pressed key not resume, then keep pausing
    beq r17, r18, playback_call_pasue
    
    ldw r17, 0(r8)
    movia r18, 'S' # if pressed key not resume, then keep pausing
    beq r17, r18, playback_stop_mode 

    br playback_loop

playback_call_pasue:
    addi sp, sp, -4
	stw r4, 0(sp)
    
	movi r4, 1
	call pause_mode
	
	ldw r4, 0(sp)
	addi sp, sp, 4
    br playback_loop

record_mode:   
    addi sp, sp, -8

    movia r8, cur_state
    movi r9, 3
    stw r9, 0(r8) # set cur_state to playback_mode

    mov r4, r9
    call display_state_LED

    movia r8, key_pressed
    movi r9, 1
    stw r9, 4(r8) # set key_pressed as read

	movia r4, free_ptr
	ldw r4, 0(r4)
    mov r10, r4
    stw r10, 0(sp) # store header pointer in stack
	stw r8, 4(sp)

    call create_header
	
	ldw r8, 4(sp)
    mov r4, r2
	movia r5, free_ptr
	ldw r5, 0(r5)
record_loop:
    call record

    mov r4, r2 # move up the pointer using return value from play_audio

    ldw r17, 0(r8)

    movia r18, 'P' # if pressed key not resume, then keep pausing
    beq r17, r18, record_call_pasue
    
    ldw r17, 0(r8)
    movia r18, 'S' # if pressed key not resume, then keep pausing
    beq r17, r18, record_stopping # update header and free space

    br record_loop

record_call_pasue:
	addi sp, sp, -4
	stw r4, 0(sp)
    
	movi r4, 3
	call pause_mode
	
	ldw r4, 0(sp)
	addi sp, sp, 4
    br record_loop

record_stopping:
    # link the new recording to the next of last
    ldw r10, 0(sp) # get header pointer from stack
    
    movia r9, last
    ldw r9, 0(r9)

    beq r9, r0, record_stopping_end # if prev != NULL
    stw r10, 8(r9) # set prev->next = current

record_stopping_end:
	movia r9, free_ptr
    stw r2, 0(r9) # update free pointer

	movia r9, last
    stw r10, 0(r9) # update last pointer
	
    addi sp, sp, 8
    br recording_stop_mode


pause_mode: # it's actually a function
    addi sp, sp, -20
	stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
	stw r19, 14(sp)

	mov r19, r4

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
	
	mov r4, r19 # set state indicator to previous
    call display_state_LED

	ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
	ldw r19, 16(sp)
    addi sp, sp, 20
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
	ldw r11, 4(r8)

	bne r11, r0, recording_stop_mode_loop
    
    movi r9, 'D'
    beq r10, r9, record_mode

    movi r9, 'R'
    beq r10, r9, playback_stop_mode

    br playback_stop_mode_loop

# ######Memory Management Below

# input a pointer, and return the pointer after the header
create_header:	
	addi sp, sp, -12
	stw r16, 0(sp)
	stw r17, 4(sp)
	stw r18, 8(sp)


    movia r16, id
    ldw r17, 0(r16)

    stw r17, 0(r4) # id
    addi r4, r4, 4 
    stw r0, 0(r4) # length
    addi r4, r4, 4 
    stw r0, 0(r4) # next pointer
    addi r4, r4, 4
	stw r0, 0(r4) # prev pointer

	movia r18, last
	ldw r18, 0(r18)
	beq r18, r0, create_header_end # if last != NULL
	stw r18, 0(r4) # prev = last # we always add to last of the list

create_header_end:
	addi r4, r4, 4   
    addi r17, r17, 1 # increment id by 1 for next use
    stw r17, 0(r16)
	
	mov r2, r4    

		
	ldw r16, 0(sp)
	ldw r17, 4(sp)
	ldw r18, 8(sp)
	addi sp, sp, 12
    ret 
    
delete_current_selection:
    ret

# ######Additional Helper functions


next_selected:
    addi sp, sp, -12
    stw r16, 0(sp)
    stw r17, 4(sp)
	stw ra, 8(sp)

    movia r16, key_pressed
    movi r17, 1
    stw r17, 0(r16) # set to readed

    movia r16, selected
	ldw r16, 0(r16)
    ldw r17, 8(r16) # get next from header pointer
    beq r17, r0, next_selected_end # if null pointer, ignore

	movia r16, selected
    stw r17, 0(r16) # update current selected

next_selected_end:
	movia r16, selected
	ldw r16, 0(r16)
	ldw r4, 0(r16)
	movi r5, 2
    call display_number	

    ldw r16, 0(sp)
    ldw r17, 4(sp)
	ldw ra, 8(sp)
    addi sp, sp, 12
    ret 

prev_selected:
    addi sp, sp, -12
    stw r16, 0(sp)
    stw r17, 4(sp)
	stw ra, 8(sp)

    movia r16, key_pressed
    movi r17, 1
    stw r17, 0(r16) # set to readed

    movia r16, selected
	ldw r16, 0(r16)
    ldw r17, 12(r16) # get previous from header pointer
    beq r17, r0, prev_selected_end # if null pointer, ignore

	movia r16, selected
    stw r17, 0(r16) # update current selected

prev_selected_end:
	movia r16, selected
	ldw r16, 0(r16)
	ldw r4, 0(r16)
	movi r5, 2
    call display_number	

    ldw r16, 0(sp)
    ldw r17, 4(sp)
	ldw ra, 8(sp)
    addi sp, sp, 12
    ret 


# ######Interrupt Handler and Helper Functions Below

# save the last key press in memory location FLAG
keypress_handler:
    addi sp, sp, -4
    stw ra, 0(sp)

    movia r8, PS2_CONTROLLER1
	movia r10, 0x8000

waitforvalid0:
	ldwio r4, 0(r8) # read input data ignore first byte
    and r9, r4, r10 # check if valid
    beq r9, r0, waitforvalid0 # if not, loop

waitforvalid1:
	ldwio r4, 0(r8) # read input data (also ack interrupt autmatically)
    and r9, r4, r10 # check if valid
    beq r9, r0, waitforvalid1 # if not, loop

waitforvalid2:
	ldwio r5, 0(r8) # second character
    and r9, r5, r10 # check if valid
    beq r9, r0, waitforvalid2 # if not, loop

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
	
	mov r17, r5
	slli r17, r17, 8
	or r17, r17, r4
   
 	movi r16, 0x2D
	slli r16, r16, 8
	ori r16, r16, 0xF0	
	beq r17, r16, R_key

    movi r16, 0x2A
	slli r16, r16, 8
	ori r16, r16, 0xF0	
    beq r17, r16, V_key

    movi r16, 0x23
	slli r16, r16, 8
	ori r16, r16, 0xF0	
    beq r17, r16, D_key

    movi r16, 0x4D
	slli r16, r16, 8
	ori r16, r16, 0xF0	
    beq r17, r16, P_key

    movi r16, 0x1B
	slli r16, r16, 8
	ori r16, r16, 0xF0	
    beq r17, r16, S_key

    movi r16, 0x79
	slli r16, r16, 8
	ori r16, r16, 0xF0	
    beq r17, r16, plus_key

    movi r16, 0x7B
	slli r16, r16, 8
	ori r16, r16, 0xF0	
    beq r17, r16, minus_key
    
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

plus_key:
    movi r17, '+'
    br keypressactions_set_pressed

minus_key:
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
    addi sp, sp, -84 # allocate stack space
    stw ra, 0(sp)
	stw r2, 4(sp)
    stw r3, 8(sp)
	stw r4, 12(sp)
	stw r5, 16(sp)
	stw r6, 20(sp)
	stw r7, 24(sp)
	stw r8, 28(sp)
	stw r9, 32(sp)
	stw r10, 36(sp)
    stw r11, 40(sp)
	stw r12, 44(sp)
	stw r13, 48(sp)
	stw r14, 52(sp)
	stw r15, 56(sp)
	stw r16, 60(sp)
	stw r17, 64(sp)
	stw r18, 68(sp)
    stw r19, 72(sp)
	stw r20, 76(sp)
	stw r23, 80(sp)


    rdctl et, ctl4
    andi et, et, PS2_IRQ7 # check if interrupt pending from IRQ7
    beq et, r0, IntrExit # if not, exit

    call keypress_handler

IntrExit:

    ldw ra, 0(sp)
	ldw r2, 4(sp)
    ldw r3, 8(sp)
	ldw r4, 12(sp)
	ldw r5, 16(sp)
	ldw r6, 20(sp)
	ldw r7, 24(sp)
	ldw r8, 28(sp)
	ldw r9, 32(sp)
	ldw r10, 36(sp)
    ldw r11, 40(sp)
	ldw r12, 44(sp)
	ldw r13, 48(sp)
	ldw r14, 52(sp)
	ldw r15, 56(sp)
	ldw r16, 60(sp)
	ldw r17, 64(sp)
	ldw r18, 68(sp)
    ldw r19, 72(sp)
	ldw r20, 76(sp)
	ldw r23, 80(sp)
	addi sp, sp, 84 # restore registers
	subi ea, ea, 4 # adjust exception address (where we should return) and return with eret
	eret

