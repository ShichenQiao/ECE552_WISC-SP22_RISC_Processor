/*
	CS/ECE 552 Spring '22

	Filename        : ID_EX.v
	Description     : ID_EX pipeline register
*/
module ID_EX (
	// Outputs
	read1Data_out, read2Data_out, immExt_out, Write_register_out, halt_out, createdump_out,
	ALUOp_out, ALUSrc_out, ClrALUSrc_out, Cin_out, invA_out, invB_out, sign_out,
	JumpI_out, PC_plus_two_out, MemWrite_out, MemRead_out, CmpSet_out, CmpOp_out,
	MemtoReg_out, link_out, specialOP_out, RegWrite_out, err_out,
	read1RegSel_out, read2RegSel_out, OpCode_out,
	// Inputs
	clk, rst, read1Data_in, read2Data_in, immExt_in, Write_register_in, halt_in, createdump_in,
	ALUOp_in, ALUSrc_in, ClrALUSrc_in, Cin_in, invA_in, invB_in, sign_in,
	JumpI_in, PC_plus_two_in, MemWrite_in, MemRead_in, CmpSet_in, CmpOp_in, 
	MemtoReg_in, link_in, specialOP_in, RegWrite_in, nop, stall, err_in, DC_Stall,
	read1RegSel_in, read2RegSel_in, OpCode_in
	);

	input clk;
	input rst;
	input [15:0] read1Data_in, read2Data_in;
	input [15:0] immExt_in;
	input [2:0] Write_register_in;
	input halt_in, createdump_in;
	input [2:0] ALUOp_in;
	input ALUSrc_in;
	input ClrALUSrc_in;
	input Cin_in, invA_in, invB_in, sign_in;
	input JumpI_in;
	input [15:0] PC_plus_two_in;
	input MemWrite_in, MemRead_in;
	input CmpSet_in;
	input [1:0] CmpOp_in;
	input MemtoReg_in;
	input link_in;
	input [1:0] specialOP_in;
	input RegWrite_in;
	input nop;
	input stall;
	input err_in;
	input DC_Stall;
	input [2:0] read1RegSel_in;
	input [2:0] read2RegSel_in;
	input [4:0] OpCode_in;

	output [15:0] read1Data_out, read2Data_out;
	output [15:0] immExt_out;
	output [2:0] Write_register_out;
	output halt_out, createdump_out;
	output [2:0] ALUOp_out;
	output ALUSrc_out;
	output ClrALUSrc_out;
	output Cin_out, invA_out, invB_out, sign_out;
	output JumpI_out;
	output [15:0] PC_plus_two_out;
	output MemWrite_out, MemRead_out;
	output CmpSet_out;
	output [1:0] CmpOp_out;
	output MemtoReg_out;
	output link_out;
	output [1:0] specialOP_out;
	output RegWrite_out;
	output err_out;
	output [2:0] read1RegSel_out;
	output [2:0] read2RegSel_out;
	output [4:0] OpCode_out;
	
	dff read1Data[15:0](
		.q(read1Data_out),
		.d(DC_Stall ? read1Data_out : read1Data_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff read2Data[15:0](
		.q(read2Data_out),
		.d(DC_Stall ? read2Data_out : read2Data_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff immExt[15:0](
		.q(immExt_out),
		.d(DC_Stall ? immExt_out : immExt_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff writeregister[2:0](
		.q(Write_register_out),
		.d(DC_Stall ? Write_register_out : Write_register_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff halt(
		.q(halt_out),
		.d(DC_Stall ? halt_out : (halt_in & ~nop)),
		.clk(clk),
		.rst(rst)
	);
	
	dff createdump(
		.q(createdump_out),
		.d(DC_Stall ? createdump_out : (createdump_in & ~nop)),
		.clk(clk),
		.rst(rst)
	);
	
	dff aluop[2:0](
		.q(ALUOp_out),
		.d(DC_Stall ? ALUOp_out : ALUOp_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff alusrc(
		.q(ALUSrc_out),
		.d(DC_Stall ? ALUSrc_out : ALUSrc_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff clralusrc(
		.q(ClrALUSrc_out),
		.d(DC_Stall ? ClrALUSrc_out : ClrALUSrc_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff cin(
		.q(Cin_out),
		.d(DC_Stall ? Cin_out : Cin_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff inva(
		.q(invA_out),
		.d(DC_Stall ? invA_out : invA_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff invb(
		.q(invB_out),
		.d(DC_Stall ? invB_out : invB_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff sign(
		.q(sign_out),
		.d(DC_Stall ? sign_out : sign_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff jumpi(
		.q(JumpI_out),
		.d(DC_Stall ? JumpI_out : (JumpI_in & ~stall)),
		.clk(clk),
		.rst(rst)
	);
	
	dff pc_plus_two[15:0](
		.q(PC_plus_two_out),
		.d(DC_Stall ? PC_plus_two_out : PC_plus_two_in),
		.clk(clk),
		.rst(rst)
	);

	dff memwrite(
		.q(MemWrite_out),
		.d(DC_Stall ? MemWrite_out : (MemWrite_in & ~nop)),
		.clk(clk),
		.rst(rst)
	);
	
	dff memread(
		.q(MemRead_out),
		.d(DC_Stall ? MemRead_out : (MemRead_in & ~nop)),
		.clk(clk),
		.rst(rst)
	);
	
	dff cmpset(
		.q(CmpSet_out),
		.d(DC_Stall ? CmpSet_out : CmpSet_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff cmpop[1:0](
		.q(CmpOp_out),
		.d(DC_Stall ? CmpOp_out : CmpOp_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff memtoreg(
		.q(MemtoReg_out),
		.d(DC_Stall ? MemtoReg_out : MemtoReg_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff link(
		.q(link_out),
		.d(DC_Stall ? link_out : link_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff specialop[1:0](
		.q(specialOP_out),
		.d(DC_Stall ? specialOP_out : specialOP_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff regwrite(
		.q(RegWrite_out),
		.d(DC_Stall ? RegWrite_out : (RegWrite_in & ~nop)),
		.clk(clk),
		.rst(rst)
	);
	
	dff err(
		.q(err_out),
		.d(DC_Stall ? err_out : err_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff read1RegSel[2:0](
		.q(read1RegSel_out),
		.d(DC_Stall ? read1RegSel_out : read1RegSel_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff read2RegSel[2:0](
		.q(read2RegSel_out),
		.d(DC_Stall ? read2RegSel_out : read2RegSel_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff OpCode[4:0](
		.q(OpCode_out),
		.d(DC_Stall ? OpCode_out : OpCode_in),
		.clk(clk),
		.rst(rst)
	);
	
endmodule
