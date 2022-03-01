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
	
	// catch any input error
	assign err = (link === 1'bz) | (link === 1'bx) |
				 (MemtoReg === 1'bz) | (MemtoReg === 1'bx) |
				 (CmpSet === 1'bz) | (CmpSet === 1'bx) |
				 (CmpOut === 1'bz) | (CmpOut === 1'bx) |
				 (^PC_plus_two === 1'bz) | (^PC_plus_two === 1'bx) |
				 (^MemOut === 1'bz) | (^MemOut === 1'bx);
endmodule
