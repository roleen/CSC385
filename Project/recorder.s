.equ ADDR_AUDIODACFIFO, 0xFF203040\
.equ ADDR_RED_LEDS, 0xFF200000
.equ RECORD_INDICATOR, 0x3E0

.global start_recording
.global record
.global stop_recording

# subroutine to start recording, uses callee saved registers
start_recording:
    # save registers used on the stack
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    # turn on left half of red LEDs indicating recording
    movia r16, ADDR_RED_LEDS
    movia r17, RECORD_INDICATOR
    stwio r17, 0(r16)

    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8

    ret

# subroutine that reads one sample and stores it at the address given as parameter
# arguments:
# r4: pointer to store location
# r5: pointer to header
record:
    # save registers used on the stack
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    # get one sample from input FIFO
    movia r16, ADDR_AUDIODACFIFO
    ldwio r17, 4(r16)      # Read fifospace register
    andi  r17, r17, 0xff    # Extract # of samples in Input Right Channel FIFO
    
    # store left and right FIFO's input sample to store location
    ldwio r17, 8(r16)
    stw r17, 0(r4)
    ldwio r17, 12(r16)
    stw r17, 4(r4)

    # increment length of header by 8 bytes
    ldw r17, 4(r4)
    addi r17, r17, 8
    stw r17, 4(r4)

    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8

    ret

# subroutine to stop recording, uses callee saved registers
stop_recording:
    # save registers used on the stack
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    # turn off left half of red LEDs indicating recording
    movia r16, ADDR_RED_LEDS
    stwio r0, 0(r16)

    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8

    ret
    