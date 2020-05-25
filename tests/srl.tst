# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

# Test 1
li x1, 0x80000000
li x2, 0x00000007
li x3, 0x01000000
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11

# Test 2
li x1, 0x80000000
li x2, 0x0000000E
li x3, 0x00020000
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11

# Test 3
li x1, 0x80000000
li x2, 0x0000001F
li x3, 0x00000001
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11

# Test 4
li x1, 0x21212121
li x2, 0xFFFFFFC0
li x3, 0x21212121
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11

# Test 5
li x1, 0x21212121
li x2, 0x10909090
li x3, 0xFFFFFFC1
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11

# Test 6
li x1, 0x21212121
li x2, 0xFFFFFFC7
li x3, 0x00424242
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11

# Test 7
li x1, 0x21212121
li x2, 0xFFFFFFCE
li x3, 0x00008484
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11

# Test 8
li x1, 0x21212121
li x2, 0xFFFFFFFF
li x3, 0x00000000
srl x4, x1, x2
bne x3, x4, fail
add x10, x10, x11


# Endless loop, SUCCESS
success:
jal x1, success
