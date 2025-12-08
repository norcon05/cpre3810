.data
testdata: .word 0x00000005

.text
.globl main

main:
    la   x10, testdata
    lw   x1, 0(x10)       # load -> produces in MEM stage
    add  x2, x1, x1       # MUST stall 1 cycle, then forward MEM/WB->EX

end:
    wfi


