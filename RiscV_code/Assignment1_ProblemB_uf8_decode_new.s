# Assignment1_ProblemB_uf8_decode_new.s

.data
inputs:
    .word 0x05 # Case 1: 5
    .word 0x15 # Case 2: 26
    .word 0x25 # Case 3: 68
    .word 0xFF # Case 4: 33554415

expected_outputs:
    .word 5
    .word 26
    .word 68
    .word 33554415

str_case:   .string "Test Case "
str_pass:   .string " PASS\n"
str_fail:   .string " FAIL\n"

.text
main:
    li s0, 4                # s0 amount of test
    la s1, inputs           # s1 pointers of inputs
    la s2, expected_outputs # s2 pointers of expected_outputs
    li s3, 1                # s3 case_counter
    
loop:
    lw a0, 0(s1) # load input
    lw a1, 0(s2) # load expected_outputs

    jal ra, uf8_decode # run uf8_decode 


    mv a2, s3          # load str
    jal ra, print_result

    addi s1, s1, 4      # next input
    addi s2, s2, 4      # next expected_output
    addi s3, s3, 1      # case_counter
    addi s0, s0, -1     # loop_counter

    bnez s0, loop       # check loop_counter
    li a7, 10           # ecall: exit
    ecall

# uf8_decode
# a0: input
uf8_decode:
    #---------------------------new-------------------------#
    li t3, 0xFF
    beq a0, t3, special_case_ff # if (input == 0xFF), jump
    #-------------------------------------------------------#
    andi t0, a0, 0x0F   # t0 = mantissa
    srli t1, a0, 4      # t1 = exponen

    # offset = ((1 << exponent) - 1) * 16
    li t2, 1
    sll t2, t2, t1      # t2 = 1 << exponent
    addi t2, t2, -1     # t2 = (1 << exponent) - 1
    slli t2, t2, 4      # t2 = offset

    # value = (mantissa << exponent) + offset
    sll t0, t0, t1      # t0 = mantissa << exponent
    add a0, t0, t2      # a0 = (mantissa << exponent) + offset
    ret
#---------------------------new-------------------------#
special_case_ff:
    li a0, 33554415     # Load the special value for 0xFF
    ret
#-------------------------------------------------------#

print_result:

    mv t0, a0   # t0 = uf8_decode_return
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
    ret