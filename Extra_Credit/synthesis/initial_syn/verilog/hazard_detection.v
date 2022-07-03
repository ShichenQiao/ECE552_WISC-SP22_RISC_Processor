/*
	CS/ECE 552 Spring '22

	Filename        : hazard_detection.v
	Description     : hazard_detection unit
*/
module hazard_detection (
	// Outputs
	stall, XD_fwd, //MD_fwd,
	// Inputs
	OpCode_ID, Rs_ID, Rt_ID,
	Write_register_EX, RegWrite_EX,
	Write_register_MEM, RegWrite_MEM,
	branchJumpDTaken_ID, FWD, MemRead_EX,
	MemRead_MEM, MemWrite_EX, read2RegSel_EX,
	MemWrite_ID, RegWrite_WB, Write_register_WB
	);

	input [4:0] OpCode_ID;
	input [2:0] Rs_ID, Rt_ID;
	input [2:0] Write_register_EX, Write_register_MEM;
	input RegWrite_EX;
	input RegWrite_MEM;
	input branchJumpDTaken_ID;
	input FWD;
	input MemRead_EX;
	input MemRead_MEM;
	input MemWrite_EX;
	input [2:0] read2RegSel_EX;
	input MemWrite_ID;
	input RegWrite_WB;
	input [2:0] Write_register_WB;
	
	output stall;
	
	// extra credit
	output XD_fwd;
	//output MD_fwd;
	
	wire EX_RAW_Rs, EX_RAW_Rt, MEM_RAW_Rs, MEM_RAW_Rt;
	wire Rt_active;
	wire Rt_stall, Rs_stall;
	
	wire branch_stall;		// stall branch in Decode waiting for RF bypassing of the previous instruction
	wire jalr_pass;			// if JALR in Decode and Rs can be EX-EX forwarded in the next cycle, do NOT stall
	wire load_stall;		// load to use stall
	
	// check if forwarding will be available
	wire line1_fwdable, line2_fwdable;
	wire fwd;
	wire line1_EXEX, line2_EXEX, line1_MEMEX, line2_MEMEX;
	wire MEMMEM_fwd;
	
	assign EX_RAW_Rs = RegWrite_EX & (Rs_ID == Write_register_EX);
	assign EX_RAW_Rt = RegWrite_EX & (Rt_ID == Write_register_EX);
	assign MEM_RAW_Rs = RegWrite_MEM & (Rs_ID == Write_register_MEM);
	assign MEM_RAW_Rt = RegWrite_MEM & (Rt_ID == Write_register_MEM);
	
	assign Rt_active = (OpCode_ID[4:1] == 4'b1101) | (OpCode_ID[4:2] == 3'b111) |
					   (OpCode_ID == 5'b10000) | (OpCode_ID == 5'b10011) ;
	
	assign Rs_stall = (OpCode_ID == 5'b11000) ? 1'b0 : (EX_RAW_Rs | MEM_RAW_Rs);
	assign Rt_stall = Rt_active ? (EX_RAW_Rt | MEM_RAW_Rt) : 1'b0;
	
	assign branch_stall = (OpCode_ID[4:2] == 3'b011) & ((RegWrite_EX & (Write_register_EX == Rs_ID)) | (RegWrite_MEM & (Write_register_MEM == Rs_ID))) & ~XD_fwd;
	
	assign jalr_pass = (OpCode_ID == 5'b00111) & (Write_register_EX == Rs_ID) & RegWrite_EX & ~MemRead_EX;
	
	assign load_stall = MemRead_EX & RegWrite_EX & (((Write_register_EX == Rs_ID) & (OpCode_ID != 5'b11000)) | (Rt_active & (Write_register_EX == Rt_ID))) & ~MEMMEM_fwd;
	
	assign stall = (((Rs_stall | Rt_stall) & ((OpCode_ID != 5'b00001)) & ~fwd) | branch_stall | load_stall) & ~jalr_pass;
	
	assign line1_fwdable = ~(OpCode_ID == 5'b00000 |		// HALT
							 OpCode_ID == 5'b00001 |		// NOP
							 OpCode_ID[4:2] == 3'b011 |		// branches
							 OpCode_ID == 5'b11000 |		// LBI
							 OpCode_ID == 5'b00100 |		// J
							 OpCode_ID == 5'b00110 |		// JAL
							 OpCode_ID == 5'b00010 |		// siic
							 OpCode_ID == 5'b00011);		// RTI
							 
	assign line2_fwdable = OpCode_ID == 5'b10000 |			// ST
						   OpCode_ID == 5'b10011 |			// STU
						   OpCode_ID == 5'b11011 |			// ADD, SUB, XOR, ANDN
						   OpCode_ID == 5'b11010 |			// ROL, SLL, ROR, SRL
						   OpCode_ID[4:2] == 3'b111;		// SEQ, SLT, SLE, SCO
	
	assign line1_EXEX = RegWrite_EX & line1_fwdable & (Write_register_EX == Rs_ID) & ~MemRead_EX;
	assign line2_EXEX = RegWrite_EX & line2_fwdable & (Write_register_EX == Rt_ID) & ~MemRead_EX;
	
	assign line1_MEMEX = RegWrite_MEM & line1_fwdable & (Write_register_MEM == Rs_ID);
	assign line2_MEMEX = RegWrite_MEM & line2_fwdable & (Write_register_MEM == Rt_ID);
	
	assign MEMMEM_fwd = MemRead_EX & MemWrite_ID & (Write_register_EX == Rt_ID) & (Write_register_EX != Rs_ID);
	
	assign XD_fwd = (OpCode_ID[4:2] == 3'b011) & RegWrite_MEM & ~MemRead_MEM & (Rs_ID == Write_register_MEM) & ~((Write_register_EX == Rs_ID) & RegWrite_EX);
	
	assign fwd = line1_EXEX | line2_EXEX | line1_MEMEX | line2_MEMEX | MEMMEM_fwd | XD_fwd;
	
endmodule
