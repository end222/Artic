# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

# Test 1
li x1, 0x00FF0F00
li x3, 0xFF00F00F
xori x4, x1, 0xF0F
bne x3, x4, fail
add x10, x10, x11

# Test 2
li x1, 0x0FF00FF0
li x3, 0x0FF00F00
xori x4, x1, 0x0F0
bne x3, x4, fail
add x10, x10, x11

# Test 3
li x1, 0x00FF08FF
li x3, 0x00FF0FF0
xori x4, x1, 0x70F
bne x3, x4, fail
add x10, x10, x11

# Test 4
li x1, 0xF00FF0FF
li x3, 0xF00FF00F
xori x4, x1, 0x0F0
bne x3, x4, fail
add x10, x10, x11

# Test 5
li x1, 0x0FF00FF0
li x3, 0x00FF0FF0
xori x4, x1, 0x0F0
bne x3, x4, fail
add x10, x10, x11

# Test 6
li x1, 0x00FF0FF0
li x3, 0x00FF08FF
xori x4, x1, 0x70F
bne x3, x4, fail
add x10, x10, x11

# Test 7
li x1, 0xF00FF00F
li x3, 0xF00FF0FF
xori x4, x1, 0x0F0
bne x3, x4, fail
add x10, x10, x11

# Test 8
li x1, 0x0FF00FF0
li x3, 0x0FF00F00
xori x4, x1, 0x0F0
bne x3, x4, fail
add x10, x10, x11

# Endless loop, SUCCESS
success:
jal x1, success
