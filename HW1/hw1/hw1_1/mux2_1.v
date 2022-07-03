/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 1

    2-1 mux template
*/
module mux2_1(out, inA, inB, s);
    output  out;
    input   inA, inB;
    input   s;

    // YOUR CODE HERE
	wire sbar;								// store inverted select input
	wire inA_nand_sbar, inB_nand_s;			// store 1st level nand results
	
	// 2:1 mux that output inA when s = 0, and output inB when s = 1
	not1 i_not1_1(.out(sbar), .in1(s));											// sbar = ~s
	nand2 i_nand2_1(.out(inA_nand_sbar), .in1(inA), .in2(sbar));				// inA_nand_sbar = ~(inA * ~s)
	nand2 i_nand2_2(.out(inB_nand_s), .in1(inB), .in2(s));						// inB_nand_s = ~(inB * s)
	nand2 i_nand2_3(.out(out), .in1(inA_nand_sbar), .in2(inB_nand_s));			// out = inA * ~s + inB *s
	
endmodule
