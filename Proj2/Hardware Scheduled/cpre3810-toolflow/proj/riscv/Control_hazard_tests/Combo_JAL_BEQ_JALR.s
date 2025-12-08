.text
.globl main

main:
    la  x6, JUMPC
    jal x1, JUMPA
    addi x2, x0, 12        # flushed

JUMPA:  
    beq x0, x0, JUMPB       # taken
    addi x3, x0, 34         # flushed

JUMPB:  
    jalr x4, x6, 0          # jump again using x6 value
    addi x5, x0, 56         # flushed

JUMPC:  
    nop                     # final landing zone
end:
    wfi


