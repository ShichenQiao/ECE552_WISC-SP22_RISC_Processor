/*
	CS/ECE 552 Spring '20

	Filename        : fetch.v
	Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (
	// Outputs
	err, Instruction, PC_plus_two,
	// Inputs
	clk, rst, halt, nxt_PC, createdump
);
	// TODO: Your code here
	input clk;				// system clock
	input rst;				// master reset, active high
	input halt;				// when asserted, halt PC
	input nxt_PC;			// the potential value of next PC
	input createdump;

	output err;
	output [15:0] Instruction;
	output [15:0] PC_plus_two;
	
	wire [15:0]PC;
	
	// 16-bit PC
	program_counter Program_Counter(
		err(),
		PC(PC),
		clk(clk),
		rst(rst),
		halt(halt),
		nxt_PC(nxt_PC)
	);
	
	// byte-addressable, 16-bit wide, 64K-byte, instruction memory.
	memory2c Instruction_Memory(
		.data_out(Instruction),
		.data_in(),					// not used
		.addr(PC),					// read the instruction stored at the current PC
		.enable(1'b1),				// always reading Instruction_Memory
		.wr(1'b0),					// never write to Instruction_Memory in the fetch stage			
		.createdump(createdump),
		.clk(clk), 
		.rst(rst)
	);
	
	cla_16b PC_adder(
		.sum(PC_plus_two),
		.c_out(),
		.a(PC),
		.b(16'h0002),				// half-word aligned
		.c_in(1'b0)					// no carry in
	);
   
endmodule
