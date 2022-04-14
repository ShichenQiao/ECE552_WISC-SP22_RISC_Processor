/*
	CS/ECE 552 Spring '22

	Filename        : memory.v
	Description     : This module contains all components in the Memory stage of the processor.
*/
module memory (
	// Outputs
	err, MemOut,
	// Inputs
	clk, rst, XOut, WriteData, MemWrite, MemRead, createdump
);
	input clk;				// system clock
	input rst;				// master reset, active high
	input [15:0] XOut;
	input [15:0] WriteData;
	input MemWrite, MemRead;
	input createdump;
	
	output err;
	output [15:0] MemOut;
	
	wire err_mem;
	
	// byte-addressable, 16-bit wide, 64K-byte, data memory.
	memory2c_align Instruction_Memory_align(
		.data_out(MemOut),
		.data_in(WriteData),
		.addr(XOut),
		.enable(MemRead | MemWrite),
		.wr(MemWrite),	
		.createdump(createdump),
		.clk(clk), 
		.rst(rst),
		.err(err_mem)
	);
	
	// catch any input error
	assign err = (MemWrite === 1'bz) | (MemWrite === 1'bx) |
				 (MemRead === 1'bz) | (MemRead === 1'bx) |
				 (createdump === 1'bz) | (createdump === 1'bx) |
				 (^WriteData === 1'bz) | (^WriteData === 1'bx) |
				 (^XOut === 1'bz) | (^XOut === 1'bx) |
				 err_mem;

endmodule
