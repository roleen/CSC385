/*********
 * 
 * Write the assembly function:
 *     printn ( char * , ... ) ;
 * Use the following C functions:
 *     printHex ( int ) ;
 *     printOct ( int ) ;
 *     printDec ( int ) ;
 * 
 * Note that 'a' is a valid integer, so movi r2, 'a' is valid, and you dont need to look up ASCII values.
 *********/

.global	printn
printn:
# ...
	addi sp, sp, -16 # allocate for arguments
    stw r4, 0(sp)
    stw r5, 4(sp)
    stw r6, 8(sp)
    stw r7, 12(sp) # saving register arugments on stack

    addi sp, sp, -8
    stw ra, 4(sp)      # save ra
    stw fp, 0(sp)      # save fp

    ldw r8, 8(sp) # get the address to string (first argument)
    addi r9, sp, 12 # get the address to second argument
    movi r12, 'O'
    movi r13, 'H'
    movi r14, 'D'

LOOP:
    ldb r10, 0(r8) # get the letter
    ldw r11, 0(r9) # get the number
	
	beq r10, r0, END_LOOP
    addi sp, sp, -32 # save caller saved register
    stw r8, 0(sp)
    stw r9, 4(sp)
    stw r10, 8(sp)
    stw r11, 12(sp)
    stw r12, 16(sp)
    stw r13, 20(sp)
    stw r14, 24(sp)
    stw r15, 28(sp)

    mov r4, r11 # set arugment

    beq r10, r12, PRINTOCT # jumps to calls
    beq r10, r13, PRINTHEX
    beq r10, r14, PRINTDEC
    br KEEP_LOOP

PRINTHEX:
    call printHex
    br CALL_RET

PRINTOCT:
    call printOct
    br CALL_RET

PRINTDEC:
    call printDec
    br CALL_RET

KEEP_LOOP:
    addi r8, r8, 1 # address to next letter
    addi r9, r9, 4 # address to next number
    br LOOP 

CALL_RET:    
    ldw r8, 0(sp) # restore caller saved registers
    ldw r9, 4(sp)
    ldw r10, 8(sp)
    ldw r11, 12(sp)
    ldw r12, 16(sp)
    ldw r13, 20(sp)
    ldw r14, 24(sp)
    ldw r15, 28(sp)
    addi sp, sp, 32 
    br KEEP_LOOP

END_LOOP:
    ldw ra, 4(sp)      # Restore return address
    ldw fp, 0(sp)       # Restore fp address
    addi sp, sp, 8       # Deallocate stack space
    addi sp, sp, 16 

    ret


