/*
	CS/ECE 552 Spring '22

	Filename        : jumpI.v
	Description     : This module handles JR and JARL instructions.
*/
module jumpI (
	// Outputs
	err, jumpITarget,
	// Inputs
	JumpI, immExt, Rs
);
	input JumpI;
	input [15:0] immExt;
	input [15:0] Rs;
	
	output err;
	output [15:0] jumpITarget;
	
	wire err_PC_potential_Ofl;

	// PC <- Rs + I(sign ext.)
	cla_16b PC_adder(
		.sum(jumpITarget),
		.c_out(),					// not used
		.a(Rs),
		.b(immExt),
		.c_in(1'b0)					// no carry in
	);
	
	assign err_PC_potential_Ofl = (Rs[15] ^ immExt[15]) ? 1'b0 : (Rs[15] ^ jumpITarget[15]);
	
	assign err = (JumpI & err_PC_potential_Ofl);
	
endmodule
