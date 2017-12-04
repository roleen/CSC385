.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

.global write_pixel
.global write_character
.global clear_screen
.global clear_characters
.global add_graph_point

# takes the y coordinate of the point to plot, plots it
# at x = 0 and moves all the other plotted points right
# by 1 pixel
# arguments:
#   r4: integer for y coordinate to be plotted (0 <= y <= 239)
add_graph_point:
    addi sp, sp, -20
    stw ra, 0(sp)
    stw r16, 4(sp)
    stw r17, 8(sp)
    stw r18, 12(sp)
    stw r19, 16(sp)

    movia r16, ADDR_VGA
    mov r19, r4

    # previous x value
    movia r17, 318

previous_column:
    # next x value
    mov r4, r17
    addi r4, r4, 1

    # current y value
    movia r5, 239

next_row:
    # get the index of the previous pixel
    muli r18, r5, 1024
    add r18, r18, r17
    add r18, r18, r17
    add r18, r18, r16

    # get the color of the previous pixel
    ldhio r6, 0(r18)

    call write_pixel

    addi r5, r5, -1
    bge r5, r0, next_row
    
    addi r17, r17, -1
    bge r17, r0, previous_column

    # initialize first column to black
    mov r4, r0
    movia r5, 239
    mov r6, r0

init_first_column:
    # get the index of the previous pixel
    muli r18, r5, 1024
    add r18, r18, r17
    add r18, r18, r17
    add r18, r18, r16

    call write_pixel

    addi r5, r5, -1
    bge r5, r0, init_first_column

    # plot the new y coordinate
    mov r4, r0
    mov r5, r19
    movia r6, 0xF800
    call write_pixel

    ldw ra, 0(sp)
    ldw r16, 4(sp)
    ldw r17, 8(sp)
    ldw r18, 12(sp)
    ldw r19, 16(sp)
    addi sp, sp, 20
    ret

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
    movia r17, 7800

remove_char_loop:
    stbio r0,0(r16)
    addi r16, r16, 1
    addi r17, r17, -1
    bne r17, r0, remove_char_loop

    ldw r16, 0(sp)
    ldw r17, 4(sp)
    addi sp, sp, 8
    ret