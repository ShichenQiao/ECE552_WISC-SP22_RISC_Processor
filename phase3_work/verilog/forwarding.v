/*
	CS/ECE 552 Spring '22

	Filename        : forwarding.v
	Description     : forwarding unit
*/
module forwarding (
	// Outputs
	line1_EXEX, line2_EXEX, line1_MEMEX, line2_MEMEX,
	// Inputs
	OpCode_EX, read1RegSel_EX, read2RegSel_EX,
	RegWrite_MEM, Write_register_MEM, MemRead_MEM,
	RegWrite_WB, Write_register_WB
	);
	
	input [4:0] OpCode_EX;
	input [2:0] read1RegSel_EX;
	input [2:0] read2RegSel_EX;
	input RegWrite_MEM;
	input [2:0] Write_register_MEM;
	input MemRead_MEM;
	input RegWrite_WB;
	input [2:0] Write_register_WB;
	
	output line1_EXEX, line2_EXEX, line1_MEMEX, line2_MEMEX;
	
	wire line1_fwdable, line2_fwdable;
	
	assign line1_fwdable = ~(OpCode_EX == 5'b00000 |		// HALT
							 OpCode_EX == 5'b00001 |		// NOP
							 OpCode_EX[4:2] == 3'b011 |		// branches
							 OpCode_EX == 5'b11000 |		// LBI
							 //OpCode_EX == 5'b10010 |		// SLBI
							 OpCode_EX == 5'b00100 |		// J
							 OpCode_EX == 5'b00110 |		// JAL
							 OpCode_EX == 5'b00010 |		// siic
							 OpCode_EX == 5'b00011);		// RTI
							 
	assign line2_fwdable = OpCode_EX == 5'b10000 |			// ST
						   OpCode_EX == 5'b10011 |			// STU
						   OpCode_EX == 5'b11011 |			// ADD, SUB, XOR, ANDN
						   OpCode_EX == 5'b11010 |			// ROL, SLL, ROR, SRL
						   OpCode_EX[4:2] == 3'b111;		// SEQ, SLT, SLE, SCO
	
	assign line1_EXEX = RegWrite_MEM & line1_fwdable & (Write_register_MEM == read1RegSel_EX) & ~MemRead_MEM;
	assign line2_EXEX = RegWrite_MEM & line2_fwdable & (Write_register_MEM == read2RegSel_EX) & ~MemRead_MEM;
	
	assign line1_MEMEX = RegWrite_WB & line1_fwdable & (Write_register_WB == read1RegSel_EX);
	assign line2_MEMEX = RegWrite_WB & line2_fwdable & (Write_register_WB == read2RegSel_EX);
	

	

	
endmodule
