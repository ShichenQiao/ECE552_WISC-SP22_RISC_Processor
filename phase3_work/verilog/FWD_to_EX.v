/*
	CS/ECE 552 Spring '22

	Filename        : FWD_to_EX.v
	Description     : EX to EX forwarding and MEM to EX forwarding logic
*/
module FWD_to_EX (
	// Outputs
	line1_EXEX, line2_EXEX, line1_MEMEX, line2_MEMEX,
	// Inputs
	Write_register_EX, RegWrite_EX, MemRead_EX,
	link_EX, read1RegSel_ID, read2RegSel_ID, OpCode_ID,
	MemtoReg_MEM, Write_register_MEM, RegWrite_MEM, link_MEM,
	);
	
	// EX-EX
	input [2:0] Write_register_EX;
	input RegWrite_EX;
	input MemRead_EX;
	input link_EX;
	input [2:0] read1RegSel_ID, read2RegSel_ID;
	input [4:0] OpCode_ID;
	// MEM-EX
	input MemtoReg_MEM;
	input [2:0] Write_register_MEM;
	
	input RegWrite_MEM, link_MEM;

	output line1_EXEX, line2_EXEX;
	output line1_MEMEX, line2_MEMEX;
	
	wire line1_fwdable, line2_fwdable;		// when high, EX line can be forwarded to

	assign line1_fwdable = ~(OpCode_ID == 5'b00000 |		// HALT
							 OpCode_ID == 5'b00001 |		// NOP
							 OpCode_ID[4:2] == 3'b011 |		// branches
							 OpCode_ID == 5'b11000 |		// LBI
							 OpCode_ID == 5'b10010 |		// SLBI
							 OpCode_ID == 5'b00100 |		// J
							 OpCode_ID == 5'b00110 |		// JAL
							 OpCode_ID == 5'b00010 |		// siic
							 OpCode_ID == 5'b00011);		// RTI
	
	assign line1_EXEX = RegWrite_EX & line1_fwdable & ((read1RegSel_ID == Write_register_EX) | ((read1RegSel_ID == 3'b111) & link_EX)) & ~MemRead_EX;
	
	assign line2_fwdable = OpCode_ID == 5'b10000 |			// ST
						   OpCode_ID == 5'b10011 |			// STU
						   OpCode_ID == 5'b11011 |			// ADD, SUB, XOR, ANDN
						   OpCode_ID == 5'b11010 |			// ROL, SLL, ROR, SRL
						   OpCode_ID[4:2] == 3'b111;		// SEQ, SLT, SLE, SCO
	
	assign line2_EXEX = RegWrite_EX & line2_fwdable & ((read2RegSel_ID == Write_register_EX) | ((read2RegSel_ID == 3'b111) & link_EX)) & ~MemRead_EX;
	
	// MEM-EX
	//assign line1_MEMEX = MemtoReg_MEM & line1_fwdable & (read1RegSel_ID == Write_register_MEM) & ~line1_EXEX;
	//assign line2_MEMEX = MemtoReg_MEM & line2_fwdable & (read2RegSel_ID == Write_register_MEM) & ~line2_EXEX;
	
	/*
	assign line1_MEMEX = MemtoReg_MEM ? (line1_fwdable & (read1RegSel_ID == Write_register_MEM) & ~(line1_EXEX & (Write_register_EX == Write_register_MEM))) :
										(RegWrite_MEM & line1_fwdable & ((read1RegSel_ID == Write_register_MEM) | ((read1RegSel_ID == 3'b111) & link_MEM)) & ~(line1_EXEX & (Write_register_EX == Write_register_MEM)));
	assign line2_MEMEX = MemtoReg_MEM ? (line2_fwdable & (read2RegSel_ID == Write_register_MEM) & ~(line2_EXEX & (Write_register_EX == Write_register_MEM))) :
										(RegWrite_MEM & line2_fwdable & ((read2RegSel_ID == Write_register_MEM) | ((read2RegSel_ID == 3'b111) & link_MEM)) & ~(line2_EXEX & (Write_register_EX == Write_register_MEM)));
	*/
	
	assign line1_MEMEX = RegWrite_MEM & line1_fwdable & ((read1RegSel_ID == Write_register_MEM) | ((read1RegSel_ID == 3'b111) & link_MEM)) & ~((line1_EXEX | line2_EXEX) & (Write_register_EX == Write_register_MEM));
	assign line2_MEMEX = RegWrite_MEM & line2_fwdable & ((read2RegSel_ID == Write_register_MEM) | ((read2RegSel_ID == 3'b111) & link_MEM)) & ~((line1_EXEX | line2_EXEX) & (Write_register_EX == Write_register_MEM));
	
endmodule
