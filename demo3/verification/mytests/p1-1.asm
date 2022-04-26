// Write your assembly program for Problem 1 (a) #1 here.

// jump to "real" begin point of the program
j .begin

// exception handler below:
addi r1, r1, 1	// r1 = 100 + 1 = 101
addi r1, r1, 1	// testing X-X forwarding inside exception handler: r1 = 101 + 1 = 102
rti				// end of exception handler

// "real" begin point of the program
.begin:
lbi  r1, 100		// load 100 into r1
siic r6
halt
