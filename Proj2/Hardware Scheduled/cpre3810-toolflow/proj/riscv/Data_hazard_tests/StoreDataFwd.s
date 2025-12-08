.data
myword: .word 109       # reserve one word

.text
.globl main

main:
    addi x2, x0, 0xAB
    la   x1, myword    # get valid RAM address
    sw   x2, 4(x1)         # forwarding ALUResult => EX/MEM_rs2_data

end:
    wfi

