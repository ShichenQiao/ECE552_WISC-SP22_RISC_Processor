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
	MemtoReg_out, link_out, specialOP_out, RegWrite_out,
	// Inputs
	clk, rst, read1Data_in, read2Data_in, immExt_in, Write_register_in, halt_in, createdump_in,
	ALUOp_in, ALUSrc_in, ClrALUSrc_in, Cin_in, invA_in, invB_in, sign_in,
	JumpI_in, PC_plus_two_in, MemWrite_in, MemRead_in, CmpSet_in, CmpOp_in, 
	MemtoReg_in, link_in, specialOP_in, RegWrite_in, stall
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
	input stall;

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
	
	dff read1Data[15:0](
		.q(read1Data_out),
		.d(read1Data_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff read2Data[15:0](
		.q(read2Data_out),
		.d(read2Data_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff immExt[15:0](
		.q(immExt_out),
		.d(immExt_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff writeregister[2:0](
		.q(Write_register_out),
		.d(Write_register_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff halt(
		.q(halt_out),
		.d(halt_in & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff createdump(
		.q(createdump_out),
		.d(createdump_in & ~stall & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff aluop[2:0](
		.q(ALUOp_out),
		.d(ALUOp_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff alusrc(
		.q(ALUSrc_out),
		.d(ALUSrc_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff clralusrc(
		.q(ClrALUSrc_out),
		.d(ClrALUSrc_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff cin(
		.q(Cin_out),
		.d(Cin_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff inva(
		.q(invA_out),
		.d(invA_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff invb(
		.q(invB_out),
		.d(invB_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff sign(
		.q(sign_out),
		.d(sign_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff jumpi(
		.q(JumpI_out),
		.d(JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff pc_plus_two[15:0](
		.q(PC_plus_two_out),
		.d(PC_plus_two_in),
		.clk(clk),
		.rst(rst)
	);

	dff memwrite(
		.q(MemWrite_out),
		.d(MemWrite_in & ~stall & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff memread(
		.q(MemRead_out),
		.d(MemRead_in & ~stall & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff cmpset(
		.q(CmpSet_out),
		.d(CmpSet_in & ~stall & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff cmpop[1:0](
		.q(CmpOp_out),
		.d(CmpOp_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff memtoreg(
		.q(MemtoReg_out),
		.d(MemtoReg_in & ~stall & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff link(
		.q(link_out),
		.d(link_in & ~stall & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff specialop[1:0](
		.q(specialOP_out),
		.d(specialOP_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff regwrite(
		.q(RegWrite_out),
		.d(RegWrite_in & ~stall & ~JumpI_in),
		.clk(clk),
		.rst(rst)
	);
   
endmodule
