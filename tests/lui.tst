# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

# Test 1
li x3, 0x00000000
lui x4, 0x00000
bne x3, x4, fail
add x10, x10, x11

# Test 2
li x3, 0xFFFFF000
lui x4, 0xFFFFF
bne x3, x4, fail
add x10, x10, x11

# Test 3
li x3, 0x7FFFF000
lui x4, 0x7FFFF
bne x3, x4, fail
add x10, x10, x11

# Test 4
li x3, 0x80000000
lui x4, 0x80000
bne x3, x4, fail
add x10, x10, x11

# Endless loop, SUCCESS
success:
jal x1, success
