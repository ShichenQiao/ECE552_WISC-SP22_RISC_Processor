// Write your assembly program for Problem 1 (a) #2 here.

// jump to "real" begin point of the program
j .begin

// exception handler below:
ld   r3, r1, 0  // load from mem location, r3 = M[100] = 15
addi r3, r3, 1	// testing M-X forwarding inside exception handler: r3 = 15 + 1 = 16
rti				// end of exception handler

// "real" begin point of the program
.begin:
lbi  r1, 100    // mem location
lbi  r2, 15     // value to store
lbi  r3, 0      // clear r3
st   r2, r1, 0  // Mem[100] <- 15
siic r6
halt
