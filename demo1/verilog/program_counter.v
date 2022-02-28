/*
	CS/ECE 552 Spring '20

	Filename        : program_counter.v
	Description     : This is the module for the program counter of the processor.
*/
module program_counter (
	// Outputs
	err, PC
	// Inputs
	clk, rst, halt, nxt_PC
);
	// TODO: Your code here
	input clk;				// system clock
	input rst;				// master reset, active high
	input halt;				// when asserted, halt PC
	input [15:0] nxt_PC;

	output [15:0] PC;
	output err;
	
	wire [15:0] PC_in;		// actual input to the PC register
	
	// 16-bit PC register
	dff PC_register [15:0](
		.q(PC),
		.d(PC_in),
		.clk(clk),
		.rst(rst)
	);
	
	// halt PC when needed
	assign PC_in = halt ? PC : nxt_PC;
	
endmodule
