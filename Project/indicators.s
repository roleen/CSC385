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

# takes a number between 0 and 99 and a segment sections between
# 0 and 3 and displays the number on that segment section of the
# seven segment display
# arguments:
#   r4: integer in range 0 to 99
#   r5: section of seven segment display (between 0 and 3)
display_number:
    addi sp, sp, -24
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    stw r19, 16(sp)
    stw r20, 20(sp)

    mov r19, r5

    call break_digits

    # get unit's place digit's seven segment
    mov r4, r2
    call digit_to_segments
    mov r16, r2

    # get ten's place digit's seven segment
    mov r4, r3
    call digit_to_segments
    mov r17, r2

    # create a 2 digit seven segment display
    slli r17, r17, 8
    or r17, r17, r16

    movia r18, ADDR_7SEG1
    movia r16, 2
    blt r19, r16, turn_off_mask
    
    movia r18, ADDR_7SEG2
    subi r19, r19, 2

turn_off_mask:
    movia r16, 0xFFFF0000
    beq r19, r0, write_seven_seg
    movia r16, 0x0000FFFF

write_seven_seg:
    ldwio r20, 0(r18)
    and r20, r20, r16

    muli r16, r19, 16
    sll r17, r17, r16
    or r20, r20, r17

    stwio r20, 0(r18)

    ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    ldw r19, 16(sp)
    ldw r20, 20(sp)
    addi sp, sp, 24

    ret

# takes integer parameter and returns corresponding seven segment mapping
# arguments:
#   r4: single digit integer
# return:
#   r2: seven segment mapping of integer
digit_to_segments:
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

# takes a number between 0 and 99 and returns two digits
# arguments:
#   r4: number between 0 and 99
# return:
#   r2: unit's place digit
#   r3: ten's place digit
break_digits:
    movi r3, 10
    div r3, r4, r3
    muli r2, r3, 10
    sub r2, r4, r2
    ret