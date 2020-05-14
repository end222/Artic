# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

la x1, tdat

# Test 1
lbu x2 0(x1)
li x3, 0x000000FF
bne x2, x3, fail
add x10, x10, x11

# Test 2
lbu x2 4(x1)
li x3, 0x00000000
bne x2, x3, fail
add x10, x10, x11

# Test 3
lbu x2 8(x1)
li x3, 0x000000F0
bne x2, x3, fail
add x10, x10, x11

# Test 4
lbu x2 12(x1)
li x3, 0x0000000F
bne x2, x3, fail
add x10, x10, x11

# From now on, using negative offset

la x1, tdat2

# Test 5
lbu x2 -12(x1)
li x3, 0x000000FF
bne x2, x3, fail
add x10, x10, x11

# Test 6
lbu x2 -8(x1)
li x3, 0x00000000
bne x2, x3, fail
add x10, x10, x11

# Test 7
lbu x2 -4(x1)
li x3, 0x000000F0
bne x2, x3, fail
add x10, x10, x11

# Test 8
lbu x2 0(x1)
li x3, 0x0000000F
bne x2, x3, fail
add x10, x10, x11


success:
jal x1, success

tdat:
.word 0x000000FF
.word 0x00000000
.word 0x000000F0
tdat2:
.word 0x0000000F
