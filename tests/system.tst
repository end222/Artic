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
# 508 (1FC) is mapped to the trap handler
sw x2, 508(x0)
# After executing the system instruction the PC should point to the handler routine
system
jal x1, fail
