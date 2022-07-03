/*
	CS/ECE 552 Spring '22

	Filename        : fetch.v
	Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (
	// Outputs
	err, Instruction, PC_plus_two, IC_Stall,
	// Inputs
	clk, rst, halt, createdump, branchJumpDTaken, branchJumpDTarget, JumpI, jumpITarget, stall
);
	input clk;				// system clock
	input rst;				// master reset, active high
	input halt;				// when asserted, halt PC
	input createdump;
	input branchJumpDTaken;
	input [15:0] branchJumpDTarget;
	input JumpI;
	input [15:0] jumpITarget;
	input stall;

	output err;
	output [15:0] Instruction;
	output [15:0] PC_plus_two;
	output IC_Stall;
	
	wire [15:0] PC, nxt_PC;
	wire err_PC, err_mem;
	wire Done, Stall, CacheHit;
	
	wire CRI_out;
	wire ending;
	
	wire [15:0] instruction_critical, CRI_inst;
	
	assign nxt_PC = branchJumpDTaken ? branchJumpDTarget : (JumpI ? jumpITarget : PC_plus_two);
	
	// 16-bit PC	
	register Program_Counter(
		.readData(PC),
		.err(err_PC),
		.clk(clk),
		.rst(rst),
		.writeData(nxt_PC),
		.writeEn((~halt) & (~stall) & (~IC_Stall))
	);
	
	cla_16b PC_Adder(
		.sum(PC_plus_two),
		.c_out(),					// not used
		.a(PC),
		.b(16'h0002),				// half-word aligned
		.c_in(1'b0)					// no carry in
	);
	
	// byte-addressable, 16-bit wide, 64K-byte, instruction cache.
	critical_mem_system #(0) Instruction_Cache(
		.DataOut(instruction_critical),
		.Done(Done),
		.Stall(Stall),
		.CacheHit(CacheHit),
		.err(err_mem),
		.Addr(PC),
		.DataIn(16'h0000),				// not used
		.Rd(1'b1),						// always reading Instruction_Cache
		.Wr(1'b0),						// never write to Instruction_Cache in the fetch stage	
		.createdump(createdump),
		.clk(clk),
		.rst(rst),
		.CRI_out(CRI_out),
		.ending(ending)
	);
	
	//assign IC_Stall = CRI_out ? ~Done : ((ending | Done) ? 1'b0 : Stall);
	assign IC_Stall = CRI_out ? ~Done : (Done ? 1'b0 : Stall);
	
	dff critical_inst [15:0](
		.q(CRI_inst),
		.d((Done & CRI_out) ? instruction_critical : CRI_inst),
		.clk(clk),
		.rst(rst)
	);
	
	assign Instruction = ((~Done & CRI_out) | ending) ? CRI_inst : instruction_critical;
	
	assign err = err_PC | err_mem;
	
endmodule
