/*
	CS/ECE 552 Spring '22

	Filename        : MEM_WB.v
	Description     : MEM_WB pipeline register
*/
module MEM_WB (
	// Outputs
	MemOut_out, XOut_out, link_out, PC_plus_two_out, MemtoReg_out,
	// Inputs
	clk, rst, MemOut_in, XOut_in, link_in, PC_plus_two_in, MemtoReg_in
	);

	input clk;
	input rst;
	input [15:0] MemOut_in;
	input [15:0] XOut_in;
	input link_in;
	input [15:0] PC_plus_two_in;
	input MemtoReg_in;

	output [15:0] MemOut_out;
	output [15:0] XOut_out;
	output link_out;
	output [15:0] PC_plus_two_out;
	output MemtoReg_out;

	dff memout[15:0](
		.q(MemOut_out),
		.d(MemOut_in),
		.clk(clk),
		.rst(rst)
	);

	dff xout[15:0](
		.q(XOut_out),
		.d(XOut_in),
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
   
endmodule
