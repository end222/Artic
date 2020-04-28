la x1, test_data

ld x2 0(x1)
add x3, x2, x2

.data
test_data:
.word 0x00000001
.word 0x00000002
