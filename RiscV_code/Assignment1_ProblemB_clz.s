# Assignment1_ProblemB_clz.s
# clz (Count Leading Zeros)?

.data
inputs:
    .word 0x00000000  # Case 1: 0
    .word 0x00000044  # Case 2: 68
    .word 0xFFFFFFFF  # Case 3: 4294967295

expected_outputs:
    .word 32
    .word 25
    .word 0

str_case:   .string "Test Case "
str_pass:   .string " PASS\n"
str_fail:   .string " FAIL\n"

.text
main:
    li s0, 3                # s0 amount of test
    la s1, inputs           # s1 pointers of inputs
    la s2, expected_outputs # s2 pointers of expected_outputs
    li s3, 1                # s3 case_counter 

loop:
    lw a0, 0(s1) # load input
    lw a1, 0(s2) # load expected_outputs
    
    jal ra, clz  # run clz
    
    mv a2, s3    # load str
    jal ra, print_result

    addi s1, s1, 4      # next input
    addi s2, s2, 4      # next expected_output
    addi s3, s3, 1      # case_counter
    addi s0, s0, -1     # loop_counter

    bnez s0, loop       # check loop_counter
    li a7, 10           # ecall: exit
    ecall
    

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
    jr ra

print_result:

    mv t0, a0   # t0 = clz_return
    mv t1, a1   # t1 = expected_outputs
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
    jr ra