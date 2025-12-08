.text
.globl main

main:
    addi x1, x0, 42       # writes in WB stage
	nop
	nop                   # Pushes the write to WB stage
    addi x2, x1, 1        # must read x1 in ID in same cycle it is written

end:
    wfi


