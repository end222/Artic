# x10 will store the number of passed tests
jal x1, begin

# Endless loop, FAIL
fail:
jal x1, fail

# Handler routine
handler:
add x10, x10, x11
loop:
jal x1, loop

begin:
li x11, 0x00000001
la x2, handler
# 504 (1F8) is mapped to the misaligned address exception handler
sw x2, 504(x0)
# Misaligned load
sw x2, 3(x0)
jal x1, fail
