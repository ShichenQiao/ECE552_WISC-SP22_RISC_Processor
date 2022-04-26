// Write your assembly program for Problem 2 (a) #1 here.

// with predict-not-taken, no stall is needed.
lbi  r1, 5			// some nonzero value
nop
nop
nop
beqz r1, .end		// branch should not be taken.
nop
nop
beqz r1, .end		// branch should not be taken.
nop
nop
.end:
halt				// when r1 reaches 0, halt the program
