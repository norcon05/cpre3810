.text
.globl main

main:
    addi x1, x0, 100       # compute address
    sw   x0, 0(x1)         # store uses forwarded ALU result for address

end:
    wfi


