.data
myword: .word 100             # reserve space

.text
.globl main
main:
    la   x1, myword        # load address of myword
    sw   x2, 0(x1)         # store uses forwarded ALU result for address

end:
    wfi


