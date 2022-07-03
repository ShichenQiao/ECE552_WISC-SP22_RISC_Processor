/*
	CS/ECE 552 Spring '22

	Filename        : alu.v
	Description     : This is the modified ALU of the processor.
	
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
module alu (InA, InB, Cin, Oper, invA, invB, sign, Out, Zero, Ofl);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 3;
       
    input  [OPERAND_WIDTH -1:0] InA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] InB ; // Input operand B
    input                       Cin ; // Carry in
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
    input                       invA; // Signal to invert A
    input                       invB; // Signal to invert B
    input                       sign; // Signal for signed operation
    output [OPERAND_WIDTH -1:0] Out ; // Result of computation
    output                      Ofl ; // Signal if overflow occured
    output                      Zero; // Signal if Out is 0

    /* YOUR CODE HERE */
	wire [OPERAND_WIDTH -1:0] shifter_out;			// output from the barrel shifter
	wire [OPERAND_WIDTH -1:0] twosCompUnit_out;		// output from the two's complement unit
	wire [OPERAND_WIDTH -1:0] A, B;					// input to submodules with invA and invB considered
	wire twosCompUnit_Ofl;
	
	// invert inA and inB, if needed;
	assign A = invA ? ~InA : InA;
	assign B = invB ? ~InB : InB;
	
	// barrel shifter, covering rll, sll, sra, srl
	shifter iShifter(
		.In(A),
		.ShAmt(B[3:0]),
		.Oper(Oper[1:0]),
		.Out(shifter_out)
	);
	
	// two's complement unit, covering ADD, AND, OR, and XOR
	twosCompUnit iTwosCompUnit(
		.A(A),
		.B(B),
		.Cin(Cin),
		.Oper(Oper[1:0]),
		.sign(sign),
		.Out(twosCompUnit_out),
		.Ofl(twosCompUnit_Ofl)
	);
	
	// pick final answer from the submodules
	assign Out = Oper[2] ? twosCompUnit_out : shifter_out;
		
	// generate Ofl flag
	assign Ofl = Oper[2] ? twosCompUnit_Ofl : 1'b0;
	
	// generate Zero flag
	assign Zero = ~(|Out);
    
endmodule
