# Assignment1_Problem2429_MinimizeXOR_clz.s
# Input, a0: num1, a1: num2

.data
inputs:
    .word 3, 5      # Case 1: num1 =  3, num2 =  5
    .word 1, 12     # Case 2: num1 =  1, num2 = 12
    .word 25, 72    # Case 3: num1 = 25, num2 = 72
    .word 10, 1     # Case 4: num1 = 10, num2 =  1

expected_outputs:
    .word 3
    .word 3
    .word 24
    .word 8

str_case:   .string "Test Case "
str_pass:   .string " PASS\n"
str_fail:   .string " FAIL\n"

.text
.global main

main:
    li s0, 4                # s0 amount of test
    la s1, inputs           # s1 pointers of inputs
    la s2, expected_outputs # s2 pointers of expected_outputs
    li s3, 1                # s3 case_counter


loop:

    lw a0, 0(s1)            # load input num1
    lw a1, 4(s1)            # load input num2
    lw s5, 0(s2)            # load expected_outputs **s5** 

    jal ra, minimizeXor     # run minimizeXor 


    mv a1, s5               # expected_output(a1)
    mv a2, s3               # case_counter(a2)
    jal ra, print_result  

    addi s1, s1, 8          # next input num1
    addi s2, s2, 4          # next input num2
    addi s3, s3, 1          # case_counter
    addi s0, s0, -1         # loop_counter

    bnez s0, loop           # check loop_counter
    li a7, 10               # ecall: exit
    ecall

.globl minimizeXor
minimizeXor:
    # stack ra, s0, s1, s2, s3, s4
    addi sp, sp, -24
    sw   ra, 20(sp)
    sw   s0, 16(sp) # s0: num1
    sw   s1, 12(sp) # s1: bit_budget (k) from num2
    sw   s2, 8(sp)  # s2: result x
    sw   s3, 4(sp)  # s3: loop counter (i)
    sw   s4, 0(sp)  # s4: temp bit check

    mv   s0, a0 # num1(s0)

    # k = popcount(num2)
    mv   a0, a1 # num2(a1) -> a0/popcount
    jal  ra, popcount
    mv   s1, a0 # s1 = k
    
    li   s2, 0  # result x = 0

    # Greedy search num1 high bits -> greedy_high_loop 
    mv   a0, s0 # num1(s0) -> a0/branchless_clz
    beqz a0, skip_high_loop # if (num1 == 0){ skip }
    jal  ra, clz
    
    li   t0, 31
    sub  s3, t0, a0 # s3 = i = msb_position of num1
    j    greedy_high_loop 
skip_high_loop:
    # if num1 == 0
    j fill_low_bits_check
    
greedy_high_loop:
    bltz s3, fill_low_bits_check # while (i >= 0 && k > 0)
    beqz s1, fill_low_bits_check

    # t1 = (num1 >> i) & 1
    srl  t1, s0, s3
    andi t1, t1, 1
    
    beqz t1, greedy_high_continue # if (t1 == 0){ skip }
    
    # num1 (t1 == 1){ x |= (1 << i) }
    li   t2, 1
    sll  t2, t2, s3
    or   s2, s2, t2 # x |= (1 << i)
    
    addi s1, s1, -1 # k--

greedy_high_continue:
    addi s3, s3, -1 # i--
    j    greedy_high_loop

fill_low_bits_check:
    beqz s1, done # if (k == 0){ done }

    # low_bit -> 1
    li   s3, 0 # i = 0

fill_low_loop:
    beqz s1, done # while (k > 0)

    srl  t1, s2, s3  # t1 = (x >> i) & 1
    andi t1, t1, 1
    
    bnez t1, fill_low_continue # if(bit == 1){ skip }
    
    # if bit(i/s3) == 0
    li   t2, 1
    sll  t2, t2, s3
    or   s2, s2, t2    # x |= (1 << i)
    
    addi s1, s1, -1    # k--

fill_low_continue:
    addi s3, s3, 1     # i++ 
    li t0, 32
    bge s3, t0, done   # if(i == 32){ done }
    j    fill_low_loop 

done:
    mv   a0, s2 # result(a0)
    lw   s4, 0(sp)
    lw   s3, 4(sp)
    lw   s2, 8(sp)
    lw   s1, 12(sp)
    lw   s0, 16(sp)
    lw   ra, 20(sp)
    addi sp, sp, 24
    ret


popcount:
    li   t0, 0 # count = 0
    mv   t1, a0     # n(t1) 
popcount_loop:
    beqz t1, popcount_done
    andi t2, t1, 1
    add  t0, t0, t2
    srli t1, t1, 1
    j    popcount_loop
    
popcount_done:
    mv a0, t0
    ret


clz:
    li t0, 32 # n
    li t1, 16 # c

clz_loop:
    srl t2, a0, t1        # y = x >> c
    beqz t2, clz_continue # if y==c, c >>= 1
clz_shift_found:
    sub t0, t0, t1        # n -= c
    mv a0, t2             # x = y
clz_continue:
    srli t1, t1, 1        # c >>= 1
    bnez t1, clz_loop
    sub a0, t0, a0
    jr ra
 
print_result:
    mv t0, a0   # t0 = actual_result
    mv t1, a1   # t1 = expected_result
    mv t2, a2   # t2 = case_counter
    
    la a0, str_case # print str
    li a7, 4
    ecall
    
    mv a0, t2       # print case_counter
    li a7, 1
    ecall
    
    beq t0, t1, passed
    # failed
    la a0, str_fail
    li a7, 4
    ecall
    j print_end
    
passed:
    la a0, str_pass
    li a7, 4
    ecall
    
print_end:
    ret