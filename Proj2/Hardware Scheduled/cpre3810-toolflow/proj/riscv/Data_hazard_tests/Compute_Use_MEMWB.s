.text
.globl main

main:
    addi x1, x0, 7        # producer
    addi x0, x0, 0        # bubble (forces value to MEM/WB)
    add   x2, x1, x1      # consumer must get MEM/WB->EX forwarded value

end:
    wfi


