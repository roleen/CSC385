.equ ADDR_7SEG1, 0xFF200020
.equ ADDR_7SEG2, 0xFF200030
.equ ZERO, 0x3F
.equ ONE, 0x6
.equ TWO, 0x5B
.equ THREE, 0x4F
.equ FOUR, 0x66
.equ FIVE, 0x6D
.equ SIX, 0x7D
.equ SEVEN, 0x7
.equ EIGHT, 0x7F
.equ NINE, 0x6F

# takes integer parameter and returns corresponding seven segment mapping
# arguments:
#   r4: single digit integer
# return:
#   r2: seven segment mapping of integer
int_to_segments:
    addi sp, sp, -4
    stw r16, 0(sp)

    movia r16, 0
    movia r2, ZERO
    beq r16, r4, return_int_to_segments

    movia r16, 1
    movia r2, ONE
    beq r16, r4, return_int_to_segments

    movia r16, 2
    movia r2, TWO
    beq r16, r4, return_int_to_segments

    movia r16, 3
    movia r2, THREE
    beq r16, r4, return_int_to_segments

    movia r16, 4
    movia r2, FOUR
    beq r16, r4, return_int_to_segments

    movia r16, 5
    movia r2, FIVE
    beq r16, r4, return_int_to_segments

    movia r16, 6
    movia r2, SIX
    beq r16, r4, return_int_to_segments

    movia r16, 7
    movia r2, SEVEN
    beq r16, r4, return_int_to_segments

    movia r16, 8
    movia r2, EIGHT
    beq r16, r4, return_int_to_segments

    movia r16, 9
    movia r2, NINE

return_int_to_segments:
    ldw r16, 0(sp)
    addi sp, sp, 4
    ret