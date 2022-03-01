/*
	CS/ECE 552 Spring '20

	Filename        : wb.v
	Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (
	// Outputs
	err, WBdata,
	// Inputs
	link, PC_plus_two, MemtoReg, MemOut, CmpSet, CmpOut, XOut
);
	// TODO: Your code here
	input link;
	input [15:0] PC_plus_two;
	input MemtoReg;
	input [15:0] MemOut;
	input CmpSet;
	input CmpOut;
	input [15:0] XOut;
	
	output err;
	output [15:0] WBdata;
	
	// write back data to the register file
	assign WBdata = link ? PC_plus_two : (MemtoReg ? MemOut : (CmpSet ? {15'h0000, CmpOut} : XOut));
   
endmodule
