la x1, test_data

lw x2 0(x1)
lw x3 4(x1)
add x4, x2, x2
add x5, x2, x3
add x6, x4, x5

end:
jal x7, end

.data
test_data:
.word 0x00000001
.word 0x00000002
