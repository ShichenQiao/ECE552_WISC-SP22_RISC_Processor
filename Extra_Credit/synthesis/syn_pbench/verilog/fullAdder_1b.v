/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 1-bit full adder
*/
module fullAdder_1b(s, c_out, a, b, c_in);
    output s;
    output c_out;
    input   a, b;
    input  c_in;

    // YOUR CODE HERE
	wire a_nand_b, a_nand_cin, b_nand_cin;			// nand results of two signals out of a, b, and cin
	
	// logic generating sum (s = exactly one or three of (a,b,cin))
	xor3 i_xor3(.out(s), .in1(a), .in2(b), .in3(c_in));				// s = a XOR b XOR c_in
	
	// logic generating c_out (c_out = two or more of (a, b, cin))
	nand2 i_nand2_1(.out(a_nand_b), .in1(a), .in2(b));
	nand2 i_nand2_2(.out(a_nand_cin), .in1(a), .in2(c_in));
	nand2 i_nand2_3(.out(b_nand_cin), .in1(b), .in2(c_in));
	nand3 i_nand3_1(.out(c_out), .in1(a_nand_b), .in2(a_nand_cin), .in3(b_nand_cin));

endmodule
