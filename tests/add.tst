# x10 will store the number of passed tests
jal x1, 4

# Endless loop, FAIL
jal x1, -4

# Test 1
li x1, 0x00000000
li x2, 0x00000000
li x3, 0x00000000
add x4, x1, x2
bne x3, x4, -24
addi x10, x10, 1

# Test 2
li x1, 0x00000001
li x2, 0x00000001
li x3, 0x00000002
add x4, x1, x2
bne x3, x4, -48
addi x10, x10, 1

# Test 3
li x1, 0xffff8000
li x2, 0x00000000
li x3, 0xffff8000
add x4, x1, x2
bne x3, x4, -72
addi x10, x10, 1

# Test 4
li x1, 0xffff8000
li x2, 0x80000000
li x3, 0x7fff8000
add x4, x1, x2
bne x3, x4, -96
addi x10, x10, 1

# Endless loop, SUCCESS
jal x1, -4
