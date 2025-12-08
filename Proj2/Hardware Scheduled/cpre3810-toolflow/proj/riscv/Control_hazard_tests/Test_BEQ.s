.text
.globl main

main:
    addi x1, x0, 5
    addi x2, x0, 5

    beq  x1, x2, target     # branch TAKEN → flush IF/ID and ID/EX
    addi x3, x0, 11         # flushed
    addi x3, x0, 22         # flushed

target:
    addi x4, x0, 100        # should execute

end:
    wfi


