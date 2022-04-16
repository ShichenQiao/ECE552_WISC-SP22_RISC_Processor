/*
	CS/ECE 552 Spring '22

	Filename        : branchJumpD.v
	Description     : This module handles branch instructions and J and JAL instructions.
*/
module branchJumpD (
	// Outputs
	err, branchJumpDTarget, branchJumpDCondition,
	// Inputs
	branchOp, Rs, immExt, PC_plus_two, Branch, JumpD, D
);
	input [1:0] branchOp;			// which is Instruction[12:11], 00: BEQZ, 01: BNEZ, 10: BLTZ, 11: BGEZ
	input [15:0] Rs;
	input [15:0] immExt;
	input [15:0] PC_plus_two;
	input Branch;
	
	input JumpD;
	input [10:0] D;					// which is Instruction[10:0]
	
	output err;
	output [15:0] branchJumpDTarget;
	output branchJumpDCondition;		// asserted when branch condition is met
	
	reg err_branchOp;
	wire [15:0] b;
	reg branchCondition;
	
	always @(*) begin
		err_branchOp = 1'b0;
		branchCondition = 1'b0;
		
		case(branchOp)
			2'b00: branchCondition = ~(|Rs);		// (Rs == 0)
			2'b01: branchCondition = |Rs;			// (Rs != 0)
			2'b10: branchCondition = Rs[15];		// (Rs < 0)
			2'b11: branchCondition = ~Rs[15];		// (Rs >= 0)
			default: err_branchOp = 1'b1;
		endcase
	end
	
	assign b = JumpD ? {{5{D[10]}}, D} : immExt;
	
	cla_16b PC_adder(
		.sum(branchJumpDTarget),
		.c_out(),					// not used
		.a(PC_plus_two),
		.b(b),
		.c_in(1'b0)					// no carry in
	);
	
	assign branchJumpDCondition = branchCondition | JumpD;
	
	assign err = err_branchOp | (Branch & JumpD);
	
endmodule
