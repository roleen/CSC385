.equ TIMER, 0xFF202000
.equ TIMER_IRQ, 0x1
.equ TIME, 10000
.equ RED_LEDS, 0xFF200002

.global _start
_start:
    # enable timer interrupt
    movia  r8, TIMER_IRQ    # enable interrupt for GPIO JP2 (IRQ12)
    wrctl  ctl3, r8
    movia  r8, 1
    wrctl  ctl0, r8             # enable global interrupts

    # Set timer
    movia r7, TIMER        # r7 contains the base address for the timer 
    movui r2, TIME
    stwio r2, 8(r7)             # Set the period to be TIME clock cycles 
    stwio r0, 12(r7)
    movui r2, 5
    stwio r2, 4(r7)             # Start the timer without continuing with interrupt enabled

LOOP:
	br LOOP

.section .exceptions, "ax"

IHANDLER:
    rdctl et, ctl4          # check for hardware interrupt
    andi et, et, TIMER_IRQ        # check if interrupt pending from IRQ0
    beq et, r0, EXIT_IHANDLER   # if not, exit handler

    # code to handle interrupt from IRQ0
    movi r9, 0xFFFFFFFF
    movia r10, RED_LEDS
    stwio r9, 0(r10)
    stwio r0, 0(r10)

    # code to acknowledge interrupt from IRQ0
    stwio r0, 0(r7)

EXIT_IHANDLER:
    subi ea, ea, 4
    eret