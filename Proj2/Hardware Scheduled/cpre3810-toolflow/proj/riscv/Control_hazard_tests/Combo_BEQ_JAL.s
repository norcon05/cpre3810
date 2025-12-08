.text
.globl main

main:
    addi x1, x0, 5
    addi x2, x0, 5

    beq x1, x2, Target1     # TAKEN → flush next 2 instructions
    jal x4, BAD             # flushed
    addi x5, x0, 77         # flushed

BAD:
    addi x3, x0, 55         # should not execute

Target1:
    jal x6, Target2         # second jump

Target2:
    addi x7, x0, 99

end:
    wfi


