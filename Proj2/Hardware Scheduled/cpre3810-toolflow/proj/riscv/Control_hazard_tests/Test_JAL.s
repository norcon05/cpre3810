.text
.globl main

main:
    addi x1, x0, 1          # harmless setup
    
    jal x2, target          # JAL: causes PC change in EX stage
    addi x3, x0, 99         # MUST be flushed (should not execute)

target:
    addi x4, x0, 42         # observable result

end:
    wfi


