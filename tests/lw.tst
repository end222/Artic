# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

la x1, tdat

# Test 1
lw x2 0(x1)
li x3, 0x00FF00FF
bne x2, x3, fail
add x10, x10, x11

# Test 2
lw x2 4(x1)
li x3, 0xFF00FF00
bne x2, x3, fail
add x10, x10, x11

# Test 3
lw x2 8(x1)
li x3, 0x0FF00FF0
bne x2, x3, fail
add x10, x10, x11

# Test 4
lw x2 12(x1)
li x3, 0xF00FF00F
bne x2, x3, fail
add x10, x10, x11

# From now on, using negative offset

la x1, tdat2

# Test 5
lw x2 -12(x1)
li x3, 0x00FF00FF
bne x2, x3, fail
add x10, x10, x11

# Test 6
lw x2 -8(x1)
li x3, 0xFF00FF00
bne x2, x3, fail
add x10, x10, x11

# Test 7
lw x2 -4(x1)
li x3, 0x0FF00FF0
bne x2, x3, fail
add x10, x10, x11

# Test 8
lw x2 0(x1)
li x3, 0xF00FF00F
bne x2, x3, fail
add x10, x10, x11


success:
jal x1, success

tdat:
.word 0x00FF00FF
.word 0xFF00FF00
.word 0x0FF00FF0
tdat2:
.word 0xF00FF00F
