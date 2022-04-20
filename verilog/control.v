/*
	CS/ECE 552 Spring '22

	Filename        : control.v
	Description     : This is the module for the control unit of the processor.
	
	Instruction Format 			Syntax 							Semantics
	00000 xxxxxxxxxxx 			HALT 							Cease instruction issue, dump memory state to file
	00001 xxxxxxxxxxx 			NOP 							None
	
	01000 sss ddd iiiii 		ADDI Rd, Rs, immediate 			Rd <- Rs + I(sign ext.)
	01001 sss ddd iiiii 		SUBI Rd, Rs, immediate 			Rd <- I(sign ext.) - Rs
	01010 sss ddd iiiii 		XORI Rd, Rs, immediate 			Rd <- Rs XOR I(zero ext.)
	01011 sss ddd iiiii 		ANDNI Rd, Rs, immediate 		Rd <- Rs AND ~I(zero ext.)
	10100 sss ddd iiiii 		ROLI Rd, Rs, immediate 			Rd <- Rs <<(rotate) I(lowest 4 bits)
	10101 sss ddd iiiii 		SLLI Rd, Rs, immediate		 	Rd <- Rs << I(lowest 4 bits)
	10110 sss ddd iiiii 		RORI Rd, Rs, immediate 			Rd <- Rs >>(rotate) I(lowest 4 bits)
	10111 sss ddd iiiii 		SRLI Rd, Rs, immediate 			Rd <- Rs >> I(lowest 4 bits)
	10000 sss ddd iiiii 		ST Rd, Rs, immediate 			Mem[Rs + I(sign ext.)] <- Rd
	10001 sss ddd iiiii 		LD Rd, Rs, immediate 			Rd <- Mem[Rs + I(sign ext.)]
	10011 sss ddd iiiii 		STU Rd, Rs, immediate 			Mem[Rs + I(sign ext.)] <- Rd
																	Rs <- Rs + I(sign ext.)
	
	11001 sss xxx ddd xx 		BTR Rd, Rs 						Rd[bit i] <- Rs[bit 15-i] for i=0..15
	11011 sss ttt ddd 00 		ADD Rd, Rs, Rt 					Rd <- Rs + Rt
	11011 sss ttt ddd 01 		SUB Rd, Rs, Rt 					Rd <- Rt - Rs
	11011 sss ttt ddd 10 		XOR Rd, Rs, Rt 					Rd <- Rs XOR Rt
	11011 sss ttt ddd 11 		ANDN Rd, Rs, Rt 				Rd <- Rs AND ~Rt
	11010 sss ttt ddd 00 		ROL Rd, Rs, Rt 					Rd <- Rs << (rotate) Rt (lowest 4 bits)
	11010 sss ttt ddd 01 		SLL Rd, Rs, Rt 					Rd <- Rs << Rt (lowest 4 bits)
	11010 sss ttt ddd 10 		ROR Rd, Rs, Rt 					Rd <- Rs >> (rotate) Rt (lowest 4 bits)
	11010 sss ttt ddd 11 		SRL Rd, Rs, Rt 					Rd <- Rs >> Rt (lowest 4 bits)
	11100 sss ttt ddd xx 		SEQ Rd, Rs, Rt 					if (Rs == Rt) then Rd <- 1 else Rd <- 0
	11101 sss ttt ddd xx 		SLT Rd, Rs, Rt 					if (Rs < Rt) then Rd <- 1 else Rd <- 0
	11110 sss ttt ddd xx 		SLE Rd, Rs, Rt 					if (Rs <= Rt) then Rd <- 1 else Rd <- 0
	11111 sss ttt ddd xx 		SCO Rd, Rs, Rt 					if (Rs + Rt) generates carry out
																	then Rd <- 1 else Rd <- 0
	
	01100 sss iiiiiiii 			BEQZ Rs, immediate 				if (Rs == 0) then
																	PC <- PC + 2 + I(sign ext.)
	01101 sss iiiiiiii 			BNEZ Rs, immediate 				if (Rs != 0) then
																	PC <- PC + 2 + I(sign ext.)
	01110 sss iiiiiiii 			BLTZ Rs, immediate 				if (Rs < 0) then
																	PC <- PC + 2 + I(sign ext.)
	01111 sss iiiiiiii 			BGEZ Rs, immediate 				if (Rs >= 0) then
																	PC <- PC + 2 + I(sign ext.)
	11000 sss iiiiiiii 			LBI Rs, immediate 				Rs <- I(sign ext.)
	10010 sss iiiiiiii 			SLBI Rs, immediate 				Rs <- (Rs << 8) | I(zero ext.)
	
	00100 ddddddddddd 			J displacement 					PC <- PC + 2 + D(sign ext.)
	00101 sss iiiiiiii 			JR Rs, immediate 				PC <- Rs + I(sign ext.)
	00110 ddddddddddd 			JAL displacement 				R7 <- PC + 2
																	PC <- PC + 2 + D(sign ext.)
	00111 sss iiiiiiii 			JALR Rs, immediate 				R7 <- PC + 2
																	PC <- Rs + I(sign ext.)
	
	00010 						siic Rs 						produce IllegalOp exception. Must provide one source register.
	00011 xxxxxxxxxxx 			NOP / RTI 						PC <- EPC
*/
module control (
	// Outputs
	err, 
	halt, createdump, RegDst, imm5, SignImm,
	ALUOp, ALUSrc, ClrALUSrc, Cin, invA, invB, sign,
	JumpI, JumpD, Branch,
	MemWrite, MemRead,
	CmpSet, CmpOp, MemtoReg, RegWrite, link,
	specialOP,
	// Inputs
	OpCode, funct
);
	input [4:0] OpCode;
	input [1:0] funct;					// for R format instructions
	
	output reg err;
	output reg halt;
	output reg createdump;
	output reg [1:0] RegDst;				// 00: Instruction[10:8], 01: Instruction[7:5], 10: Instruction[4:2], 11: R7
	output reg imm5;
	output reg SignImm;
	
	/*
		ALUOp:
		000 ROL Rotate left
		001 SLL Shift left logical
		010 ROR Rotate right
		011 SRL Shift right logical
		100 ADD A+B
		101 AND A AND B
		110 OR A OR B
		111 XOR A XOR B
	*/
	output reg [2:0] ALUOp;
	
	output reg ALUSrc;
	output reg ClrALUSrc;					// when asserted, clear the Src2 to the ALU
	output reg Cin, invA, invB, sign;		// other ALU controls
	output reg JumpI, JumpD;
	output reg Branch;
	output reg MemWrite, MemRead;
	output reg CmpSet;
	output reg [1:0] CmpOp;					// 00: == , 01: < , 10: <= , 11: carryout
	output reg MemtoReg;
	output reg RegWrite;
	output reg link;
	
	// extending ALU functionalities
	output reg [1:0] specialOP;				// 00: none, 01: BTR, 10 LBI, 11 SLBI
	
	always @(*) begin
		err = 1'b0;
		halt = 1'b0;
		createdump = 1'b0;
		RegDst = 2'b00;			// Rs by default
		imm5 = 1'b0;
		SignImm = 1'b0;
		ALUOp = 3'b000;			// rll by default
		ALUSrc = 1'b0;
		ClrALUSrc = 1'b0;
		Cin = 1'b0;
		invA = 1'b0;
		invB = 1'b0;
		sign = 1'b1;			// signed ALU operation by default
		JumpI = 1'b0;
		JumpD = 1'b0;
		Branch = 1'b0;
		MemWrite = 1'b0;
		MemRead = 1'b0;
		CmpSet = 1'b0;
		CmpOp = 2'b00;			// == by default
		MemtoReg = 1'b0;
		RegWrite = 1'b0;
		link = 1'b0;
		specialOP = 2'b00;		// by default, no special operation, just take ALU out to XOut
		
		case(OpCode)
			5'b00000: begin		// HALT
				halt = 1'b1;
				createdump = 1'b1;
			end
			5'b00001: begin		// NOP
				// none
			end
			
			/* I format 1 below: */
			
			5'b01000: begin		// ADDI
				RegDst = 2'b01;
				imm5 = 1'b1;
				SignImm = 1'b1;
				ALUOp = 3'b100;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
			end
			5'b01001: begin		// SUBI
				RegDst = 2'b01;
				imm5 = 1'b1;
				SignImm = 1'b1;
				ALUOp = 3'b100;
				ALUSrc = 1'b1;
				Cin = 1'b1;
				invA = 1'b1;
				RegWrite = 1'b1;
			end	
			5'b01010: begin		// XORI
				RegDst = 2'b01;
				imm5 = 1'b1;
				ALUOp = 3'b111;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
			end
			5'b01011: begin		// ANDNI
				RegDst = 2'b01;
				imm5 = 1'b1;
				ALUOp = 3'b101;
				ALUSrc = 1'b1;
				invB = 1'b1;
				RegWrite = 1'b1;
			end
			5'b10100: begin		// ROLI
				RegDst = 2'b01;
				imm5 = 1'b1;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
			end
			5'b10101: begin		// SLLI
				RegDst = 2'b01;
				imm5 = 1'b1;
				ALUOp = 3'b001;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
			end
			5'b10110: begin		// RORI
				RegDst = 2'b01;
				imm5 = 1'b1;
				ALUOp = 3'b010;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
			end
			5'b10111: begin		// SRLI
				RegDst = 2'b01;
				imm5 = 1'b1;
				ALUOp = 3'b011;
				ALUSrc = 1'b1;
				RegWrite = 1'b1;
			end
			5'b10000: begin		// ST
				imm5 = 1'b1;
				SignImm = 1'b1;
				ALUOp = 3'b100;			// Rs + I(Sign Extend)
				ALUSrc = 1'b1;
				MemWrite = 1'b1;
			end
			5'b10001: begin		// LD
				RegDst = 2'b01;
				imm5 = 1'b1;
				SignImm = 1'b1;
				ALUOp = 3'b100;
				ALUSrc = 1'b1;
				MemRead = 1'b1;
				MemtoReg = 1'b1;
				RegWrite = 1'b1;
			end
			5'b10011: begin		// STU
				RegDst = 2'b00;
				imm5 = 1'b1;
				SignImm = 1'b1;
				ALUOp = 3'b100;
				ALUSrc = 1'b1;
				MemWrite = 1'b1;
				RegWrite = 1'b1;
			end
						
			/* R format below: */
			
			5'b11001: begin		// BTR
				RegDst = 2'b10;
				RegWrite = 1'b1;
				specialOP = 2'b01;
			end
			5'b11011: begin		// ADD, SUB, XOR, ANDN
				case(funct)
					2'b00: begin		// ADD
						RegDst = 2'b10;
						ALUOp = 3'b100;
						RegWrite = 1'b1;
					end
					2'b01: begin		// SUB
						RegDst = 2'b10;
						ALUOp = 3'b100;
						RegWrite = 1'b1;
						Cin = 1'b1;
						invA = 1'b1;
					end
					2'b10: begin		// XOR
						RegDst = 2'b10;
						ALUOp = 3'b111;
						RegWrite = 1'b1;
					end
					2'b11: begin		// ANDN
						RegDst = 2'b10;
						ALUOp = 3'b101;
						RegWrite = 1'b1;
						invB = 1'b1;
					end
					default: err = 1'b1;			// R format funct code error
				endcase
			end
			5'b11010: begin		// ROL, SLL, ROR, SRL
				case(funct)
					2'b00: begin		// ROL
						RegDst = 2'b10;
						RegWrite = 1'b1;
					end
					2'b01: begin		// SLL
						RegDst = 2'b10;
						ALUOp = 3'b001;
						RegWrite = 1'b1;
					end
					2'b10: begin		// ROR
						RegDst = 2'b10;
						ALUOp = 3'b010;
						RegWrite = 1'b1;
					end
					2'b11: begin		// SRL
						RegDst = 2'b10;
						ALUOp = 3'b011;
						RegWrite = 1'b1;
					end
					default: err = 1'b1;			// R format funct code error
				endcase
			end
			5'b11100: begin		// SEQ
				RegDst = 2'b10;
				ALUOp = 3'b100;			// if (Rs - Rt == 0) then Rd <- 1 else Rd <- 0
				Cin = 1'b1;
				invB = 1'b1;
				CmpSet = 1'b1;
				RegWrite = 1'b1;
			end
			5'b11101: begin		// SLT
				RegDst = 2'b10;
				ALUOp = 3'b100;			// if (Rs - Rt < 0) then Rd <- 1 else Rd <- 0
				Cin = 1'b1;
				invB = 1'b1;
				CmpSet = 1'b1;
				CmpOp = 2'b01;
				RegWrite = 1'b1;
			end
			5'b11110: begin		// SLE
				RegDst = 2'b10;
				ALUOp = 3'b100;			// if (Rs - Rt <= 0) then Rd <- 1 else Rd <- 0
				Cin = 1'b1;
				invB = 1'b1;
				CmpSet = 1'b1;
				CmpOp = 2'b10;
				RegWrite = 1'b1;
			end
			5'b11111: begin		// SCO
				RegDst = 2'b10;
				ALUOp = 3'b100;			// if (Rs + Rt) generates carry out, then Rd <- 1 else Rd <- 0
				sign = 1'b0;			// make ALU do unsigned (Rs + Rt) so that Ofl from ALU will indicate c_out
				CmpSet = 1'b1;
				CmpOp = 2'b11;
				RegWrite = 1'b1;
			end
			
			/* I format 2 below: */
			
			5'b01100: begin		// BEQZ
				SignImm = 1'b1;
				Branch = 1'b1;
			end
			5'b01101: begin		// BNEZ
				SignImm = 1'b1;
				Branch = 1'b1;
			end
			5'b01110: begin		// BLTZ
				SignImm = 1'b1;
				Branch = 1'b1;
			end
			5'b01111: begin		// BGEZ
				SignImm = 1'b1;
				Branch = 1'b1;
			end
			5'b11000: begin		// LBI
				SignImm = 1'b1;
				RegWrite = 1'b1;
				specialOP = 2'b10;
			end
			5'b10010: begin		// SLBI
				SignImm = 1'b1;
				RegWrite = 1'b1;
				specialOP = 2'b11;
			end
			
			/* Jump Instructions below: */
			
			5'b00100: begin		// J displacement
				JumpD = 1'b1;
			end
			5'b00101: begin		// JR
				SignImm = 1'b1;
				ALUOp = 3'b100;			// PC <- Rs + I(sign ext.)
				ALUSrc = 1'b1;
				JumpI = 1'b1;
			end
			5'b00110: begin		// JAL
				RegDst = 2'b11;			// R7
				JumpD = 1'b1;
				RegWrite = 1'b1;
				link = 1'b1;
			end
			5'b00111: begin		// JALR
				RegDst = 2'b11;			// R7
				SignImm = 1'b1;
				ALUOp = 3'b100;			// PC <- Rs + I(sign ext.)
				ALUSrc = 1'b1;
				JumpI = 1'b1;
				RegWrite = 1'b1;
				link = 1'b1;
			end
			
			/* TODO: Extra Credit below: */
			
			5'b00010: begin		// siic *****************************************
			
			end
			5'b00011: begin		// NOP / RTI ************************************
			
			end
			
			default: err = 1'b1;		// Control OpCode error
		endcase
	end   

endmodule
