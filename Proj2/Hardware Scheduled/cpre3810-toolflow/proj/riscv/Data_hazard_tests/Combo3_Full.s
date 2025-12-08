.data
myword: .word 0

.text
.globl main

main:
    la   x1, myword        # produce address
    addi x2, x0, 0x12      # produce data
    sw   x2, 0(x1)         # needs ALU forwarding for address & data

    lw   x3, 0(x1)         # load value back (store→load)
    add  x4, x3, x1        # uses loaded value + forwarded ALU value

end:
    wfi
