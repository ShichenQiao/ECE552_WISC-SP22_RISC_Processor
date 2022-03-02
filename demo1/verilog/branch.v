/*
	CS/ECE 552 Spring '20

	Filename        : branch.v
	Description     : This is the module handles branch instructions of the processor.
*/
module branch (
	// Outputs
	err, branchTarget, branchCondition,
	// Inputs
	branchOp, Rs, Imm, PC_plus_two, Branch
);
	input [1:0] branchOp;			// which is Instruction[12:11], 00: BEQZ, 01: BNEZ, 10: BLTZ, 11: BGEZ
	input [15:0] Rs;
	input [7:0]	Imm;				// which is Instruction[7:0]
	input [15:0] PC_plus_two;
	input Branch;
	
	output reg err;
	output [15:0] branchTarget;
	output reg branchCondition;		// asserted when branch condition is met
	
	reg err_branchOp, err_PC_potential_Ofl;
	
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
	
	cla_16b PC_adder(
		.sum(branchTarget),
		.c_out(err_PC_potential_Ofl),
		.a(PC_plus_two),
		.b({{8{Imm[7]}}, Imm}),		// I(sign ext.)
		.c_in(1'b0)					// no carry in
	);
	
	assign err = err_branchOp | (Branch & err_PC_potential_Ofl);
	
endmodule
