# x10 will store the number of passed tests
jal x1, begin

add x10, x10, x11

success:
jal x1, success

# Endless loop, FAIL
fail:
jal x1, fail

begin:
li x11, 0x00000001
jalr x1, 4(x0)
jal x1, fail
