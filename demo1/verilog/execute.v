/*
	CS/ECE 552 Spring '20

	Filename        : execute.v
	Description     : This is the overall module for the execute stage of the processor.
*/
module execute (
	// Outputs
	err, XOut, CmpOut,
	// Inputs
	read1Data, read2Data, immExt, funct, CmpOp
);
	// TODO: Your code here
	input [15:0] read1Data, read2Data;
	input [15:0] immExt;
	input [1:0] funct;
	input ClrSrc1, ClrSrc2;
	input ALUSrc;
	input [2:0] CmpOp;		// 000: == , 001: != , 010: <= , 011: >= , 100: < , 101: carryout
	
	output err;
	output reg [15:0] XOut;
	output Zero, Neg, Ofl;
	output CmpOut;
	
	wire [15:0] InA, InB;
	wire Zero, Neg, Ofl;
	wire [15:0] ALUOut;
	
	assign InA = ClrSrc1 ? 16'h0000 : read1Data;
	assign InB = ClrSrc2 ? 16'h0000 : (ALUSrc ? immExt : read2Data);

	alu i_alu(
	   .InA(InA),
	   .InB(InB),
	   .Cin(),
	   .Oper(),
	   .invA(),
	   .invB(),
	   .sign(),
	   .Out(ALUOut),
	   .Zero(Zero),
	   .Ofl(Ofl)
	);
	
	assign Neg = ALUOut[15];
	
	flag_analyzer i_flag_analyzer(
		err(),
		CmpOut(CmpOut),
		CmpOp(CmpOp),
		Zero(Zero),
		Neg(Neg),
		Ofl(Ofl)
	);
   
	// extending ALU functionalities
	always @(*) case(specialOP)
		2'b00: XOut = ALUOut;								// normal ALU operation
		2'b01: XOut = read1Data[0:15];						// BTR
		2'b10: XOut = immExt;								// LBI
		2'b11: XOut = {read1Data[7:0], immExt[7:0]};		// SLBI
		default: err = 1'b1;
	endcase
	
endmodule
