/*
	CS/ECE 552 Spring '20

	Filename        : right_shift_rotator.v
	Description     : A right shifter/rotator sub-module.
*/
module right_shift_rotator(In, shift, ShAmt, out);

	input [15:0]In;			// vector to be right shifted/rotated
	input shift;			// 1 to logical shift right, 0 to rotate right
	input [3:0]ShAmt;		// shift/rotate amount, 0 to 15
	output [15:0]out;		// resulting vector of right shift/rotate

	wire [15:0] stage1, stage2, stage3;	// three intermediate stages of right shift/rotate
	
	// logical right shift / right rotate according to ShAmt[0] and shift only, stay the same or move 1 bits
	assign stage1 = ShAmt[0] ? {shift ? 1'b0 : In[0], In[15:1]} : In;
	// samilar as above, consider ShAmt[1] and move 2 bits if needed
	assign stage2 = ShAmt[1] ? {shift ? 2'b00 : stage1[1:0], stage1[15:2]} : stage1;
	// samilar as above, consider ShAmt[2] and move 4 bits if needed
	assign stage3 = ShAmt[2] ? {shift ? 4'h0 : stage2[3:0], stage2[15:4]} : stage2;
	// samilar as above, consider ShAmt[3] and move 8 bits if needed
	assign out = ShAmt[3] ? {shift ? 8'h00 : stage3[7:0], stage3[15:8]} : stage3;

endmodule
