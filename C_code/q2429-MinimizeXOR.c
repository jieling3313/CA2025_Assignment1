#include <stdio.h>
#include <stdint.h>

int branchless_clz(uint32_t x) {
    if (x == 0) {return 32;}
    int count = 0;
    if ((x >> 16) == 0) { count += 16; x <<= 16; }
    if ((x >> 24) == 0) { count += 8;  x <<= 8; }
    if ((x >> 28) == 0) { count += 4;  x <<= 4; }
    if ((x >> 30) == 0) { count += 2;  x <<= 2; }
    if ((x >> 31) == 0) { count += 1; }
    return count;
}

int popcount(uint32_t n) {
    int count = 0;
    while (n > 0) {
        count += (n & 1);
        n >>= 1;
    }
    return count;
}

uint32_t minimizeXor(uint32_t num1, uint32_t num2) {
    int k = popcount(num2);
    uint32_t x = 0;
    int start_bit = 31 - branchless_clz(num1);
    for (int i = start_bit; i >= 0 && k > 0; --i) {
        if ((num1 >> i) & 1) {
            x |= (1 << i);
            k--;
        }
    }
    if (k > 0) {
        for (int i = 0; i < 32 && k > 0; ++i) {
            if (!((x >> i) & 1)) {
                x |= (1 << i);
                k--;
            }
        }
    }
    return x;
}

int main() {
    /* Case1, Input: num1 =  3, num2 =  5, expected_output =  3
     * Case2, Input: num1 =  1, num2 = 12, expected_output =  3
     * Case3, Input: num1 = 25, num2 = 72, expected_output = 24
     * Case4, Input: num1 = 10, num2 =  1, expected_output =  8 */
    
    uint32_t all_num1[] = {3, 1, 25, 10};
    uint32_t all_num2[] = {5, 12, 72, 1};
    uint32_t all_expected[] = {3, 3, 24, 8};

    int num_test_cases = sizeof(all_num1) / sizeof(all_num1[0]);

    for (int i = 0; i < num_test_cases; i++) {
        uint32_t num1 = all_num1[i];
        uint32_t num2 = all_num2[i];
        uint32_t expected_case = all_expected[i];
        uint32_t result = minimizeXor(num1, num2);

        printf("--- Test Case %d ---\n", i + 1);
        printf("Input: num1 = %u, num2 = %u\n", num1, num2);
        printf("Output: %u (Expected: %u)", result, expected_case);

        if (result == expected_case) {printf("...PASS\n");} 
        else {printf("...FAIL\n");}
        printf("------------------------------------\n");
    }

    return 0;
}