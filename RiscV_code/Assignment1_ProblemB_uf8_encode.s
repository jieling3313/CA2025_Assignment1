#  Assignment1_ProblemB_uf8_encode_new.s

.data
inputs:
    .word 5          # Case 1
    .word 26         # Case 2
    .word 68         # Case 3
    .word 33554415   # Case 4

expected_outputs:
    .word 0x05
    .word 0x15
    .word 0x25
    .word 0xFF

str_case:   .string "case "
str_pass:   .string " PASS\n"
str_fail:   .string " FAIL\n"

.text
.global main

main:
    li s0, 4              # s0 amount of test
    la s1, inputs         # s1 pointers of inputs
    la s2, expected_outputs # s2 pointers of expected_outputs
    li s3, 1              # s3 case_counter

loop:
    lw a0, 0(s1)          # load input
    lw a1, 0(s2)          # load expected_outputs
    
   jal ra, uf8_encode     # run uf8_encode


    mv a2, s3             # load str
    jal ra, print_result  

    addi s1, s1, 4      # next input
    addi s2, s2, 4      # next expected_output
    addi s3, s3, 1      # case_counter
    addi s0, s0, -1     # loop_counter

    bnez s0, loop       # check loop_counter
    li a7, 10           # ecall: exit
    ecall


# uf8_encode
# a0: input 
uf8_encode:
    addi sp, sp, -8       # Stack -> ra, s0
    sw ra, 4(sp)          # back to loop
    sw s0, 0(sp)          
    mv s0, a0             # s0 = input

    # if (value < 16) return value;
    li t0, 16
    blt a0, t0, encode_done 

    jal ra, clz           # call clz, return a0
    li t0, 31
    sub t1, t0, a0        # t1 = msb = 31 - leading_zeros(a0)

    li t2, 0              # t2 = exponent = 0
    li t3, 0              # t3 = overflow = 0
    li t0, 5
    blt t1, t0, find_exponent # if (msb < 5), skip (16 ~ 31)
    
    addi t2, t1, -4       # exponent(t2) = msb - 4
    li t0, 15
    ble t2, t0, calc_overflow # if (exponent <= 15), calc_overflow
    mv t2, t0                 # or limit exponent at 15


calc_overflow:
    # Calculate inital overflow
    li t4, 0              # t4 = loop counter 'e'
for_overflow_loop:
    bge t4, t2, adjust_overflow # Loop until e >= exponent
    slli t3, t3, 1    # overflow = (overflow << 1) + 16
    addi t3, t3, 16
    addi t4, t4, 1
    j for_overflow_loop

adjust_overflow:
while_adjust_loop:
    blez t2, find_exponent      # break if exponent <= 0
    bge s0, t3, find_exponent   # break if value >= overflow
    addi t3, t3, -16
    srli t3, t3, 1
    addi t2, t2, -1
    j while_adjust_loop

find_exponent:
while_find_loop:
    li t0, 15
    bge t2, t0, calculate_mantissa # break if exponent >= 15
    slli t4, t3, 1
    addi t4, t4, 16                # t4 = next_overflow
    blt s0, t4, calculate_mantissa # if (value < next_overflow), we found the right exponent
    mv t3, t4                      # overflow = next_overflow
    addi t2, t2, 1                 # exponent++
    j while_find_loop

calculate_mantissa:
    # mantissa(t5) = (value(s0) - overflow(t3)) >> exponent(t2);
    sub t5, s0, t3
    srl t5, t5, t2
    slli t2, t2, 4
    or a0, t2, t5

encode_done:
    # Restore stack
    lw s0, 0(sp)
    lw ra, 4(sp)
    addi sp, sp, 8 
    ret

# clz: Count Leading Zeros
# a0: input
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
    ret

print_result:
    mv t0, a0    # t0 = uf8_encode_return
    mv t1, a1    # t1 = expected_outputs
    mv t2, a2    # t2 = case_counter
    
    la a0, str_case # print str
    li a7, 4
    ecall
    
    mv a0, t2    # print case_counter
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