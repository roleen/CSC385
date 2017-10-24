.equ ADDR_JTAG_UART, 0x10001020

.global _start
_start:
	call ReadSensorsAndSpeed
	movi r12, 0x1f
	beq r2, r12, SteerStraight
	movi r12, 0x1e
	beq r2, r12, SteerRight
	movi r12, 0x1c
	beq r2, r12, SteerHardRight
	movi r12, 0x0f
	beq r2, r12, SteerLeft
	movi r12, 0x07
	beq r2, r12, SteerHardLeft

CallSetSteering:
	call SetSteering
	
	movi r4, 0x04
	call WriteOneByteToUART
	movi r4, 30
	call WriteOneByteToUART
	br _start

SteerStraight:
	movi r4, 0x00
	br CallSetSteering

SteerRight:
	movi r4, 60
	br CallSetSteering

SteerHardRight:
	movi r4, 127
	br CallSetSteering

SteerLeft:
	movi r4, -60
	br CallSetSteering

SteerHardLeft:
	movi r4, -127
	br CallSetSteering

SetSteering:
	movi r5, r4
	mov r4, 0x05
	call WriteOneByteToUART
	mov r4, r5
	call WriteOneByteToUART

ReadSensorsAndSpeed:
	movi r4, 0x02
	call WriteOneByteToUART
	WaitForZeroByte:
		call ReadOneByteFromUART
		bne r2, r0, WaitForZeroByte
	call ReadOneByteFromUART
	addi r11, r2, 0
	call ReadOneByteFromUART
	addi r3, r2, 0
	addi r2, r11, 0
	ret

WriteOneByteToUART:
	movia r10, ADDR_JTAG_UART
	ldwio r8, 4(r10) /* Load Control Register from the JTAG */
	srli r8, r8, 16 /* Check only the write available bits */
	beq r8, r0, WriteOneByteToUART /* If this is 0 (branch true), data cannot be sent */
	stwio r4, 0(r10) /* Write the input byte to the JTAG */
	ret

ReadOneByteFromUART:
	movia r10, ADDR_JTAG_UART
	ldwio r8, 0(r10) /* Load Data Register from the JTAG */
	andi r9, r8, 0x8000 /* Mask other bits */
	beq r9, r0, ReadOneByteFromUART /* If this is 0 (branch true), data is not valid */
	andi r2, r8, 0x00FF /* Data read is now in r9 */
	ret
