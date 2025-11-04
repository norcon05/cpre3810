###############################################################
# Control Flow Instruction Test (No Print)
# Demonstrates all branch/jump instructions and recursion depth >= 5
###############################################################

.text
###############################################################
# Main Program
###############################################################
main:
      ###########################################################
      # Initialize stack pointer and counter
      ###########################################################
      addi  sp, sp, -64           # allocate stack space
      addi  s0, zero, 5           # recursion depth = 5
      jal   ra, level1            # start nested calls

after_calls:
      addi  sp, sp, 64            # restore stack
      j     exit_program


###############################################################
# LEVEL 1 Function
###############################################################
level1:
      addi  sp, sp, -16
      sw    ra, 12(sp)
      addi  s0, s0, -1

      # Branch instruction (beq)
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

      # Branch instruction (bne)
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

      # Branch instruction (blt)
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

      # Branch instruction (bge)
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

      # Unsigned branches
      bltu  s0, zero, ret5     # will not be taken
      bgeu  s0, zero, ret5     # always taken (unsigned)
      
ret5:
      lw    ra, 12(sp)
      addi  sp, sp, 16
      jalr  zero, 0(ra)


###############################################################
# Program Exit
###############################################################
exit_program:
      wfi                        # wait for interrupt / halt
