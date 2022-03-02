/*
	CS/ECE 552 Spring '20

	Filename        : execute.v
	Description     : This is the overall module for the execute stage of the processor.
*/
module execute (
	// Outputs
	err, XOut,
	// Inputs
	read1Data, read2Data, immExt,
	ALUOp, ALUSrc, ClrALUSrc, Cin, invA, invB, CmpOp, specialOP, CmpSet
);
	// TODO: Your code here
	input [15:0] read1Data, read2Data;
	input [15:0] immExt;
	input [2:0] ALUOp;
	input ALUSrc;
	input ClrALUSrc;
	input Cin, invA, invB;			// other ALU controls
	input [1:0] CmpOp;				// 00: == , 01: < , 10: <= , 11: carryout
	input [1:0] specialOP;			// 00: none, 01: BTR, 10 LBI, 11 SLBI
	input CmpSet;
	
	output reg err;
	output reg [15:0] XOut;
	
	wire [15:0] InA, InB;
	wire Zero, Neg, Ofl;
	wire [15:0] ALUOut;
	reg [15:0] ALUExtOut;
	wire [15:0] read1Data_rev;
	
	assign InB = ClrALUSrc ? 16'h0000 : (ALUSrc ? immExt : read2Data);

	alu i_ALU(
	   .InA(read1Data),
	   .InB(InB),
	   .Cin(Cin),
	   .Oper(Oper),
	   .invA(invA),
	   .invB(invB),
	   .sign(1'b1),				// for this ALU, always treat as signed inputs
	   .Out(ALUOut),
	   .Zero(Zero),
	   .Ofl(Ofl)
	);
	
	assign Neg = ALUOut[15];

	flag_analyzer i_Flag_Analyzer(
		.err(),
		.CmpOut(CmpOut),
		.CmpOp(CmpOp),
		.Zero(Zero),
		.Neg(Neg),
		.Ofl(Ofl)
	);
	
	assign read1Data_rev = {read1Data[0], read1Data[1], read1Data[2], read1Data[3], 
							read1Data[4], read1Data[5], read1Data[6], read1Data[7], 
							read1Data[8], read1Data[9], read1Data[10], read1Data[11], 
							read1Data[12], read1Data[13], read1Data[14], read1Data[15]};

	// extending ALU functionalities
	always @(*) begin
		err = 1'b0;
		ALUExtOut = 16'h0000;
		
		case(specialOP)
			2'b00: ALUExtOut = ALUOut;								// normal ALU operation
			2'b01: ALUExtOut = read1Data_rev;						// BTR
			2'b10: ALUExtOut = immExt;								// LBI
			2'b11: ALUExtOut = {read1Data[7:0], immExt[7:0]};		// SLBI
			default: err = 1'b1;
		endcase
	end
	
	// choose final output from the execute between the ALU and the flag analyzer
	assign XOut = CmpSet ? CmpOut : ALUExtOut;
	
endmodule
