// Most basic exception handling tests as required in the extra credict description

// jump to "real" begin point of the program
j .begin

// exception handler below: loading 0xBADD to r7
lbi r7, 0xBA
slbi r7, 0xDD
rti				// end of exception handler

// "real" begin point of the program
.begin:
siic r6
halt
