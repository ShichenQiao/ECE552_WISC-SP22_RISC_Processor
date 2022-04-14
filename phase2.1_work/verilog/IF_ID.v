/*
	CS/ECE 552 Spring '22

	Filename        : IF_ID.v
	Description     : IF_ID pipeline register
*/
module IF_ID (
	// Outputs
	Instruction_out, PC_plus_two_out, err_out,
	// Inputs
	clk, rst, Instruction_in, PC_plus_two_in, stall, flush, err_in
	);

	input clk;
	input rst;
	input [15:0] Instruction_in;
	input [15:0] PC_plus_two_in;
	input stall;
	input flush;
	input err_in;

	output [15:0] Instruction_out;
	output [15:0] PC_plus_two_out;
	output err_out;
	
	wire [15:0] Instruction_d, PC_plus_two_d;
	
	dff instruction[15:0](
		.q(Instruction_out),
		.d(Instruction_d),
		.clk(clk),
		.rst(1'b0)
	);
	
	// pass NOP (16'h0FFF) to pipeline on stall or reset
	assign Instruction_d = (rst | flush) ? 16'h0800 :
						   stall ? Instruction_out :
						   Instruction_in;
	
	dff pc_plus_two[15:0](
		.q(PC_plus_two_out),
		.d(PC_plus_two_d),
		.clk(clk),
		.rst(rst)
	);
	
	dff err(
		.q(err_out),
		.d(err_in),
		.clk(clk),
		.rst(rst)
	);
	
	assign PC_plus_two_d = stall ? PC_plus_two_out : PC_plus_two_in;
   
endmodule
