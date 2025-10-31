# RISC-V Merge Sort Implementation
# Sorts an array of N integers in ascending order using Merge Sort.
# Demonstrates recursion, stack usage, and memory manipulation.


.data
arr:    .word 9, 4, 7, 2, 8, 1, 5, 3, 6     # Unsorted array
N:      .word 9                             # Array size

msg_start: .asciz "Unsorted array:\n"
msg_sorted: .asciz "\nSorted array:\n"
space:  .asciz " "
newline:.asciz "\n"

.text
###############################################################
# Main program
###############################################################
main:
      la   a0, msg_start
      li   a7, 4
      ecall                              # print start message

      la   a0, arr
      la   a1, N
      lw   a1, 0(a1)                     # load N
      jal  ra, print_array               # print unsorted array

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
      # Print sorted array
      ##########################################################
      la   a0, msg_sorted
      li   a7, 4
      ecall

      la   a0, arr
      la   a1, N
      lw   a1, 0(a1)
      jal  ra, print_array

      ##########################################################
      # Program finished
      ##########################################################
      j    exit


###############################################################
# mergesort(arr, left, right)
# Recursively splits array and merges sorted halves.
# a0 = base address
# a1 = left index
# a2 = right index
###############################################################
mergesort:
      addi sp, sp, -20
      sw   ra, 16(sp)
      sw   a0, 12(sp)
      sw   a1, 8(sp)
      sw   a2, 4(sp)

      # if left >= right, return
      bge  a1, a2, ms_return

      # mid = (left + right) / 2
      add  t0, a1, a2
      srai t0, t0, 1                     # divide by 2

      # mergesort(arr, left, mid)
      mv   a1, a1                        # left unchanged
      mv   a2, t0                        # right = mid
      jal  ra, mergesort

      # mergesort(arr, mid+1, right)
      lw   a0, 12(sp)
      addi t1, t0, 1                     # left = mid + 1
      mv   a1, t1
      lw   a2, 4(sp)                     # right
      jal  ra, mergesort

      # merge(arr, left, mid, right)
      lw   a0, 12(sp)
      lw   a1, 8(sp)
      mv   a2, t0                        # mid
      lw   a3, 4(sp)                     # right
      jal  ra, merge

ms_return:
      lw   ra, 16(sp)
      addi sp, sp, 20
      jalr zero, 0(ra)


###############################################################
# merge(arr, left, mid, right)
# Merges two sorted halves of arr[left..mid] and arr[mid+1..right]
# a0 = base address
# a1 = left
# a2 = mid
# a3 = right
###############################################################
merge:
      addi sp, sp, -64
      sw   ra, 60(sp)
      sw   a0, 56(sp)
      sw   a1, 52(sp)
      sw   a2, 48(sp)
      sw   a3, 44(sp)

      ##########################################################
      # Copy arr[left..right] into temp buffer on stack
      ##########################################################
      mv   t0, a1             # i = left
      mv   t1, zero           # temp index = 0
copy_loop:
      bgt  t0, a3, copy_done
      slli t2, t0, 2
      add  t3, a0, t2
      lw   t4, 0(t3)
      sw   t4, 0(sp)          # use stack as temporary buffer
      addi sp, sp, -4
      addi t0, t0, 1
      j    copy_loop
copy_done:
      addi sp, sp, 4          # restore stack pointer after last loop iteration

      ##########################################################
      # Merge the two halves
      ##########################################################
      lw   a1, 52(sp)         # left
      lw   a2, 48(sp)         # mid
      lw   a3, 44(sp)         # right
      mv   t1, a1             # i = left
      addi t2, a2, 1          # j = mid + 1
      mv   t3, a1             # k = left

merge_loop:
      bgt  t1, a2, right_half
      bgt  t2, a3, left_half

      # Compare arr[i] and arr[j]
      slli t4, t1, 2
      add  t4, a0, t4
      lw   t5, 0(t4)          # arr[i]
      slli t6, t2, 2
      add  t6, a0, t6
      lw   t7, 0(t6)          # arr[j]
      ble  t5, t7, take_left
      j    take_right

take_left:
      slli t8, t3, 2
      add  t8, a0, t8
      sw   t5, 0(t8)
      addi t1, t1, 1
      addi t3, t3, 1
      j    merge_loop

take_right:
      slli t8, t3, 2
      add  t8, a0, t8
      sw   t7, 0(t8)
      addi t2, t2, 1
      addi t3, t3, 1
      j    merge_loop

left_half:
      bgt  t1, a2, merge_done
      slli t4, t1, 2
      add  t4, a0, t4
      lw   t5, 0(t4)
      slli t8, t3, 2
      add  t8, a0, t8
      sw   t5, 0(t8)
      addi t1, t1, 1
      addi t3, t3, 1
      j    left_half

right_half:
      bgt  t2, a3, merge_done
      slli t6, t2, 2
      add  t6, a0, t6
      lw   t7, 0(t6)
      slli t8, t3, 2
      add  t8, a0, t8
      sw   t7, 0(t8)
      addi t2, t2, 1
      addi t3, t3, 1
      j    right_half

merge_done:
      lw   ra, 60(sp)
      addi sp, sp, 64
      jalr zero, 0(ra)


###############################################################
# print_array(base, N)
# Prints array of N integers separated by spaces.
# a0 = base address
# a1 = number of elements
###############################################################
print_array:
      mv   t0, a0             # pointer to current element
      mv   t1, a1             # remaining elements
print_loop:
      beq  t1, zero, print_done

      lw   a0, 0(t0)          # load integer
      li   a7, 1              # print integer
      ecall

      la   a0, space
      li   a7, 4              # print space
      ecall

      addi t0, t0, 4
      addi t1, t1, -1
      j    print_loop
print_done:
      la   a0, newline
      li   a7, 4
      ecall
      jr   ra


###############################################################
# Program exit
###############################################################
exit:
      wfi

