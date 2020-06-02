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
jal x1, b
jal x0, fail
a:
jal x1, c
b:
jal x1, a
jal x1, fail

c:
add x10, x10, x11

success:
jal x1, success
