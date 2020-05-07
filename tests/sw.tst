# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

la x1, tdat

# Test 1
li x2, 0x00AA00AA
sw x2, 0(x1)
lw x3, 0(x1)
bne x2, x3, fail
add x10, x10, x11

# Test 2
li x2, 0xAA00AA00
sw x2, 4(x1)
lw x3, 4(x1)
bne x2, x3, fail
add x10, x10, x11

# Test 3
li x2, 0x0AA00AA0
sw x2, 8(x1)
lw x3, 8(x1)
bne x2, x3, fail
add x10, x10, x11

# Test 4
li x2, 0xA00AA00A
sw x2, 12(x1)
lw x3, 12(x1)
bne x2, x3, fail
add x10, x10, x11

# From now on, using negative offset

la x1, tdat2

# Test 5
li x2, 0x00AA00AA
sw x2, -12(x1)
lw x3, -12(x1)
bne x2, x3, fail
add x10, x10, x11

# Test 6
li x2, 0xAA00AA00
sw x2, -8(x1)
lw x3, -8(x1)
bne x2, x3, fail
add x10, x10, x11

# Test 7
li x2, 0x0AA00AA0
sw x2, -4(x1)
lw x3, -4(x1)
bne x2, x3, fail
add x10, x10, x11

# Test 8
li x2, 0xA00AA00A
sw x2, 0(x1)
lw x3, 0(x1)
bne x2, x3, fail
add x10, x10, x11


success:
jal x1, success

tdat:
.word 0xDEADBEEF
.word 0xDEADBEEF
.word 0xDEADBEEF
.word 0xDEADBEEF
.word 0xDEADBEEF
.word 0xDEADBEEF
.word 0xDEADBEEF
tdat2:
