/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
module shifter (In, ShAmt, Oper, Out);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input  [OPERAND_WIDTH -1:0] In   ; // Input operand
    input  [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input  [NUM_OPERATIONS-1:0] Oper ; // Operation type
    output [OPERAND_WIDTH -1:0] Out  ; // Result of shift/rotate

    /* YOUR CODE HERE */
	wire [OPERAND_WIDTH -1:0] left_out, right_out;			// output from the left_shift_rotator and the right_ari_log_shifter
	
    left_shift_rotator iLeft(
		.In(In), 
		.shift(Oper[0]), 
		.ShAmt(ShAmt), 
		.out(left_out)
	);
	
	// replaced 010 sra Shift right arithmetic by rotate right for the project
	right_shift_rotator iRight(
		.In(In), 
		.shift(Oper[0]), 
		.ShAmt(ShAmt), 
		.out(right_out)
	);
	
	// pick final answer from the submodules
	assign Out = Oper[1] ? right_out : left_out;
   
endmodule
