# Comprehensive RISC-V Instruction Test Program
# Demonstrates all required arithmetic, logical, memory,
# and control instructions at least once.

.data
# Reserve memory area for memory load/store tests
test_data:  .word  0x12345678, 0x00000000, 0x11111111, 0x22222222

.text
###############################################################
# Main program start
###############################################################
main:
      la    s0, test_data       # load base address of test_data
      addi  sp, sp, -32         # allocate stack space
      
      ###########################################################
      # Arithmetic operations
      ###########################################################
      addi  s1, zero, 10        # s1 = 10
      addi  s2, zero, 20        # s2 = 20
      add   s3, s1, s2          # s3 = 30
      sub   s4, s2, s1          # s4 = 10
      
      ###########################################################
      # Logical operations
      ###########################################################
      and   s5, s1, s2          # s5 = s1 & s2
      or    s6, s1, s2          # s6 = s1 | s2
      xor   s7, s1, s2          # s7 = s1 ^ s2
      andi  s8, s3, 0x0F        # s8 = s3 & 0x0F
      ori   s9, s3, 0x10        # s9 = s3 | 0x10
      xori  s10, s3, 0xFF       # s10 = s3 ^ 0xFF
      
      ###########################################################
      # Shift operations
      ###########################################################
      sll   s11, s1, s2         # shift left logical
      srl   t0,  s3, s1         # shift right logical
      sra   t1,  s3, s1         # shift right arithmetic
      slli  t2,  s1, 2          # shift left logical immediate
      srli  t3,  s2, 1          # shift right logical immediate
      srai  t4,  s3, 1          # shift right arithmetic immediate
      
      ###########################################################
      # Set-less-than operations
      ###########################################################
      slt   t5, s1, s2          # set if s1 < s2
      slti  t6, s2, 15          # set if s2 < 15
      sltiu t7, s1, 50          # unsigned comparison
      
      ###########################################################
      # Immediate upper and PC-relative
      ###########################################################
      lui   t8, 0x12345         # load upper immediate
      auipc t9, 0x1             # add upper immediate to PC
      
      ###########################################################
      # Memory operations (using stack + test_data)
      ###########################################################
      sw    s3,  0(sp)          # store word
      sh    s1,  4(sp)          # store halfword
      sb    s2,  6(sp)          # store byte
      
      lw    a0,  0(sp)          # load word
      lh    a1,  4(sp)          # load halfword
      lb    a2,  6(sp)          # load byte
      lhu   a3,  4(sp)          # load halfword unsigned
      lbu   a4,  6(sp)          # load byte unsigned
      
      ###########################################################
      # Branch operations
      ###########################################################
      beq   s1, s1, branch_eq   # branch if equal
      nop
      branch_eq:
            bne   s1, s2, branch_ne   # branch if not equal
            nop
      branch_ne:
            blt   s1, s2, branch_lt   # branch if less than
            nop
      branch_lt:
            bge   s2, s1, branch_ge   # branch if greater/equal
            nop
      branch_ge:
            bltu  s1, s2, branch_ltu  # branch if less than (unsigned)
            nop
      branch_ltu:
            bgeu  s2, s1, branch_geu  # branch if greater/equal (unsigned)
            nop
      branch_geu:
      
      ###########################################################
      # Jump and link tests
      ###########################################################
      jal   ra, test_function   # call test_function, store return in ra
      
      after_jal:
            ori   s11, zero, 0x123    # verify we returned correctly
      
      ###########################################################
      # Program done
      ###########################################################
      addi  sp, sp, 32          # restore stack
      j     done

###############################################################
# Subroutine to test JALR return
###############################################################
test_function:
      addi  t0, zero, 42        # some operation
      jalr  zero, 0(ra)         # return to caller
      
###############################################################
# Program end
###############################################################
done:
      wfi                       # wait for interrupt / halt
