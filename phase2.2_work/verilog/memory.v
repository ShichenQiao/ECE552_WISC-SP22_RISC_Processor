/*
	CS/ECE 552 Spring '22

	Filename        : memory.v
	Description     : This module contains all components in the Memory stage of the processor.
*/
module memory (
	// Outputs
	err, MemOut, DC_Stall,
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
	output DC_Stall;
	
	wire err_mem;
	wire Done, Stall, CacheHit;
	
	// byte-addressable, 16-bit wide, 64K-byte, data memory.	
	stallmem Data_Memory(
		.DataOut(MemOut),
		.Done(Done),
		.Stall(Stall),
		.CacheHit(CacheHit),
		.err(err_mem),
		.Addr(XOut),
		.DataIn(WriteData),
		.Rd(MemRead & ~XOut[0]),
		.Wr(MemWrite & ~XOut[0]),	
		.createdump(createdump),
		.clk(clk),
		.rst(rst)
	);
	
	assign DC_Stall = Done ? 1'b0 : Stall;
	
	// catch any input error
	assign err = (MemWrite === 1'bz) | (MemWrite === 1'bx) |
				 (MemRead === 1'bz) | (MemRead === 1'bx) |
				 (createdump === 1'bz) | (createdump === 1'bx) |
				 (^WriteData === 1'bz) | (^WriteData === 1'bx) |
				 (^XOut === 1'bz) | (^XOut === 1'bx) |
				 (XOut[0] & (MemRead | MemWrite)) |
				 err_mem;

endmodule
