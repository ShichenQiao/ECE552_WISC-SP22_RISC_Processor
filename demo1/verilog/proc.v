/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

	// OR all the err ouputs for every sub-module and assign it as this
	// err output
	wire errF, errD, errX, errM, errW;
	assign err = errF | errD | errX | errM | errW;

	// As desribed in the homeworks, use the err signal to trap corner
	// cases that you think are illegal in your statemachines
   
	/* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
	wire [15:0] Instruction;
	wire [15:0] PC_plus_two;
	wire halt;
	wire branchJumpDTaken;
	wire [15:0] branchJumpDTarget;
	wire JumpI;
	wire [15:0] jumpITarget;
	
	wire [15:0] read1Data, read2Data;
	wire [15:0] immExt;
	wire createdump;
	wire [2:0] ALUOp;
	wire ALUSrc;
	wire ClrALUSrc;
	wire Cin, invA, invB, sign;
	wire MemWrite, MemRead;
	wire CmpSet;
	wire [1:0] CmpOp;
	wire MemtoReg;
	wire link;
	wire [1:0] specialOP;
	wire [15:0] WBdata;
	
	wire [15:0] XOut;

	wire [15:0] MemOut;

	
	fetch fetch_stage(
		.err(errF),
		.Instruction(Instruction),
		.PC_plus_two(PC_plus_two),
		.clk(clk),
		.rst(rst),
		.halt(halt),
		.branchJumpDTaken(branchJumpDTaken),
		.branchJumpDTarget(branchJumpDTarget),
		.JumpI(JumpI),
		.jumpITarget(jumpITarget)
	);
	
	decode decode_stage(
		.err(errD),
		.read1Data(read1Data),
		.read2Data(read2Data),
		.immExt(immExt),
		.halt(halt),
		.createdump(createdump),
		.ALUOp(ALUOp),
		.ALUSrc(ALUSrc),
		.ClrALUSrc(ClrALUSrc),
		.Cin(Cin),
		.invA(invA),
		.invB(invB),
		.sign(sign),
		.JumpI(JumpI),
		.branchJumpDTaken(branchJumpDTaken),
		.branchJumpDTarget(branchJumpDTarget),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.CmpSet(CmpSet),
		.CmpOp(CmpOp),
		.MemtoReg(MemtoReg),
		.link(link),
		.specialOP(specialOP),
		.clk(clk),
		.rst(rst),
		.Instruction(Instruction),
		.WBdata(WBdata),
		.PC_plus_two(PC_plus_two)
	);
	
	execute execute_stage(
		.err(errX),
		.XOut(XOut),
		.jumpITarget(jumpITarget),
		.read1Data(read1Data),
		.read2Data(read2Data),
		.immExt(immExt),
		.ALUOp(ALUOp),
		.ALUSrc(ALUSrc),
		.ClrALUSrc(ClrALUSrc),
		.Cin(Cin),
		.invA(invA),
		.invB(invB),
		.sign(sign),
		.CmpOp(CmpOp),
		.specialOP(specialOP),
		.CmpSet(CmpSet),
		.JumpI(JumpI)
	);
	
	memory memory_stage(
		.err(errM),
		.MemOut(MemOut),
		.clk(clk),
		.rst(rst),
		.XOut(XOut),
		.WriteData(read2Data),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.createdump(createdump)
	);
	
	wb write_back_stage(
		.err(errW),
		.WBdata(WBdata),
		.link(link),
		.PC_plus_two(PC_plus_two),
		.MemtoReg(MemtoReg),
		.MemOut(MemOut),
		.XOut(XOut)
	);
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
