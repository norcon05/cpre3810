.text
.globl main
.data
B: .word 8

main:
    addi x1, x0, 5         # ALU producer
    add  x2, x1, x1        # ALU consumer (EX/MEM->EX forward)
    la   x10, B
    lw   x3, 0(x10)        # load producer
    add  x4, x3, x2        # consumes load & prior ALU result simultaneously

end:
    wfi


