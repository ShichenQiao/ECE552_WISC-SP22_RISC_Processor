/*
	CS/ECE 552 Spring '20

	Filename        : decode.v
	Description     : This is the module for the overall decode stage of the processor.
*/
module decode (
	// Outputs
	err,
	// Inputs
	clk, rst, Instruction, Write_data
);
	// TODO: Your code here
	input clk;				// system clock
	input rst;				// master reset, active high
	input [15:0] Instruction;
	input [15:0] Write_data;
	
	output err;
	output [15:0] read1Data, read2Data;
	
	regFile_bypass i_RF_bypassing(
		.read1Data(),
		.read2Data(),
		.err(),
		.clk(clk),
		.rst(rst),
		.read1RegSel(),
		.read2RegSel(),
		.writeRegSel(),
		.writeData(Write_data),
		.writeEn()
	);
	
   
endmodule
