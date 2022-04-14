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
	// Inputs
	clk, rst, XOut_in,
	read2Data_in, MemWrite_in, MemRead_in, halt_in, createdump_in,
	link_in, PC_plus_two_in, MemtoReg_in, Write_register_in, RegWrite_in, err_in
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
	
	dff xout[15:0](
		.q(XOut_out),
		.d(XOut_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff read2Data[15:0](
		.q(read2Data_out),
		.d(read2Data_in),
		.clk(clk),
		.rst(rst)
	);

	dff memwrite(
		.q(MemWrite_out),
		.d(MemWrite_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff memread(
		.q(MemRead_out),
		.d(MemRead_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff halt(
		.q(halt_out),
		.d(halt_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff createdump(
		.q(createdump_out),
		.d(createdump_in),
		.clk(clk),
		.rst(rst)
	);

	dff link(
		.q(link_out),
		.d(link_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff pc_plus_two[15:0](
		.q(PC_plus_two_out),
		.d(PC_plus_two_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff memtoreg(
		.q(MemtoReg_out),
		.d(MemtoReg_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff writeregister[2:0](
		.q(Write_register_out),
		.d(Write_register_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff regwrite(
		.q(RegWrite_out),
		.d(RegWrite_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff err(
		.q(err_out),
		.d(err_in),
		.clk(clk),
		.rst(rst)
	);
	
endmodule
