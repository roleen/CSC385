.data                              # "data" section for input and output lists


    .align 1
IN_LIST:                       # List of 10 signed halfwords starting at address IN_LIST
    .hword 1
    .hword -1
    .hword -2
    .hword 2
    .hword 0
    .hword -3
    .hword 100
    .hword 0xff9c
    .hword 0b1111
LAST:           # These 2 bytes are the last halfword in IN_LIST
    .byte  0x01           # address LAST
    .byte  0x02           # address LAST+1
    
    .align 2
IN_LINKED_LIST:                     # Used only in Part 3 and Part 4
    A: .word 1
       .word B
    B: .word -1
       .word C
    C: .word -2
       .word E + 8
    D: .word 2
       .word C
    E: .word 0
       .word K
    F: .word -3
       .word G
    G: .word 100
       .word J
    H: .word 0xffffff9c
       .word E
    I: .word 0xff9c
       .word H
    J: .word 0b1111
       .word IN_LINKED_LIST + 0x40
    K: .byte 0x01       # address K
       .byte 0x02       # address K+1
       .byte 0x03       # address K+2
       .byte 0x04       # address K+3
       .word 0

    .align 2
OUT_LIST_NEGATIVE:
    .skip 40                         # Reserve space for 10 output words
    
    .align 2
OUT_LIST_POSITIVE:
    .skip 40                         # Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for code

    # Register allocation:
    #   r0 is zero, and r1 is "assembler temporary". Not used here.
    #   r2  Holds the number of negative numbers in the list
    #   r3  Holds the number of positive numbers in the list
    #   r4  Pointer to current element in IN_LINKED_LIST
    #   r5  loop counter for IN_LIST
    #   r6  Pointer to current available position in OUT_LIST_NEGATIVE
    #   r7  Pointer to current available position in OUT_LIST_POSITIVE
    #   r8  Current number that we are looking at in the IN_LINKED_LIST
    

.global _start
_start:
    movi r2, 0              # Initialize negative numbers counter
    movi r3, 0              # Initialize positive numbers counter
    movia r4, IN_LINKED_LIST
    movia r6, OUT_LIST_NEGATIVE     # Initialize Pointer to available spot in OUT_LIST_NEGATIVE
    movia r7, OUT_LIST_POSITIVE     # Initialize Pointer to available spot in OUT_LIST_POSITIVE

LOOP_IN_LIST:
    beq r4, r0, LOOP_FOREVER
    ldw r8, 0(r4)           # Load the element of IN_LIST
    ldw r4, 4(r4)
    blt r8, r0, ADD_TO_NEG
    bgt r8, r0, ADD_TO_POS
    beq r8, r0, LOOP_IN_LIST
    br LOOP_FOREVER
    
ADD_TO_NEG:
    stw r8, 0(r6)
    addi r6, r6, 4
    addi r2, r2, 1
    br LOOP_IN_LIST     

ADD_TO_POS:
    stw r8, 0(r7)
    addi r7, r7, 4
    addi r3, r3, 1
    br LOOP_IN_LIST   

LOOP_FOREVER: br LOOP_FOREVER                   # Loop forever.  

