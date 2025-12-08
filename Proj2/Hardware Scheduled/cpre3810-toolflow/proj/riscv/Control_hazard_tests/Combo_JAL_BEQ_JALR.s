.text
.globl main

main:
    jal x1, A
    addi x2, x0, 123        # flushed

A:  beq x0, x0, B           # taken
    addi x3, x0, 456        # flushed

B:  jalr x4, x1, 0          # jump again using x1 value
    addi x5, x0, 777        # flushed

C:  nop                     # final landing zone
end:
    wfi


