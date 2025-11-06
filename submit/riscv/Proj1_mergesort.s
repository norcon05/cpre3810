# RISC-V Merge Sort Implementation
# Sorts an array of N integers in ascending order using Merge Sort.

.data
arr:    .word 9, 3, 4, 7, 2, -1, 8, 1, 5, 3, 6 , 10   # Unsorted array
N:      .word 11                                      # Array size

.text
###############################################################
# Main program
###############################################################
main:
      la   a0, arr
      la   a1, N
      lw   a1, 0(a1)                     # load N

      ##########################################################
      # Call mergesort(arr, 0, N-1)
      ##########################################################
      la   a0, arr                       # base address
      li   a1, 0                         # left index = 0
      la   a2, N
      lw   a2, 0(a2)
      addi a2, a2, -1                    # right index = N - 1
      jal   ra, mergesort

      ##########################################################
      # Program finished
      ##########################################################
      j    exit


###############################################################
# mergesort(arr, left, right)
###############################################################
mergesort:
      addi sp, sp, -24       # increase stack frame to store mid
      sw   ra, 20(sp)        # save return address
      sw   a0, 16(sp)        # save base address
      sw   a1, 12(sp)        # save left
      sw   a2, 8(sp)         # save right
      sw   zero, 4(sp)       # reserved for mid

      # if left >= right, return
      bge  a1, a2, ms_return

      # mid = (left + right) / 2
      add  t0, a1, a2
      srai t0, t0, 1
      sw   t0, 4(sp)         # save mid on stack

      # mergesort(arr, left, mid)
      lw   a0, 16(sp)
      lw   a1, 12(sp)
      lw   a2, 4(sp)         # mid
      jal  ra, mergesort

      # mergesort(arr, mid+1, right)
      lw   a0, 16(sp)
      lw   t0, 4(sp)        # reload mid
      addi a1, t0, 1        # left = mid + 1
      lw   a2, 8(sp)        # right
      jal  ra, mergesort

      # merge(arr, left, mid, right)
      lw   a0, 16(sp)
      lw   a1, 12(sp)
      lw   a2, 4(sp)         # mid restored from stack
      lw   a3, 8(sp)
      jal  ra, merge

ms_return:
      lw   ra, 20(sp)
      addi sp, sp, 24
      jalr zero, 0(ra)


###############################################################
# merge(arr, left, mid, right)
###############################################################
merge:
      addi sp, sp, -160
      sw   ra, 156(sp)
      sw   a0, 152(sp)
      sw   a1, 148(sp)
      sw   a2, 144(sp)
      sw   a3, 140(sp)

      ##########################################################
      # Copy arr[left..right] into temp buffer on stack
      ##########################################################
      addi t0, sp, 0          # temp buffer base
      mv   t1, a1             # i = left
copy_loop:
      bgt  t1, a3, copy_done
      slli t2, t1, 2
      add  t3, a0, t2
      lw   t4, 0(t3)          # arr[i]

      sub  t5, t1, a1         # buffer index = i - left
      slli t5, t5, 2
      add  t6, t0, t5
      sw   t4, 0(t6)          # store into buffer

      addi t1, t1, 1
      j    copy_loop
copy_done:

      ##########################################################
      # Merge the two halves
      ##########################################################
      lw   a0, 152(sp)
      lw   a1, 148(sp)
      lw   a2, 144(sp)
      lw   a3, 140(sp)

      mv   t0, a1             # i = left
      addi t1, a2, 1          # j = mid + 1
      mv   t2, a1             # k = left
      addi t3, sp, 0          # temp buffer base

merge_loop:
      bgt  t0, a2, right_half
      bgt  t1, a3, left_half

      # Compare temp[i-left] and temp[j-left]
      sub  t4, t0, a1
      slli t4, t4, 2
      add  t5, t3, t4
      lw   s0, 0(t5)          # left value

      sub  t4, t1, a1
      slli t4, t4, 2
      add  t5, t3, t4
      lw   s1, 0(t5)          # right value

      ble  s0, s1, take_left
      j    take_right

take_left:
      slli t4, t2, 2
      add  t5, a0, t4
      sw   s0, 0(t5)
      addi t0, t0, 1
      addi t2, t2, 1
      j    merge_loop

take_right:
      slli t4, t2, 2
      add  t5, a0, t4
      sw   s1, 0(t5)
      addi t1, t1, 1
      addi t2, t2, 1
      j    merge_loop

left_half:
      bgt  t0, a2, merge_done
      sub  t4, t0, a1
      slli t4, t4, 2
      add  t5, t3, t4
      lw   s0, 0(t5)
      slli t4, t2, 2
      add  t5, a0, t4
      sw   s0, 0(t5)
      addi t0, t0, 1
      addi t2, t2, 1
      j    left_half

right_half:
      bgt  t1, a3, merge_done
      sub  t4, t1, a1
      slli t4, t4, 2
      add  t5, t3, t4
      lw   s1, 0(t5)
      slli t4, t2, 2
      add  t5, a0, t4
      sw   s1, 0(t5)
      addi t1, t1, 1
      addi t2, t2, 1
      j    right_half

merge_done:
      lw   ra, 156(sp)
      addi sp, sp, 160
      jalr zero, 0(ra)


###############################################################
# Program exit
###############################################################
exit:
      wfi
