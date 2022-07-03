// test arbituary load and stores
lbi r0, 100
lbi r1, 123
st r1, r0, 2
addi r1, r1, 1
ld r1, r0, 8
addi r1, r1, 1
ld r1, r0, 10
addi r1, r1, 1
ld r1, r0, 12
addi r1, r1, 1
st r1, r0, 4
addi r1, r1, 1
ld r1, r0, 6
halt
