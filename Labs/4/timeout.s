.global	timeout

timeout:
    # addi sp, sp, -4
    # stw ra, 0(sp)      # save ra

    movia r8, 0xFF202000  # timer 1 addr
    srli r9, r4, 16 # get the higher 16 bits of arugment by shift right 16 bits
    slli r10, r4, 16 
    srli r10, r10, 16 # get the lower 16 bits of arugment by shift left than shift right 16 bits

    stwio r10, 8(r8)                          # Set the period to be 1000 clock cycles 
    stwio r9, 12(r8)

    stwio r0, 0(r8) # clear timeout bit 
    movui r11, 4
    stwio r11, 4(r8)                          # Start the timer without continuing or interrupts 

LOOP:
    ldwio r12, r8
    andi r12, r12, 1 # only check bit 0
    movi r13, 1
    bne r12, r13, LOOP

    stwio r0, 0(r8) # clear timeout bit 
    # ldw ra, 0(sp)      # Restore return address
    # addi sp, sp, 4  
    ret 