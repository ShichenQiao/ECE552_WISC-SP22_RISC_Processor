/*
	CS/ECE 552 Spring '20

	Filename        : decode.v
	Description     : This is the module for the overall decode stage of the processor.
*/
module decode (
	// Outputs
	err, read1Data, read2Data, immExt, funct,
	// Inputs
	clk, rst, Instruction, WBdata
);
	// TODO: Your code here
	input clk;				// system clock
	input rst;				// master reset, active high
	input [15:0] Instruction;
	input [15:0] WBdata;
	
	output err;
	output [15:0] read1Data, read2Data;
	output [15:0] immExt;
	output [1:0] funct;
	
	reg [2:0] Write_register;
	wire [1:0] regDst;		// 00: Instruction[10:8], 01: Instruction[7:5], 10: Instruction[4:2], 11: 3'b111
	wire RegWrite;
	wire SignImm;
	
	regFile_bypass i_RF_bypassing(
		.read1Data(read1Data),
		.read2Data(read2Data),
		.err(),
		.clk(clk),
		.rst(rst),
		.read1RegSel(Instruction[10:8]),
		.read2RegSel(Instruction[7:5]),
		.writeRegSel(Write_register),
		.writeData(WBdata),
		.writeEn(RegWrite)
	);
	
	always @(*) case(regDst)
		2'b00: Write_register = Instruction[10:8];			// Rs
		2'b01: Write_register = Instruction[7:5];			// Rt
		2'b10: Write_register = Instruction[4:2];			// Rd
		2'b11: Write_register = 3'b111;						// R7
		default: Write_register = 3'bxxx;
	endcase
	
	assign immExt = SignImm ? (imm5 ? {11{Instruction[4]}, Instruction[4:0]} : {8{Instruction[4]}, Instruction[7:0]}) :
							  (imm5 ? {11'h000, Instruction[4:0]} : {8'h00, Instruction[7:0]});
							  
	assign funct = Instruction[1:0];
	
endmodule
