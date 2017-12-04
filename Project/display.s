.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

# .global _start
# _start:
#    movia sp, 4000000 # init sp
#    call clear_screen
#    call clear_characters
#    movia r4, 1
#    movia r5, 1
#    movia r6, 'A'
#    call write_character

# loop:
#    br loop

# takes the (x, y) coordinates and a color value, and sets
# the color of the (x, y) pixel on VGA display with that color
# arguments:
#   r4: integer for x coordinate on VGA display (0 <= x <= 319)
#   r5: integer for y coordinate on VGA display (0 <= y <= 239)
#   r6: color value for pixel at given coordinate
write_pixel:
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    # get the address of the pixel on VGA display
    movia r16, ADDR_VGA
    muli r17, r5, 1024
    add r17, r17, r4
    add r17, r17, r4
    add r17, r17, r16

    sthio r6,0(r17)

    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8
    ret

# takes the (x, y) coordinates, a color value and a character and
# and sets (x, y) character in the character buffer in the given color
# arguments:
#   r4: integer for x coordinate on VGA display (0 <= x <= 79)
#   r5: integer for y coordinate on VGA display (0 <= y <= 59)
#   r6: character value
write_character:
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    # get the address of the pixel on VGA display
    movia r16, ADDR_CHAR
    muli r17, r5, 128
    add r17, r17, r4
    add r17, r17, r16
    
    stbio r6, 0(r17)

    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8
    ret

# clears the screen to black screen
clear_screen:
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    movia r16, ADDR_VGA
    movia r17, 128000

set_black_loop:
    sthio r0,0(r16)
    addi r16, r16, 2
    addi r17, r17, -1
    bne r17, r0, set_black_loop

    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8
    ret

# clears the characters on the screen
clear_characters:
    addi sp, sp, -8
    stw r16, 0(sp)
    stw r17, 4(sp)

    movia r16, ADDR_CHAR
    movia r17, 4800

remove_char_loop:
    stbio r0,0(r16)
    addi r16, r16, 1
    addi r17, r17, -1
    bne r17, r0, remove_char_loop

    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8
    ret