.text
.globl main
.data
A: .word 10
   .word 20

main:
    la   x10, A
    lw   x1, 0(x10)
    lw   x2, 4(x10)
    add  x3, x1, x2       # both operands come from two loads requiring stalls

end:
    wfi


