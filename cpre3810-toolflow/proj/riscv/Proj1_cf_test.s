# Control Flow Instruction Test
# Demonstrates all branch/jump instructions and recursion depth ≥ 5

.data
msg_start:  .asciz "Starting control-flow test...\n"
msg_done:   .asciz "All control flow instructions executed.\n"
newline:    .asciz "\n"

.text
###############################################################
# Main Program
###############################################################
main:
      ###########################################################
      # Print startup message
      ###########################################################
      la    a0, msg_start
      ori   a7, zero, 4           # Print string syscall
      ecall

      ###########################################################
      # Initialize stack pointer and counter
      ###########################################################
      addi  sp, sp, -64           # allocate stack space
      addi  s0, zero, 5           # recursion depth = 5
      jal   ra, level1            # start nested calls

after_calls:
      ###########################################################
      # Print completion message
      ###########################################################
      la    a0, msg_done
      ori   a7, zero, 4
      ecall

      addi  sp, sp, 64            # restore stack
      j     exit_program


###############################################################
# LEVEL 1 Function
###############################################################
level1:
      addi  sp, sp, -16           # new activation record
      sw    ra, 12(sp)
      addi  s0, s0, -1            # decrement depth counter

      # Use a branch instruction (beq)
      beq   s0, zero, ret1        # if zero, return

      jal   ra, level2            # nested call
ret1:
      lw    ra, 12(sp)
      addi  sp, sp, 16
      jalr  zero, 0(ra)           # return


###############################################################
# LEVEL 2 Function
###############################################################
level2:
      addi  sp, sp, -16
      sw    ra, 12(sp)
      addi  s0, s0, -1

      # Use bne
      bne   s0, zero, continue2
      j     ret2
continue2:
      jal   ra, level3
ret2:
      lw    ra, 12(sp)
      addi  sp, sp, 16
      jalr  zero, 0(ra)


###############################################################
# LEVEL 3 Function
###############################################################
level3:
      addi  sp, sp, -16
      sw    ra, 12(sp)
      addi  s0, s0, -1

      # Use blt
      blt   s0, zero, ret3
      jal   ra, level4
ret3:
      lw    ra, 12(sp)
      addi  sp, sp, 16
      jalr  zero, 0(ra)


###############################################################
# LEVEL 4 Function
###############################################################
level4:
      addi  sp, sp, -16
      sw    ra, 12(sp)
      addi  s0, s0, -1

      # Use bge (taken when s0 >= 0)
      bge   s0, zero, deeper4
      j     ret4
deeper4:
      jal   ra, level5
ret4:
      lw    ra, 12(sp)
      addi  sp, sp, 16
      jalr  zero, 0(ra)


###############################################################
# LEVEL 5 Function
###############################################################
level5:
      addi  sp, sp, -16
      sw    ra, 12(sp)
      addi  s0, s0, -1

      # Use unsigned branches (bltu / bgeu)
      bltu  s0, zero, ret5     # will not be taken
      bgeu  s0, zero, ret5     # always taken (unsigned)
      
      # Just for demonstration, call a print
      la    a0, newline
      ori   a7, zero, 4
      ecall

ret5:
      lw    ra, 12(sp)
      addi  sp, sp, 16
      jalr  zero, 0(ra)


###############################################################
# Program Exit
###############################################################
exit_program:
      wfi                        # wait for interrupt / halt
