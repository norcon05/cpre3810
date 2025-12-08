.text
.globl main

main:
    beq x0, x0, B1          # taken
    addi x1, x0, 9          # flushed

B1:
    bne x0, x1, B2          # taken (0 != 9)
    addi x2, x0, 10         # flushed

B2:
    addi x3, x0, 11

end:
    wfi


