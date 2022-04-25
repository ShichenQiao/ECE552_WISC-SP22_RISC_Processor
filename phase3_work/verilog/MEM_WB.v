/*
	CS/ECE 552 Spring '22

	Filename        : MEM_WB.v
	Description     : MEM_WB pipeline register
*/
module MEM_WB (
	// Outputs
	MemOut_out, XOut_out, link_out, PC_plus_two_out, MemtoReg_out,
	Write_register_out, RegWrite_out, halt_out, err_out, MemRead_out,
	// Inputs
	clk, rst, MemOut_in, XOut_in, link_in, PC_plus_two_in, MemtoReg_in,
	Write_register_in, RegWrite_in, halt_in, err_in, DC_Stall, MemRead_in
	);

	input clk;
	input rst;
	input [15:0] MemOut_in;
	input [15:0] XOut_in;
	input link_in;
	input [15:0] PC_plus_two_in;
	input MemtoReg_in;
	input [2:0] Write_register_in;
	input RegWrite_in;
	input halt_in;
	input err_in;
	input DC_Stall;
	input MemRead_in;

	output [15:0] MemOut_out;
	output [15:0] XOut_out;
	output link_out;
	output [15:0] PC_plus_two_out;
	output MemtoReg_out;
	output [2:0] Write_register_out;
	output RegWrite_out;
	output halt_out;
	output err_out;
	output MemRead_out;

	dff memout[15:0](
		.q(MemOut_out),
		.d(DC_Stall ? MemOut_out : MemOut_in),
		.clk(clk),
		.rst(rst)
	);

	dff xout[15:0](
		.q(XOut_out),
		.d(DC_Stall ? XOut_out : XOut_in),
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
	
	dff halt(
		.q(halt_out),
		.d(DC_Stall ? halt_out : halt_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff err(
		.q(err_out),
		.d(DC_Stall ? err_out : err_in),
		.clk(clk),
		.rst(rst)
	);
	
	dff MemRead(
		.q(MemRead_out),
		.d(DC_Stall ? MemRead_out : MemRead_in),
		.clk(clk),
		.rst(rst)
	);
   
endmodule
