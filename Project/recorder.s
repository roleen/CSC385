.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ ADDR_AUDIODAC_IRQ, 6
.equ CLEAR_READ_FIFO, 0x4
.equ AUDIO_READ_INTERRUPT, 0x1
.equ ADDR_RED_LEDS, 0xFF200000
.equ RECORD_INDICATOR, 0x3E0

.global start_recording
.global record

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

# subroutine that reads one sample and stores it at the address given as parameter
# argument is a pointer stored at r4
record:
    # save registers used on stack
    addi sp, sp, -16
    stw r16, 0(sp)
    stw r17, 4(sp)
    stw r18, 8(sp)
    stw r19, 12(sp)
	stw r20, 16(sp)
    stw r21, 20(sp)

    # initialize left and right input samples to 0
    mov r18, r0
    mov r19, r0
	
	movia r16, ADDR_AUDIODACFIFO
	movia r19, 0x10000
	movia r20, ADDR_RED_LEDS
	
record_loop:
	beq r19, r0, 1
	movia r21, 0
	stwio r21, 0(r20)
    # read fifo space register    
    ldwio r17, 4(r16)

    # extract # of samples in Input Right Channel FIFO
    andi r17, r17, 0xff
	beq r17, r0, record_loop
	
	
	movia r21, 0b100
	stwio r21, 0(r20)
	
	
	ldwio r18, 8(r16)
	stw r18, 0(r4)
	
	ldwio r18, 12(r16)	
	stw r18, 4(r4)
	
	subi r19, r19, 1

record_end:
    # restore registers used from the stack
    ldw r16, 0(sp)
    ldw r17, 4(sp)
    ldw r18, 8(sp)
    ldw r19, 12(sp)
	ldw r20, 16(sp)
    ldw r21, 20(sp)
    addi sp, sp, 16
    
    ret

# subroutine to stop recording, uses callee saved registers
stop_recording:
    # TODO
