.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ ADDR_AUDIODAC_IRQ, 6
.equ CLEAR_READ_FIFO, 0x4
.equ AUDIO_READ_INTERRUPT, 0x1
.equ ADDR_RED_LEDS, 0xFF200000
.equ RECORD_INDICATOR, 0x3E0

# subroutine to start recording, uses callee saved registers
start_recording:
    # save registers used on the stack
    addi sp, sp, -12
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)

    # clear read FIFOs
    movia r16, ADDR_AUDIODACFIFO
    movia r17, CLEAR_READ_FIFO
    stwio r17, 0(r16)

    # enable audio core interrupts
    movia r17, ADDR_AUDIODAC_IRQ
	wrctl ctl3, r17

    # enable global interrupts
    movia r17, 1
	wrctl ctl0, r17

    # turn on left half of red LEDs indicating recording
    movia r18, ADDR_RED_LEDS
    movia r17, RECORD_INDICATOR
    stwio r17, 0(r18)

    # turn off clear read FIFO and enable read interrupt
    movia r17, AUDIO_READ_INTERRUPT
    stwio r17, 0(r16)

    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    addi sp, sp, 12

    ret

# subroutine to stop recording, uses callee saved registers
stop_recording:
    # TODO