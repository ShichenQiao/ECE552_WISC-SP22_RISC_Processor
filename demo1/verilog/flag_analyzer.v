/*
	CS/ECE 552 Spring '20

	Filename        : flag_analyzer.v
	Description     : This is the module for the flag_analyzer.
					  It take CmpOp from control and flags from ALU to form a one bit output.
*/
module flag_analyzer (
	// Outputs
	err, CmpOut,
	// Inputs
	CmpOp, Zero, Neg, Ofl
);
	input [2:0] CmpOp;		// 000: == , 001: != , 010: <= , 011: >= , 100: < , 101: carryout
	input Zero;
	input Neg;
	input Ofl;

	output reg err;
	output reg CmpOut;
	
	always @(*) begin
		err = 1'b0;
		CmpOut = 1'b0;
		
		case(CmpOp)
			3'b000:	CmpOut = Zero;
			3'b001:	CmpOut = ~Zero;
			3'b010: CmpOut = Neg | Zero;
			3'b011:	CmpOut = ~Neg | Zero;
			3'b100: CmpOut = Neg;
			3'b101: CmpOut = Ofl;
			default: err = 1'b1;
		endcase
	end
	
endmodule
