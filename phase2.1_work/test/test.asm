
lbi r0, 0

ld r0, r0, 0x1F // Load R0 value from memory

// RAW dependency requires MEM->EX forwarding
// r0 is being loaded from memory and is used as an operand in the next instruction
// MEM-> Rd

addi r0, r0, 0x01 // R0 = R0 + 1

halt
