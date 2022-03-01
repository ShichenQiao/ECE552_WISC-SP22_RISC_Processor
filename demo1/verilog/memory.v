/*
	CS/ECE 552 Spring '20

	Filename        : memory.v
	Description     : This module contains all components in the Memory stage of the 
					 processor.
*/
module memory (
	// Outputs
	err, MemOut,
	// Inputs
	clk, rst, XOut, WriteData, MemWrite, MemRead, link
);
	// TODO: Your code here
	input clk;				// system clock
	input rst;				// master reset, active high
	input [15:0] XOut;
	input [15:0] WriteData;
	input MemWrite, MemRead;
	input link;
	
	output err;
	output [15:0] MemOut;
	
	// byte-addressable, 16-bit wide, 64K-byte, data memory.
	memory2c Instruction_Memory(
		.data_out(MemOut),
		.data_in(WriteData),
		.addr(XOut),
		.enable(MemRead),
		.wr(MemWrite),	
		.createdump(),
		.clk(clk), 
		.rst(rst)
	);

   
endmodule
