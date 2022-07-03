// Write your assembly program for Problem 1 (a) #3 here.

// jump to "real" begin point of the program
j .begin

// exception handler below:
ld   r5, r1, 0  // load from mem location, r5 = M[60] = 79
st   r5, r4, 8  // testing M-M forwarding inside exception handler: Mem[36 + 8] <- 79
rti				// end of exception handler

// "real" begin point of the program
.begin:
lbi  r1, 60     // mem location
lbi  r2, 79     // value to store
lbi  r3, 0      // clear r3
lbi  r4, 36		// another mem location
lbi  r5, 0      // clear r5
st   r2, r1, 0  // Mem[60] <- 79
siic r6
halt			// program should return to here and halt if both siic and rti are good
