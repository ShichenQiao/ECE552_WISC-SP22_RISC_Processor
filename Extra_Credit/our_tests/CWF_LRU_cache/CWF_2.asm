// test consequtive load correctness
lbi r0, 100
ld r1, r0, 6
ld r1, r0, 4
ld r1, r0, 2
ld r1, r0, 10
ld r1, r0, 8
ld r1, r0, 0
halt
