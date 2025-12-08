.text
.globl main

main:
    jal x1, T1              # redirects PC, flushes next 2 instructions
    beq x0, x0, BAD         # MUST be flushed
    addi x2, x0, 222        # MUST be flushed

BAD:
    addi x4, x0, 77         # should not execute

T1:
    addi x3, x0, 33

end:
    wfi


