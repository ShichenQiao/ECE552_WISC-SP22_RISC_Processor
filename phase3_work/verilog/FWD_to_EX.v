/*
	CS/ECE 552 Spring '22

	Filename        : FWD_to_EX.v
	Description     : EX to EX forwarding and MEM to EX forwarding logic
*/
module FWD_to_EX (
	// Outputs
	line1_EXEX, line2_EXEX, line1_MEMEX, line2_MEMEX,
	// Inputs
	Write_register_MEM, RegWrite_MEM, MemRead_MEM,
	link_MEM, read1RegSel_EX, read2RegSel_EX, OpCode_EX,
	MemtoReg_WB, Write_register_WB
	);
	
	// EX-EX
	input [2:0] Write_register_MEM;
	input RegWrite_MEM;
	input MemRead_MEM;
	input link_MEM;
	input [2:0] read1RegSel_EX, read2RegSel_EX;
	input [4:0] OpCode_EX;
	// MEM-EX
	input MemtoReg_WB;
	input [2:0] Write_register_WB;

	output line1_EXEX, line2_EXEX;
	output line1_MEMEX, line2_MEMEX;
	
	wire line1_fwdable, line2_fwdable;		// when high, EX line can be forwarded to

	assign line1_fwdable = ~(OpCode_EX == 5'b00000 |		// HALT
							 OpCode_EX == 5'b00001 |		// NOP
							 OpCode_EX[4:2] == 3'b011 |		// branches
							 OpCode_EX == 5'b11000 |		// LBI
							 OpCode_EX == 5'b10010 |		// SLBI
							 OpCode_EX == 5'b00100 |		// J
							 OpCode_EX == 5'b00110 |		// JAL
							 OpCode_EX == 5'b00010 |		// siic
							 OpCode_EX == 5'b00011);		// RTI
	
	//assign line1_EXEX = ((read1RegSel_EX == Write_register_MEM) & RegWrite_MEM & line1_fwdable) |
	//					((read1RegSel_EX == 3'b111) & link_MEM);
	
	assign line1_EXEX = RegWrite_MEM & line1_fwdable & ((read1RegSel_EX == Write_register_MEM) | ((read1RegSel_EX == 3'b111) & link_MEM));
	
	assign line2_fwdable = OpCode_EX == 5'b10000 |			// ST
						   OpCode_EX == 5'b10011 |			// STU
						   OpCode_EX == 5'b11011 |			// ADD, SUB, XOR, ANDN
						   OpCode_EX == 5'b11010 |			// ROL, SLL, ROR, SRL
						   OpCode_EX[4:2] == 3'b111;		// SEQ, SLT, SLE, SCO
	
	//assign line2_EXEX = ((read2RegSel_EX == Write_register_MEM) & RegWrite_MEM & line2_fwdable) |
	//					((read2RegSel_EX == 3'b111) & link_MEM);
	
	assign line2_EXEX = RegWrite_MEM & line2_fwdable & ((read1RegSel_EX == Write_register_MEM) | ((read2RegSel_EX == 3'b111) & link_MEM));
	
	// MEM-EX
	assign line1_MEMEX = MemtoReg_WB & line1_fwdable & (read1RegSel_EX == Write_register_WB) & ~line1_EXEX;
	assign line2_MEMEX = MemtoReg_WB & line2_fwdable & (read2RegSel_EX == Write_register_WB) & ~line2_EXEX;
	
endmodule
