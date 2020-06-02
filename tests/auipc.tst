# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
# Test 1: pc = 0x8
auipc x4, 0x00000

# Test 2: pc = 0xC
auipc x5, 0xFFFFF

# Test 3: pc = 0x10
auipc x6, 0x7FFFF

# Test 4: pc = 0x14
auipc x7, 0x80000

li x11, 0x00000001

li x12, 0x00000008
li x13, 0xFFFFF00C
li x14, 0x7FFFF010
li x15, 0x80000014

bne x4, x12, fail
add x10, x10, x11
bne x5, x13, fail
add x10, x10, x11
bne x6, x14, fail
add x10, x10, x11
bne x7, x15, fail
add x10, x10, x11

# Endless loop, SUCCESS
success:
jal x1, success
