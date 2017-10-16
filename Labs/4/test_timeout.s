.equ LED, 0xff200000
.equ TIMEOUT, 1000000

.global _start
_start:
    movia r16, LED
    movia r17, 1

LOOP:
    movia r4, TIMEOUT
    call timeout
    stwio r16, 0(r17) # on

    movia r4, TIMEOUT
    call timeout
    stwio r0, 0(r17) # off

    br LOOP