/*
	CS/ECE 552 Spring '20

	Filename        : jump.v
	Description     : This is the module handles jump instructions of the processor.
*/
module jump (
	// Outputs
	err, jumpTarget,
	// Inputs
	JumpI, JumpD, D, immExt, Rs, PC_plus_two
);
	input JumpI, JumpD;
	input [10:0] D;					// which is Instruction[10:0]
	input [15:0] immExt;
	input [15:0] Rs;
	input [15:0] PC_plus_two;
	
	output err;
	output [15:0] jumpTarget;
	
	wire [15:0] a, b;
	wire err_PC_potential_Ofl;
	
	assign a = JumpD ? PC_plus_two : Rs;
	
	assign b = JumpD ? {{5{D[10]}}, D} : immExt;

	cla_16b PC_adder(
		.sum(jumpTarget),
		.c_out(),					// not used
		.a(a),
		.b(b),
		.c_in(1'b0)					// no carry in
	);
	
	assign err_PC_potential_Ofl = (a[15] ^ b[15]) ? 1'b0 : (a[15] ^ jumpTarget[15]);
	
	assign err = ((JumpI | JumpD) & err_PC_potential_Ofl);
	
endmodule
