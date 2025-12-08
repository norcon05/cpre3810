.text
.globl main

main:
    addi x2, x0, 0xABCD    # store data
    sw   x2, 4(x0)         # forwarding ALUResult => EX/MEM_rs2_data

end:
    wfi

