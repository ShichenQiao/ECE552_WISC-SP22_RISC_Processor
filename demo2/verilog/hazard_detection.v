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
	Write_register_MEM, RegWrite_MEM
	);

	input [4:0] OpCode_ID;
	input [2:0] Rs_ID, Rt_ID;
	input [2:0] Write_register_EX, Write_register_MEM;
	input RegWrite_EX;
	input RegWrite_MEM;
	
	output stall;
	
	wire EX_RAW_Rs, EX_RAW_Rt, MEM_RAW_Rs, MEM_RAW_Rt;
	wire Rt_active;
	wire Rt_stall, Rs_stall;
	
	assign EX_RAW_Rs = RegWrite_EX & (Rs_ID == Write_register_EX);
	assign EX_RAW_Rt = RegWrite_EX & (Rt_ID == Write_register_EX);
	assign MEM_RAW_Rs = RegWrite_MEM & (Rs_ID == Write_register_MEM);
	assign MEM_RAW_Rt = RegWrite_MEM & (Rt_ID == Write_register_MEM);
	
	assign Rt_active = (OpCode_ID[4:1] == 4'b1101) | (OpCode_ID[4:2] == 3'b111) |
					   (OpCode_ID == 5'b10000) | (OpCode_ID == 5'b10011) ;
	
	assign Rs_stall = EX_RAW_Rs | MEM_RAW_Rs;
	assign Rt_stall = Rt_active ? (EX_RAW_Rt | MEM_RAW_Rt) : 1'b0;
	
	assign stall = (OpCode_ID != 5'b00001) ? (Rs_stall | Rt_stall) : 1'b0;
	
endmodule
