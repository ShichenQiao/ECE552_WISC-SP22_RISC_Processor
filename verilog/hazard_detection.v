/*
	CS/ECE 552 Spring '22

	Filename        : hazard_detection.v
	Description     : hazard_detection unit
*/
module hazard_detection (
	// Outputs
	stall,
	// Inputs
	OpCode_ID, Rs_ID, Rt_ID,
	Write_register_EX, RegWrite_EX,
	Write_register_MEM, RegWrite_MEM,
	branchJumpDTaken_ID, FWD, MemRead_EX
	);

	input [4:0] OpCode_ID;
	input [2:0] Rs_ID, Rt_ID;
	input [2:0] Write_register_EX, Write_register_MEM;
	input RegWrite_EX;
	input RegWrite_MEM;
	input branchJumpDTaken_ID;
	input FWD;
	input MemRead_EX;
	
	output stall;
	
	wire EX_RAW_Rs, EX_RAW_Rt, MEM_RAW_Rs, MEM_RAW_Rt;
	wire Rt_active;
	wire Rt_stall, Rs_stall;
	
	wire branch_stall;		// stall branch in Decode waiting for RF bypassing of the previous instruction
	wire jalr_pass;			// if JALR in Decode and Rs can be EX-EX forwarded in the next cycle, do NOT stall
	
	assign EX_RAW_Rs = RegWrite_EX & (Rs_ID == Write_register_EX);
	assign EX_RAW_Rt = RegWrite_EX & (Rt_ID == Write_register_EX);
	assign MEM_RAW_Rs = RegWrite_MEM & (Rs_ID == Write_register_MEM);
	assign MEM_RAW_Rt = RegWrite_MEM & (Rt_ID == Write_register_MEM);
	
	assign Rt_active = (OpCode_ID[4:1] == 4'b1101) | (OpCode_ID[4:2] == 3'b111) |
					   (OpCode_ID == 5'b10000) | (OpCode_ID == 5'b10011) ;
	
	assign Rs_stall = (OpCode_ID == 5'b11000) ? 1'b0 : (EX_RAW_Rs | MEM_RAW_Rs);
	assign Rt_stall = Rt_active ? (EX_RAW_Rt | MEM_RAW_Rt) : 1'b0;
	
	assign branch_stall = (OpCode_ID[4:2] == 3'b011) & ((RegWrite_EX & (Write_register_EX == Rs_ID)) | (RegWrite_MEM & (Write_register_MEM == Rs_ID)));
	
	assign jalr_pass = (OpCode_ID == 5'b00111) & (Write_register_EX == Rs_ID) & RegWrite_EX & ~MemRead_EX;
	
	assign stall = (((Rs_stall | Rt_stall) & ((OpCode_ID != 5'b00001)) & ~FWD) | branch_stall) & ~jalr_pass;
	
endmodule
