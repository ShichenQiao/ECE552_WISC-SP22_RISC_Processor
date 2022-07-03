/*
	CS/ECE 552 Spring '22

	Filename        : EX_MEM.v
	Description     : EX_MEM pipeline register
*/
module EX_MEM (
	// Outputs
	XOut_out,
	read2Data_out, MemWrite_out, MemRead_out, halt_out, createdump_out,
	link_out, PC_plus_two_out, MemtoReg_out, Write_register_out, RegWrite_out, err_out,
	read1RegSel_out, read2RegSel_out,
	// Inputs
	clk, rst, XOut_in,
	read2Data_in, MemWrite_in, MemRead_in, halt_in, createdump_in,
	link_in, PC_plus_two_in, MemtoReg_in, Write_register_in, RegWrite_in, err_in, DC_Stall,
	read1RegSel_in, read2RegSel_in
	);

	input clk;
	input rst;
	input [15:0] XOut_in;
	input [15:0] read2Data_in;
	input MemWrite_in, MemRead_in;
	input halt_in, createdump_in;	
	input link_in;
	input [15:0] PC_plus_two_in;
	input MemtoReg_in;
	input [2:0] Write_register_in;
	input RegWrite_in;
	input err_in;
	input DC_Stall;
	input [2:0] read1RegSel_in, read2RegSel_in;

	output [15:0] XOut_out;
	output [15:0] read2Data_out;
	output MemWrite_out, MemRead_out;
	output halt_out, createdump_out;
	output link_out;
	output [15:0] PC_plus_two_out;
	output MemtoReg_out;
	output [2:0] Write_register_out;
	output RegWrite_out;
	output err_out;
	output [2:0] read1RegSel_out, read2RegSel_out;
	
	dff xout[15:0](
		.q(XOut_out),
		.d(DC_Stall ? XOut_out : XOut_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff read2Data[15:0](
		.q(read2Data_out),
		.d(DC_Stall ? read2Data_out : read2Data_in),
		.clk(clk),
		.rst(rst)
	);

	dff memwrite(
		.q(MemWrite_out),
		.d(DC_Stall ? MemWrite_out : MemWrite_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff memread(
		.q(MemRead_out),
		.d(DC_Stall ? MemRead_out : MemRead_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff halt(
		.q(halt_out),
		.d(DC_Stall ? halt_out : halt_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff createdump(
		.q(createdump_out),
		.d(DC_Stall ? createdump_out : createdump_in),
		.clk(clk),
		.rst(rst)
	);

	dff link(
		.q(link_out),
		.d(DC_Stall ? link_out : link_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff pc_plus_two[15:0](
		.q(PC_plus_two_out),
		.d(DC_Stall ? PC_plus_two_out : PC_plus_two_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff memtoreg(
		.q(MemtoReg_out),
		.d(DC_Stall ? MemtoReg_out : MemtoReg_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff writeregister[2:0](
		.q(Write_register_out),
		.d(DC_Stall ? Write_register_out : Write_register_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff regwrite(
		.q(RegWrite_out),
		.d(DC_Stall ? RegWrite_out : RegWrite_in),
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

endmodule
