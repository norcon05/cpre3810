.text
.globl main

main:
    addi x1, x0, 5
    addi x2, x0, 5

    bne  x1, x2, target     # NOT TAKEN
    addi x3, x0, 3          # should execute

target:
    addi x4, x0, 44

end:
    wfi



