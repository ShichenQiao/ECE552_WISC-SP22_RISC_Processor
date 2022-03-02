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
	input [1:0] CmpOp;				// 00: == , 01: < , 10: <= , 11: carryout
	input Zero;
	input Neg;
	input Ofl;

	output reg err;
	output reg CmpOut;
	
	always @(*) begin
		err = 1'b0;
		CmpOut = 1'b0;
		
		case(CmpOp)
			2'b00: CmpOut = Zero;
			2'b01: CmpOut = Neg;
			2'b10: CmpOut = Neg | Zero;
			2'b11: CmpOut = Ofl;
			default: err = 1'b1;
		endcase
	end
	
endmodule
