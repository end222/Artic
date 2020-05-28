# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001

# Test 1

li x1, 0x00000000
li x2, 0x00000000
beq x1, x2, b
jal x0, fail
a:
jal x1, c
b:
beq x1, x2, a
jal x1, fail

c:
add x10, x10, x11

# Test 2

li x1, 0xFFFFFFFF
li x2, 0xFFFFFFFF
beq x1, x2, e
jal x0, fail
d:
jal x1, f
e:
beq x1, x2, d
jal x1, fail

f:
add x10, x10, x11

# Test 3

li  x1, 0x00000001
li  x2, 0x00000010
beq x1, x2, g
jal x1, h
g:
jal x1, fail
h:
beq x1, x2, g

add x10, x10, x11
