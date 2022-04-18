/*
	CS/ECE 552 Spring '22

	Filename        : decode.v
	Description     : This is the module for the overall decode stage of the processor.
*/
module decode (
	// Outputs
	err, read1Data, read2Data, immExt, Write_register,
	// Global_Control Outputs
	halt, createdump, ALUOp, ALUSrc, ClrALUSrc,
	Cin, invA, invB, sign,
	JumpI, MemWrite, MemRead,
	CmpSet, CmpOp, MemtoReg, link, specialOP,
	branchJumpDTaken, branchJumpDTarget, RegWrite,
	// Inputs
	clk, rst, Instruction, WBdata, WBreg, WBregwrite, PC_plus_two
);
	input clk;				// system clock
	input rst;				// master reset, active high
	input [15:0] Instruction;
	input [15:0] WBdata;
	input [2:0] WBreg;
	input WBregwrite;
	input [15:0] PC_plus_two;
	
	output err;
	output [15:0] read1Data, read2Data;
	output [15:0] immExt;
	
	/* Outputs from control below: */
	
	output halt;
	output createdump;
	
	/*
		ALUOp:
		000 rll Rotate left
		001 sll Shift left logical
		010 sra Shift right arithmetic
		011 srl Shift right logical
		100 ADD A+B
		101 AND A AND B
		110 OR A OR B
		111 XOR A XOR B
	*/
	output [2:0] ALUOp;
	
	output ALUSrc;
	output ClrALUSrc;					// when asserted, clear the Src2 to the ALU
	output Cin, invA, invB, sign;		// other ALU controls
	output JumpI;
	output branchJumpDTaken;
	output [15:0] branchJumpDTarget;
	output MemWrite, MemRead;
	output CmpSet;
	output [1:0] CmpOp;					// 00: == , 01: < , 10: <= , 11: carryout
	output MemtoReg;
	output link;
	
	// extending ALU functionalities
	output [1:0] specialOP;				// 00: none, 01: BTR, 10 LBI, 11 SLBI
	
	// Note: changed to an output in Phase 2 for pipelining
	output reg [2:0] Write_register;
	output RegWrite;
	
	wire [1:0] RegDst;					// 00: Instruction[10:8], 01: Instruction[7:5], 10: Instruction[4:2], 11: R7
	wire SignImm;
	wire imm5;
	wire err_RF, err_Global_Control, err_Branch_JumpD_Detector;
	reg err_regDst;
	wire Branch;
	wire JumpD;
	wire branchJumpDCondition;
	
	// using RF bypassing since Phase 2
	regFile_bypass i_RF_bypass(
		.read1Data(read1Data),
		.read2Data(read2Data),
		.err(err_RF),
		.clk(clk),
		.rst(rst),
		.read1RegSel(Instruction[10:8]),
		.read2RegSel(Instruction[7:5]),
		.writeRegSel(WBreg),
		.writeData(WBdata),
		.writeEn(WBregwrite)
	);
	
	always @(*) begin
		err_regDst = 1'b0;
		Write_register = 3'b000;
		
		case(RegDst)
			2'b00: Write_register = Instruction[10:8];			// Rs
			2'b01: Write_register = Instruction[7:5];			// Rt
			2'b10: Write_register = Instruction[4:2];			// Rd
			2'b11: Write_register = 3'b111;						// R7
			default: err_regDst = 1'b1;
		endcase
	end
	
	assign immExt = SignImm ? (imm5 ? {{11{Instruction[4]}}, Instruction[4:0]} : {{8{Instruction[7]}}, Instruction[7:0]}) :
							  (imm5 ? {11'h000, Instruction[4:0]} : {8'h00, Instruction[7:0]});
							  
	// global control unit
	control Global_Control(
		.err(err_Global_Control), 
		.halt(halt),
		.createdump(createdump),
		.RegDst(RegDst),
		.imm5(imm5),
		.SignImm(SignImm),
		.ALUOp(ALUOp),
		.ALUSrc(ALUSrc),
		.ClrALUSrc(ClrALUSrc),
		.Cin(Cin),
		.invA(invA),
		.invB(invB),
		.sign(sign),
		.JumpI(JumpI),
		.JumpD(JumpD),
		.Branch(Branch),
		.MemWrite(MemWrite),
		.MemRead(MemRead),
		.CmpSet(CmpSet),
		.CmpOp(CmpOp),
		.MemtoReg(MemtoReg),
		.RegWrite(RegWrite),
		.link(link),
		.specialOP(specialOP),
		.OpCode(Instruction[15:11]),
		.funct(Instruction[1:0])
	);
	
	branchJumpD i_Branch_JumpD_Detector(
		.err(err_Branch_JumpD_Detector),
		.branchJumpDTarget(branchJumpDTarget),
		.branchJumpDCondition(branchJumpDCondition),
		.branchOp(Instruction[12:11]),
		.Rs(read1Data),
		.immExt(immExt),
		.PC_plus_two(PC_plus_two),
		.Branch(Branch),
		.JumpD(JumpD),
		.D(Instruction[10:0])
	);
	
	assign branchJumpDTaken = (Branch | JumpD) & branchJumpDCondition;
	
	assign err = err_RF | err_regDst | err_Global_Control | err_Branch_JumpD_Detector |
				 (^WBdata === 1'bz) | (^WBdata === 1'bx);
	
endmodule
