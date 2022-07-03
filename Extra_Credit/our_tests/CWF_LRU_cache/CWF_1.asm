// test basic CWF functions on read misses
lbi r0, 100
ld r1, r0, 6		// read miss, less stall with CWF
addi r1, r1, 1
addi r1, r1, 1
addi r1, r1, 1
addi r1, r1, 1
halt
