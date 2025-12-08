.data
C: .word 3

.text
.globl main

main:
    la   x10, C
    lw   x1, 0(x10)        # load
    add  x2, x1, x1        # stall + forward
    add  x3, x2, x1        # compute-use on result of forwarded load

end:
    wfi


