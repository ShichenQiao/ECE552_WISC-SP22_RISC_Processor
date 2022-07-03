/*
	CS/ECE 552 Spring '22

	Filename        : memory.v
	Description     : This module contains all components in the Memory stage of the processor.
*/
module memory (
	// Outputs
	err, MemOut, DC_Stall, WB_critical, ending, CRI_data,
	// Inputs
	clk, rst, XOut, WriteData, MemWrite, MemRead, createdump, new_Access
);
	input clk;				// system clock
	input rst;				// master reset, active high
	input [15:0] XOut;
	input [15:0] WriteData;
	input MemWrite, MemRead;
	input createdump;
	input new_Access;
	
	output err;
	output [15:0] MemOut;
	output DC_Stall;
	output WB_critical;
	output ending;
	output [15:0] CRI_data;
	
	wire err_mem;
	wire Done, Stall, CacheHit;
	
	wire CRI_out;
	wire [15:0] MemOut_critical;
	
	// byte-addressable, 16-bit wide, 64K-byte, data memory.	
	critical_mem_system #(1) Data_Cache(
		.DataOut(MemOut_critical),
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
		.rst(rst),
		.CRI_out(CRI_out),
		.ending(ending)
	);

	assign DC_Stall = CRI_out ? new_Access : ((ending | Done) ? 1'b0 : Stall);
	
	assign WB_critical = Done & CRI_out;
	
	dff critical_data [15:0](
		.q(CRI_data),
		.d(WB_critical ? MemOut_critical : CRI_data),
		.clk(clk),
		.rst(rst)
	);
	
	assign MemOut = MemOut_critical;
	
	// catch any input error
	assign err = (MemWrite === 1'bz) | (MemWrite === 1'bx) |
				 (MemRead === 1'bz) | (MemRead === 1'bx) |
				 (createdump === 1'bz) | (createdump === 1'bx) |
				 (^WriteData === 1'bz) | (^WriteData === 1'bx) |
				 (^XOut === 1'bz) | (^XOut === 1'bx) |
				 (XOut[0] & (MemRead | MemWrite)) |
				 err_mem;

endmodule
