/*
	CS/ECE 552 Spring '20

	Filename        : decode.v
	Description     : This is the module for the overall decode stage of the processor.
*/
module decode (
	// Outputs
	err, read1Data, read2Data, immExt, funct,
	// Global_Control Outputs
	halt, createdump, ALUOp, ALUSrc, ClrALUSrc,
	JumpI, JumpD, Branch, MemWrite, MemRead,
	CmpSet, CmpOp, MemtoReg, link, specialOP,
	// Inputs
	clk, rst, Instruction, WBdata
);
	// TODO: Your code here
	input clk;				// system clock
	input rst;				// master reset, active high
	input [15:0] Instruction;
	input [15:0] WBdata;
	
	output reg err;
	output [15:0] read1Data, read2Data;
	output [15:0] immExt;
	output [1:0] funct;
	
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
	output JumpI, JumpD;
	output Branch;
	output MemWrite, MemRead;
	output CmpSet;
	output [2:0] CmpOp;					// 000: == , 001: != , 010: <= , 011: >= , 100: < , 101: carryout
	output MemtoReg;
	output link;
	
	// extending ALU functionalities
	output [1:0] specialOP;				// 00: none, 01: BTR, 10 LBI, 11 SLBI
	
	reg [2:0] Write_register;
	wire [1:0] regDst;					// 00: Instruction[10:8], 01: Instruction[7:5], 10: Instruction[4:2], 11: R7
	wire RegWrite;
	wire SignImm;
	wire imm5;
	reg err_RF, err_regDst, err_Global_Control;
	
	regFile_bypass i_RF_bypassing(
		.read1Data(read1Data),
		.read2Data(read2Data),
		.err(err_RF),
		.clk(clk),
		.rst(rst),
		.read1RegSel(Instruction[10:8]),
		.read2RegSel(Instruction[7:5]),
		.writeRegSel(Write_register),
		.writeData(WBdata),
		.writeEn(RegWrite)
	);
	
	always @(*) begin
		err_regDst = 1'b0;
		Write_register = 3'b000;
		
		case(regDst)
			2'b00: Write_register = Instruction[10:8];			// Rs
			2'b01: Write_register = Instruction[7:5];			// Rt
			2'b10: Write_register = Instruction[4:2];			// Rd
			2'b11: Write_register = 3'b111;						// R7
			default: err_regDst = 1'b1;
		endcase
	end
	
	assign immExt = SignImm ? (imm5 ? {{11{Instruction[4]}}, Instruction[4:0]} : {{8{Instruction[4]}}, Instruction[7:0]}) :
							  (imm5 ? {11'h000, Instruction[4:0]} : {8'h00, Instruction[7:0]});
							  
	assign funct = Instruction[1:0];
	
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
		.funct(funct)
	);
	
	assign err = err_RF | err_regDst | err_Global_Control |
				 (^WBdata === 1'bz) | (^WBdata === 1'bx);
	
endmodule
