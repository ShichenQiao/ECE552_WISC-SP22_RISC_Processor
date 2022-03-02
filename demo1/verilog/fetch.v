/*
	CS/ECE 552 Spring '20

	Filename        : fetch.v
	Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (
	// Outputs
	err, Instruction, PC_plus_two,
	// Inputs
	clk, rst, halt, branchTaken, branchTarget
);
	// TODO: Your code here
	input clk;				// system clock
	input rst;				// master reset, active high
	input halt;				// when asserted, halt PC
	input branchTaken;
	input [15:0] branchTarget;

	output err;
	output [15:0] Instruction;
	output [15:0] PC_plus_two;
	
	wire [15:0] PC, nxt_PC;
	wire err_PC, err_PC_overflow;
	
	assign nxt_PC = branchTaken ? branchTarget : PC_plus_two;
	
	// 16-bit PC	
	register Program_Counter(
		.readData(PC),
		.err(err_PC),
		.clk(clk),
		.rst(rst),
		.writeData(nxt_PC),
		.writeEn(~halt)
	);
	
	cla_16b PC_Adder(
		.sum(PC_plus_two),
		.c_out(err_PC_overflow),
		.a(PC),
		.b(16'h0002),				// half-word aligned
		.c_in(1'b0)					// no carry in
	);
	
	// byte-addressable, 16-bit wide, 64K-byte, instruction memory.
	memory2c Instruction_Memory(
		.data_out(Instruction),
		.data_in(16'h0000),			// not used
		.addr(PC),					// read the instruction stored at the current PC
		.enable(1'b1),				// always reading Instruction_Memory
		.wr(1'b0),					// never write to Instruction_Memory in the fetch stage			
		.createdump(1'b0),			// never dump the Instruction_Memory
		.clk(clk), 
		.rst(rst)
	);
	
	assign err = err_PC | err_PC_overflow;
	
endmodule