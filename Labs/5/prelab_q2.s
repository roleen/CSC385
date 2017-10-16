.equ ADDR_JP2, 0xFF200070     # address GPIO JP2
.equ ADDR_JP2_IRQ, 0x1000      # IRQ line for GPIO JP2 (IRQ12) 

movia  r8, ADDR_JP2         # load address GPIO JP2 into r8
movia  r9, 0x07f557ff       # set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs 
stwio  r9, 4(r8)

# load sensor0 threshold value 5 and enable sensor0

movia  r9,  0xfabffbff       # set motors off enable threshold load sensor 0
stwio  r9,  0(r8)            # store value into threshold register

# disable threshold register and enable state mode

movia  r9,  0xfadfffff      # keep threshold value same in case update occurs before state mode is enabled
stwio  r9,  0(r8)

# enable interrupts

movia  r12, 0x8000000       # enable interrupts on sensor 0
stwio  r12, 8(r8)

movia  r8, ADDR_JP2_IRQ    # enable interrupt for GPIO JP2 (IRQ12) 
wrctl  ctl3, r8

movia  r8, 1
wrctl  ctl0, r8            # enable global interrupts 

LOOP:
br LOOP
