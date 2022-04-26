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

	wire errF, errD, errX, errM, errW;
	wire err_ID, err_EX, err_MEM, err_WB;

	// As desribed in the homeworks, use the err signal to trap corner
	// cases that you think are illegal in your statemachines
   	assign err = err_WB | errW;

	/* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
	wire [15:0] Instruction_IF, Instruction_ID;
	wire [15:0] PC_plus_two_IF, PC_plus_two_ID, PC_plus_two_EX, PC_plus_two_MEM, PC_plus_two_WB;
	
	wire [15:0] read1Data_ID, read2Data_ID, read1Data_EX, read2Data_EX, read2Data_MEM;
	wire [15:0] immExt_ID, immExt_EX;
	wire [2:0] Write_register_ID, Write_register_EX, Write_register_MEM, Write_register_WB;
	wire halt_ID, halt_EX, halt_MEM, halt_WB;
	wire createdump_ID, createdump_EX, createdump_MEM;
	wire [2:0] ALUOp_ID, ALUOp_EX;
	wire ALUSrc_ID, ALUSrc_EX;
	wire ClrALUSrc_ID, ClrALUSrc_EX;
	wire Cin_ID, invA_ID, invB_ID, sign_ID, Cin_EX, invA_EX, invB_EX, sign_EX;
	wire JumpI_ID, JumpI_EX;
	wire branchJumpDTaken_ID;
	wire [15:0] branchJumpDTarget_ID;
	wire MemWrite_ID, MemRead_ID, MemWrite_EX, MemRead_EX, MemWrite_MEM, MemRead_MEM, MemRead_WB;
	wire CmpSet_ID, CmpSet_EX;
	wire [1:0] CmpOp_ID, CmpOp_EX;
	wire MemtoReg_ID, MemtoReg_EX, MemtoReg_MEM, MemtoReg_WB;
	wire link_ID, link_EX, link_MEM, link_WB;
	wire [1:0] specialOP_ID, specialOP_EX;
	wire RegWrite_ID, RegWrite_EX, RegWrite_MEM, RegWrite_WB;
	
	wire [15:0] XOut_EX, XOut_MEM, XOut_WB;
	wire [15:0] jumpITarget_EX;

	wire [15:0] MemOut_MEM, MemOut_WB;
	
	wire [15:0] WBdata;
	
	wire stall;		// stall signal from hdu

	// Cache stalls
	wire IC_Stall;
	wire DC_Stall;
	
	// forwardings
	wire line1_EXEX;
	wire line2_EXEX;
	wire line1_MEMEX;
	wire line2_MEMEX;
	wire [4:0] OpCode_EX;
	wire [2:0] read1RegSel_EX, read2RegSel_EX;
	
	// extra credit
	wire siic, rti;
	wire [15:0] EPC_out;
	//wire MEMMEM_fwd;		// MEM to MEM forwarding increase CPI becasue of issue with ICOUNT, so excluded for Phase 3
	wire [2:0] read1RegSel_MEM, read2RegSel_MEM;
	wire XD_fwd;

	fetch fetch_stage(
		.err(errF),
		.Instruction(Instruction_IF),
		.PC_plus_two(PC_plus_two_IF),
		.IC_Stall(IC_Stall),
		.clk(clk),
		.rst(rst),
		.halt(halt_ID & ~branchJumpDTaken_ID & ~JumpI_EX),
		.branchJumpDTaken(branchJumpDTaken_ID),
		.branchJumpDTarget(siic ? 16'h0002 : (rti ? EPC_out : branchJumpDTarget_ID)),
		.JumpI(JumpI_EX),
		.jumpITarget(jumpITarget_EX),
		.stall((stall & ~JumpI_EX) | DC_Stall)
	);
	
	IF_ID if_id(
		.Instruction_out(Instruction_ID),
		.PC_plus_two_out(PC_plus_two_ID),
		.err_out(err_ID),
		.clk(clk),
		.rst(rst),
		.Instruction_in(Instruction_IF),
		.PC_plus_two_in(PC_plus_two_IF),
		.stall(stall | DC_Stall | ((branchJumpDTaken_ID | JumpI_EX) & IC_Stall)),
		.flush(((branchJumpDTaken_ID ^ IC_Stall) & ~stall & ~DC_Stall) | (JumpI_EX & ~(stall & JumpI_ID))),
		.err_in(errF)
	);
	
	decode decode_stage(
		.err(errD),
		.read1Data(read1Data_ID),
		.read2Data(read2Data_ID),
		.immExt(immExt_ID),
		.Write_register(Write_register_ID),
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
		.RegWrite(RegWrite_ID),
		.siic(siic),
		.rti(rti),
		.clk(clk),
		.rst(rst),
		.Instruction(Instruction_ID),
		.WBdata(WBdata),
		.WBreg(Write_register_WB),
		.WBregwrite(RegWrite_WB & ~err_WB & ~DC_Stall & ~(IC_Stall & JumpI_EX & (line1_EXEX | line1_MEMEX))),
		.PC_plus_two(PC_plus_two_ID),
		.XD_fwd(XD_fwd),
		.XOut_MEM(XOut_MEM)
	);
	
	hazard_detection hdu(
		.stall(stall),
		.XD_fwd(XD_fwd), 
		.OpCode_ID(Instruction_ID[15:11]),
		.Rs_ID(Instruction_ID[10:8]),
		.Rt_ID(Instruction_ID[7:5]),
		.Write_register_EX(Write_register_EX),
		.RegWrite_EX(RegWrite_EX),
		.Write_register_MEM(Write_register_MEM),
		.RegWrite_MEM(RegWrite_MEM),
		.branchJumpDTaken_ID(branchJumpDTaken_ID),
		.FWD(line1_EXEX | line2_EXEX | line1_MEMEX | line2_MEMEX),
		.MemRead_EX(MemRead_EX),
		.MemRead_MEM(MemRead_MEM),
		.MemWrite_EX(MemWrite_EX),
		.read2RegSel_EX(read2RegSel_EX),
		.MemWrite_ID(MemWrite_ID),
		.RegWrite_WB(RegWrite_WB), 
		.Write_register_WB(Write_register_WB)
	);
	
	ID_EX id_ex(
		.read1Data_out(read1Data_EX),
		.read2Data_out(read2Data_EX),
		.immExt_out(immExt_EX),
		.Write_register_out(Write_register_EX),
		.halt_out(halt_EX),
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
		.RegWrite_out(RegWrite_EX),
		.err_out(err_EX),
		.OpCode_out(OpCode_EX),
		.read1RegSel_out(read1RegSel_EX),
		.read2RegSel_out(read2RegSel_EX),
		.clk(clk),
		.rst(rst),
		.read1Data_in(read1Data_ID),
		.read2Data_in(read2Data_ID),
		.immExt_in(immExt_ID),
		.Write_register_in(Write_register_ID),
		.halt_in(halt_ID),
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
		.specialOP_in(specialOP_ID),
		.RegWrite_in(RegWrite_ID),
		.stall(stall),
		.nop(stall | (JumpI_EX & ~IC_Stall) | (branchJumpDTaken_ID & IC_Stall)),
		.err_in(err_ID | errD),
		.DC_Stall(DC_Stall | (JumpI_EX & IC_Stall)),
		.OpCode_in(Instruction_ID[15:11]),
		.read1RegSel_in(Instruction_ID[10:8]),
		.read2RegSel_in(Instruction_ID[7:5])
	);
	
	execute execute_stage(
		.err(errX),
		.XOut(XOut_EX),
		.jumpITarget(jumpITarget_EX),
		.read1Data(line1_EXEX ? XOut_MEM : (line1_MEMEX ? WBdata : read1Data_EX)),
		.read2Data(line2_EXEX ? XOut_MEM : (line2_MEMEX ? WBdata : read2Data_EX)),
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
		.halt_out(halt_MEM),
		.createdump_out(createdump_MEM),
		.link_out(link_MEM),
		.PC_plus_two_out(PC_plus_two_MEM),
		.MemtoReg_out(MemtoReg_MEM),
		.Write_register_out(Write_register_MEM),
		.RegWrite_out(RegWrite_MEM),
		.read1RegSel_out(read1RegSel_MEM),
		.read2RegSel_out(read2RegSel_MEM),
		.err_out(err_MEM),
		.clk(clk),
		.rst(rst),
		.XOut_in(XOut_EX),
		.read2Data_in(line2_EXEX ? XOut_MEM : (line2_MEMEX ? WBdata : read2Data_EX)),
		.MemWrite_in(MemWrite_EX),
		.MemRead_in(MemRead_EX),
		.halt_in(halt_EX),
		.createdump_in(createdump_EX),
		.link_in(link_EX),
		.PC_plus_two_in(PC_plus_two_EX),
		.MemtoReg_in(MemtoReg_EX),
		.Write_register_in(Write_register_EX),
		.RegWrite_in(RegWrite_EX & ~(JumpI_EX & IC_Stall)),
		.err_in(err_EX | errX),
		.DC_Stall(DC_Stall | (IC_Stall & JumpI_EX & (line1_EXEX | line1_MEMEX))),
		.read1RegSel_in(read1RegSel_EX),
		.read2RegSel_in(read2RegSel_EX)
	);
	
	memory memory_stage(
		.err(errM),
		.MemOut(MemOut_MEM),
		.DC_Stall(DC_Stall),
		.clk(clk),
		.rst(rst),
		.XOut(XOut_MEM),
		.WriteData(read2Data_MEM),
		//.WriteData(MEMMEM_fwd ? MemOut_WB : read2Data_MEM), 		// MEM to MEM forwarding increase CPI becasue of issue with ICOUNT, so excluded for Phase 3
		.MemWrite(MemWrite_MEM & ~halt_WB),
		.MemRead(MemRead_MEM),
		.createdump(createdump_MEM)
	);
	
	MEM_WB mem_wb(
		.MemOut_out(MemOut_WB),
		.XOut_out(XOut_WB),
		.link_out(link_WB),
		.PC_plus_two_out(PC_plus_two_WB),
		.MemtoReg_out(MemtoReg_WB),
		.Write_register_out(Write_register_WB),
		.RegWrite_out(RegWrite_WB),
		.halt_out(halt_WB),
		.err_out(err_WB),
		.MemRead_out(MemRead_WB),
		.clk(clk),
		.rst(rst),
		.MemOut_in(MemOut_MEM),
		.XOut_in(XOut_MEM),
		.link_in(link_MEM),
		.PC_plus_two_in(PC_plus_two_MEM),
		.MemtoReg_in(MemtoReg_MEM),
		.Write_register_in(Write_register_MEM),
		.RegWrite_in(RegWrite_MEM),
		.halt_in(halt_MEM),
		.err_in(err_MEM | errM),
		.DC_Stall(DC_Stall | (IC_Stall & JumpI_EX & (line1_EXEX | line1_MEMEX))),
		.MemRead_in(MemRead_MEM)
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
	
	forwarding fwd(
		.line1_EXEX(line1_EXEX),
		.line2_EXEX(line2_EXEX),
		.line1_MEMEX(line1_MEMEX),
		.line2_MEMEX(line2_MEMEX),
		//.MEMMEM_fwd(MEMMEM_fwd),		// MEM to MEM forwarding increase CPI becasue of issue with ICOUNT, so excluded for Phase 3
		.OpCode_EX(OpCode_EX),
		.read1RegSel_EX(read1RegSel_EX),
		.read2RegSel_EX(read2RegSel_EX),
		.RegWrite_MEM(RegWrite_MEM),
		.Write_register_MEM(Write_register_MEM),
		.MemRead_MEM(MemRead_MEM),
		.RegWrite_WB(RegWrite_WB),
		.Write_register_WB(Write_register_WB),
		.MemRead_WB(MemRead_WB),
		.MemWrite_MEM(MemWrite_MEM),
		.read1RegSel_MEM(read1RegSel_MEM),
		.read2RegSel_MEM(read2RegSel_MEM)
	);
	
	// extra credit
	register EPC(
		.readData(EPC_out),
		.err(),
		.clk(clk),
		.rst(rst),
		.writeData(PC_plus_two_ID),
		.writeEn(siic & (~DC_Stall))
	);
	
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0: