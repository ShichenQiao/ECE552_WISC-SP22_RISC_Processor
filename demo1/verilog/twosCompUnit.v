/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 2
    
    A two's complement sub-module that deal with ADD, AND, OR, and XOR operations
 */
module twosCompUnit(A, B, Cin, Oper, sign, Out, Ofl);

    input [15:0] A; 			// Input operand A
    input [15:0] B; 			// Input operand B
    input Cin; 					// Carry in
    input [1:0] Oper; 			// Operation type
    input sign; 				// Signal for signed operation
    output [15:0] Out; 			// Result of computation
    output Ofl; 				// Signal if overflow occured
	
	wire [15:0] AandB, AorB, AxorB;			// possible outputs of this module
	wire [15:0] cla_sum;					// sum and carry out from the CLA
	wire cla_cout;
	
	// logic unit
	assign AandB = A & B;
	assign AorB = A | B;
	assign AxorB = A ^ B;
	
	// CLA module
	cla_16b iCLA(
		.sum(cla_sum),
		.c_out(cla_cout),
		.a(A),
		.b(B),
		.c_in(Cin)
	);
	
	// generate overflow flag
	assign Ofl = |Oper ? 1'b0 : 		// Ofl stays 0 when operation is not ADD
				 sign ? (A[15] ^ B[15] ? 1'b0 : A[15] ^ cla_sum[15]):			// signed overflow detection
				 cla_cout;				// when unsigned, cla_cout is indicating whether overflow occured
				 
	// 00 ADD, 01 AND, 10 OR, 11 XOR
	assign Out = Oper[1] ? Oper[0] ? AxorB : AorB :
						   Oper[0] ? AandB : cla_sum;
	
endmodule
