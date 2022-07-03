/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 1
    
    A arithmetic/logical right shifter sub-module.
 */
module right_ari_log_shifter(In, logical, ShAmt, out);

	input [15:0]In;			// vector to be arithmetic/logical right shifted
	input logical;			// 1 to logical right shift, 0 to arithmetic right shift
	input [3:0]ShAmt;		// shift amount, 0 to 15
	output [15:0]out;		// resulting vector of arithmetic/logical right shift

	wire [15:0] stage1, stage2, stage3;	// three intermediate stages of arithmetic/logical right shift
	
	// arithmetic/logical right shift according to ShAmt[0] and logical only, stay the same or move 1 bits
	assign stage1 = ShAmt[0] ? {logical ? 1'b0 : In[15], In[15:1]} : In;
	// samilar as above, consider ShAmt[1] and move 2 bits if needed
	assign stage2 = ShAmt[1] ? {logical ? 2'b00 : {2{In[15]}}, stage1[15:2]} : stage1;
	// samilar as above, consider ShAmt[2] and move 4 bits if needed
	assign stage3 = ShAmt[2] ? {logical ? 4'h0 : {4{In[15]}}, stage2[15:4]} : stage2;
	// samilar as above, consider ShAmt[3] and move 8 bits if needed
	assign out = ShAmt[3] ? {logical ? 8'h00 : {8{In[15]}}, stage3[15:8]} : stage3;

endmodule
