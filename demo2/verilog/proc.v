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
	wire [15:0] Instruction_IF, Instruction_ID;
	wire [15:0] PC_plus_two_IF, PC_plus_two_ID, PC_plus_two_EX, PC_plus_two_MEM, PC_plus_two_WB;
	
	wire [15:0] read1Data_ID, read2Data_ID, read1Data_EX, read2Data_EX, read2Data_MEM;
	wire [15:0] immExt_ID, immExt_EX;
	wire halt_ID;
	wire createdump_ID, createdump_EX, createdump_MEM;
	wire [2:0] ALUOp_ID, ALUOp_EX;
	wire ALUSrc_ID, ALUSrc_EX;
	wire ClrALUSrc_ID, ClrALUSrc_EX;
	wire Cin_ID, invA_ID, invB_ID, sign_ID, Cin_EX, invA_EX, invB_EX, sign_EX;
	wire JumpI_ID, JumpI_EX;
	wire branchJumpDTaken_ID;
	wire [15:0] branchJumpDTarget_ID;
	wire MemWrite_ID, MemRead_ID, MemWrite_EX, MemRead_EX, MemWrite_MEM, MemRead_MEM;
	wire CmpSet_ID, CmpSet_EX;
	wire [1:0] CmpOp_ID, CmpOp_EX;
	wire MemtoReg_ID, MemtoReg_EX, MemtoReg_MEM, MemtoReg_WB;
	wire link_ID, link_EX, link_MEM, link_WB;
	wire [1:0] specialOP_ID, specialOP_EX;
	wire [15:0] WBdata;
	
	wire [15:0] XOut_EX, XOut_MEM, XOut_WB;
	wire [15:0] jumpITarget_EX;

	wire [15:0] MemOut_MEM, MemOut_WB;

	fetch fetch_stage(
		.err(errF),
		.Instruction(Instruction_IF),
		.PC_plus_two(PC_plus_two_IF),
		.clk(clk),
		.rst(rst),
		.halt(halt_ID),
		.branchJumpDTaken(branchJumpDTaken_ID),
		.branchJumpDTarget(branchJumpDTarget_ID),
		.JumpI(JumpI_EX),
		.jumpITarget(jumpITarget_EX)
	);
	
	IF_ID if_id(
		.Instruction_out(Instruction_ID),
		.PC_plus_two_out(PC_plus_two_ID),
		.clk(clk),
		.rst(rst),
		.Instruction_in(Instruction_IF),
		.PC_plus_two_in(PC_plus_two_IF)
	);
	
	decode decode_stage(
		.err(errD),
		.read1Data(read1Data_ID),
		.read2Data(read2Data_ID),
		.immExt(immExt_ID),
		.halt(halt_ID),
		.createdump(createdump_ID),
		.ALUOp(ALUOp_ID),
		.ALUSrc(ALUSrc_ID),
		.ClrALUSrc(ClrALUSrc_ID),
		.Cin(Cin_ID),
		.invA(invA_ID),
		.invB(invB_ID),
		.sign(sign_ID),
		.JumpI(JumpI_ID),
		.branchJumpDTaken(branchJumpDTaken_ID),
		.branchJumpDTarget(branchJumpDTarget_ID),
		.MemWrite(MemWrite_ID),
		.MemRead(MemRead_ID),
		.CmpSet(CmpSet_ID),
		.CmpOp(CmpOp_ID),
		.MemtoReg(MemtoReg_ID),
		.link(link_ID),
		.specialOP(specialOP_ID),
		.clk(clk),
		.rst(rst),
		.Instruction(Instruction_ID),
		.WBdata(WBdata),
		.PC_plus_two(PC_plus_two_ID)
	);
	
	ID_EX id_ex(
		.read1Data_out(read1Data_EX),
		.read2Data_out(read2Data_EX),
		.immExt_out(immExt_EX),
		.createdump_out(createdump_EX),
		.ALUOp_out(ALUOp_EX),
		.ALUSrc_out(ALUSrc_EX),
		.ClrALUSrc_out(ClrALUSrc_EX),
		.Cin_out(Cin_EX),
		.invA_out(invA_EX),
		.invB_out(invB_EX),
		.sign_out(sign_EX),
		.JumpI_out(JumpI_EX),
		.PC_plus_two_out(PC_plus_two_EX),
		.MemWrite_out(MemWrite_EX),
		.MemRead_out(MemRead_EX),
		.CmpSet_out(CmpSet_EX),
		.CmpOp_out(CmpOp_EX),
		.MemtoReg_out(MemtoReg_EX),
		.link_out(link_EX),
		.specialOP_out(specialOP_EX),
		.clk(clk),
		.rst(rst),
		.read1Data_in(read1Data_ID),
		.read2Data_in(read2Data_ID),
		.immExt_in(immExt_ID),
		.createdump_in(createdump_ID),
		.ALUOp_in(ALUOp_ID),
		.ALUSrc_in(ALUSrc_ID),
		.ClrALUSrc_in(ClrALUSrc_ID),
		.Cin_in(Cin_ID),
		.invA_in(invA_ID),
		.invB_in(invB_ID),
		.sign_in(sign_ID),
		.JumpI_in(JumpI_ID),
		.PC_plus_two_in(PC_plus_two_ID),
		.MemWrite_in(MemWrite_ID),
		.MemRead_in(MemRead_ID),
		.CmpSet_in(CmpSet_ID),
		.CmpOp_in(CmpOp_ID),
		.MemtoReg_in(MemtoReg_ID),
		.link_in(link_ID),
		.specialOP_in(specialOP_ID)
	);
	
	execute execute_stage(
		.err(errX),
		.XOut(XOut_EX),
		.jumpITarget(jumpITarget_EX),
		.read1Data(read1Data_EX),
		.read2Data(read2Data_EX),
		.immExt(immExt_EX),
		.ALUOp(ALUOp_EX),
		.ALUSrc(ALUSrc_EX),
		.ClrALUSrc(ClrALUSrc_EX),
		.Cin(Cin_EX),
		.invA(invA_EX),
		.invB(invB_EX),
		.sign(sign_EX),
		.CmpOp(CmpOp_EX),
		.specialOP(specialOP_EX),
		.CmpSet(CmpSet_EX),
		.JumpI(JumpI_EX)
	);
	
	EX_MEM ex_mem(
		.XOut_out(XOut_MEM),
		.read2Data_out(read2Data_MEM),
		.MemWrite_out(MemWrite_MEM),
		.MemRead_out(MemRead_MEM),
		.createdump_out(createdump_MEM),
		.link_out(link_MEM),
		.PC_plus_two_out(PC_plus_two_MEM),
		.MemtoReg_out(MemtoReg_MEM),
		.clk(clk),
		.rst(rst),
		.XOut_in(XOut_EX),
		.read2Data_in(read2Data_EX),
		.MemWrite_in(MemWrite_EX),
		.MemRead_in(MemRead_EX),
		.createdump_in(createdump_EX),
		.link_in(link_EX),
		.PC_plus_two_in(PC_plus_two_EX),
		.MemtoReg_in(MemtoReg_EX)
	);
	
	memory memory_stage(
		.err(errM),
		.MemOut(MemOut_MEM),
		.clk(clk),
		.rst(rst),
		.XOut(XOut_MEM),
		.WriteData(read2Data_MEM),
		.MemWrite(MemWrite_MEM),
		.MemRead(MemRead_MEM),
		.createdump(createdump_MEM)
	);
	
	MEM_WB mem_wb(
		.MemOut_out(MemOut_WB),
		.XOut_out(XOut_WB),
		.link_out(link_WB),
		.PC_plus_two_out(PC_plus_two_WB),
		.MemtoReg_out(MemtoReg_WB),
		.clk(clk),
		.rst(rst),
		.MemOut_in(MemOut_MEM),
		.XOut_in(XOut_MEM),
		.link_in(link_MEM),
		.PC_plus_two_in(PC_plus_two_MEM),
		.MemtoReg_in(MemtoReg_MEM)
	);
	
	wb write_back_stage(
		.err(errW),
		.WBdata(WBdata),
		.link(link_WB),
		.PC_plus_two(PC_plus_two_WB),
		.MemtoReg(MemtoReg_WB),
		.MemOut(MemOut_WB),
		.XOut(XOut_WB)
	);
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0: