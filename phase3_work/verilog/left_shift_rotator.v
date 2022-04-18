/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 1
    
    A left shifter/rotator sub-module.
 */
module left_shift_rotator(In, shift, ShAmt, out);

	input [15:0]In;			// vector to be left shifted/rotated
	input shift;			// 1 to shift, 0 to rotate
	input [3:0]ShAmt;		// shift/rotate amount, 0 to 15
	output [15:0]out;		// resulting vector of left shift/rotate

	wire [15:0] stage1, stage2, stage3;	// three intermediate stages of left shift/rotate

	// left shift/rotate according to ShAmt[0] and shift only, stay the same or move 1 bits
	assign stage1 = ShAmt[0] ? {In[14:0], shift ? 1'b0 : In[15]} : In;
	// samilar as above, consider ShAmt[1] and move 2 bits if needed
	assign stage2 = ShAmt[1] ? {stage1[13:0], shift ? 2'b00 : stage1[15:14]} : stage1;
	// samilar as above, consider ShAmt[2] and move 4 bits if needed
	assign stage3 = ShAmt[2] ? {stage2[11:0], shift ? 4'h0 : stage2[15:12]} : stage2;
	// samilar as above, consider ShAmt[3] and move 8 bits if needed
	assign out = ShAmt[3] ? {stage3[7:0], shift ? 8'h00 : stage3[15:8]} : stage3;

endmodule
