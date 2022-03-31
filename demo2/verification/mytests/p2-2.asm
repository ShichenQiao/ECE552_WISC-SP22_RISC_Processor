// Write your assembly program for Problem 2 (a) #2 here.

lbi  r1, -5			// loop variable r1 with initial value -5
.loop:
beqz r1, .end		// exit the loop when r1 reaches 0
addi r1, r1, 1		// increment r1 by 1 in each iteration
j	 .loop
.end:
halt
