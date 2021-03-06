# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

# Test 1
li x1, 0x00000000
li x3, 0x00000000
srai x4, x1, 0x000
bne x3, x4, fail
add x10, x10, x11

# Test 2
li x1, 0x80000000
li x3, 0xC0000000
srai x4, x1, 0x001
bne x3, x4, fail
add x10, x10, x11

# Test 3
li x1, 0x80000000
li x3, 0xFF000000
srai x4, x1, 0x007
bne x3, x4, fail
add x10, x10, x11

# Test 4
li x1, 0x80000000
li x3, 0xFFFE0000
srai x4, x1, 0x00E
bne x3, x4, fail
add x10, x10, x11

# Test 5
li x1, 0x80000000
li x3, 0xFFFFFFFF
srai x4, x1, 0x01F
bne x3, x4, fail
add x10, x10, x11

# Test 6
li x1, 0x7FFFFFFF
li x3, 0x7FFFFFFF
srai x4, x1, 0x000
bne x3, x4, fail
add x10, x10, x11

# Test 7
li x1, 0x7FFFFFFF
li x3, 0x3FFFFFFF
srai x4, x1, 0x001
bne x3, x4, fail
add x10, x10, x11

# Test 8
li x1, 0x7FFFFFFF
li x3, 0x00FFFFFF
srai x4, x1, 0x007
bne x3, x4, fail
add x10, x10, x11

# Endless loop, SUCCESS
success:
jal x1, success
