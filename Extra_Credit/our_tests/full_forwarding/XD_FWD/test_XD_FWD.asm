lbi r1, 0            // r1 = 0
nop
nop
nop
addi r2, r1, 1       // r2 = r1 + 1 = 1
addi r1, r1, 1       // r1 = r1 + 1 = 1
beqz r2, .label      // Branch to .label if r2 equals to 0. With X->D forwarding, we will not need to stall 
					 // at the decode stage of branch instruction
addi r2, r2, 1       // r2 = r2 + 1 = 2
.label:
addi r1, r1, 1       // r2 = 2
halt