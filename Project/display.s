.equ ADDR_VGA, 0x08000000
.equ ADDR_CHAR, 0x09000000

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