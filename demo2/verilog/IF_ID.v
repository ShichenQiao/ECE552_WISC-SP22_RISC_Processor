/*
	CS/ECE 552 Spring '22

	Filename        : IF-ID.v
	Description     : IF-ID pipeline register
*/
module IF_ID (
	// Outputs
	Instruction_out, PC_plus_two_out,
	// Inputs
	clk, rst, Instruction_in, PC_plus_two_in
	);

	input clk;
	input rst;
	input [15:0] Instruction_in;
	input [15:0] PC_plus_two_in;

	output [15:0] Instruction_out;
	output [15:0] PC_plus_two_out;
	
	wire [15:0] inst_fix;
	
	dff instruction[15:0](
		.q(Instruction_out),
		.d(inst_fix),
		.clk(clk),
		.rst(1'b0)
	);
	
	assign inst_fix = rst ? 16'h0FFF : Instruction_in;
	
	dff pc_plus_two[15:0](
		.q(PC_plus_two_out),
		.d(PC_plus_two_in),
		.clk(clk),
		.rst(rst)
	);
   
endmodule
