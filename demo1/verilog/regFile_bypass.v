/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
                       // Outputs
                       read1Data, read2Data, err,
                       // Inputs
                       clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                       );
	
	parameter REGWIDTH = 16;
	
	input        clk, rst;
	input [2:0]  read1RegSel;
	input [2:0]  read2RegSel;
	input [2:0]  writeRegSel;
	input [REGWIDTH-1:0] writeData;
	input        writeEn;

	output [REGWIDTH-1:0] read1Data;
	output [REGWIDTH-1:0] read2Data;
	output        err;

	/* YOUR CODE HERE */
	wire RD1_bypass, RD2_bypass;
	wire [REGWIDTH-1:0] read1Data_raw, read2Data_raw;
	
	regFile #(.REGWIDTH(REGWIDTH)) iRF(
		.read1Data(read1Data_raw),
		.read2Data(read2Data_raw),
		.err(err),
		.clk(clk),
		.rst(rst),
		.read1RegSel(read1RegSel),
		.read2RegSel(read2RegSel),
		.writeRegSel(writeRegSel),
		.writeData(writeData),
		.writeEn(writeEn)
	);
	
	// bypass if any read register is the same as the write register
	assign RD1_bypass = ~(|(read1RegSel ^ writeRegSel));
	assign RD2_bypass = ~(|(read2RegSel ^ writeRegSel));
	
	// put bypass data on read outputs if by pass is needed, RF write enabled, and not reseting
	assign read1Data = (RD1_bypass & writeEn & ~rst) ? writeData : read1Data_raw;
	assign read2Data = (RD2_bypass & writeEn & ~rst) ? writeData : read2Data_raw;

endmodule
