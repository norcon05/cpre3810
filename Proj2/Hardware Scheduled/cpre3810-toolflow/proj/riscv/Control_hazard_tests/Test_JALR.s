.text
.globl main

main:
    la   x5, target
    jalr x6, x5, 0          # JALR: EX-stage PC redirect
    addi x7, x0, 77         # MUST be flushed

target:
    addi x8, x0, 55

end:
    wfi



