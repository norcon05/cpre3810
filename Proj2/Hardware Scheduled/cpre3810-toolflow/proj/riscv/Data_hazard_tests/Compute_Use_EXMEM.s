.text
.globl main

main:
    # Compute-use: result needed immediately in the next cycle
    addi x1, x0, 5        # produces x1 in EX stage
    add  x2, x1, x1       # consumes x1 in EX (requires EX/MEM->EX forward)

    sub  x3, x2, x1       # also consumes forwarded values

end:
    wfi


