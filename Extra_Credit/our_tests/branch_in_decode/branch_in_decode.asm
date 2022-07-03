lbi r1, 0            // r1 = 0
beqz r1, .label      // branch if r1 equals 0, will need to flush 2 instructions if branch resolve in execute stage,
					 // while it only needs to flush 1 instruction if branch resolve in branch stage
addi r2, r1, 1       // r2 = r1 + 1 = 1
addi r2, r2, 1       // r2 = r2 + 1 = 2
.label:
addi r2, r1, 1       // r2 = 1
halt