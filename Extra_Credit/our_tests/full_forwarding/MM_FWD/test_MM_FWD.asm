// test MEM to MEM forwarding
lbi r0, 123
lbi r1, 100
st r0, r1, 0		// MEM[100] <- 123, make sure later access hits
nop					// to prevent I Cache stall when M-M forwarding
ld r2, r1, 0		// r2 <- 123
st r2, r1, 2		// MEM[102] <- 123, r2 is M-M forwarded
ld r3, r1, 2		// r3 <- 123
halt