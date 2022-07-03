/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2
    
    a 16-bit CLA module
*/
module cla_16b(sum, c_out, a, b, c_in);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 16;

    output [N-1:0] sum;
    output         c_out;
    input [N-1:0] a, b;
    input          c_in;

    // YOUR CODE HERE
	wire G_0_3, G_4_7, G_8_11, G_12_15;			// group G outputs from 4-bit CLAs
	wire P_0_3, P_4_7, P_8_11, P_12_15;			// group G outputs from 4-bit CLAs
	wire c4, c8, c12;							// carry in signals to 4-bit CLA blocks
	wire G_0_7, G_8_15, G_0_15;					// tree structure of 2nd level CLA
	wire P_0_7, P_8_15, P_0_15;					// tree structure of 2nd level CLA
	wire G_4_7_inv, P_4_7_G_0_3_inv;			// intermediate signals for G_0_7
	wire G_12_15_inv, P_12_15_G_8_11_inv;		// intermediate signals for G_8_15
	wire G_8_15_inv, P_8_15_G_0_7_inv;			// intermediate signals for G_0_15
	wire P_0_7_inv, P_8_15_inv, P_0_15_inv;		// intermediate signals for P_0_7, P_8_15, and P_0_15
	wire G_0_15_inv, P_0_15_c_in_inv;			// intermediate signals for c_out
	wire G_0_7_inv, P_0_7_c_in_inv;				// intermediate signals for c8
	wire G_0_3_inv, P_0_3_c_in_inv;				// intermediate signals for c4
	wire G_8_11_inv, P_8_11_c8_inv;				// intermediate signals for c12
	
	// instantiate N/4 4-bit CLAs to form a N-bit CLA, note that N should be a multiple of 4, and N >= 8
	cla_4b i_cla_4b[3:0](
		.sum(sum), 
		.c_out(), 
		.a(a), 
		.b(b), 
		.c_in({c12, c8, c4, c_in}), 
		.P({P_12_15, P_8_11, P_4_7, P_0_3}),
		.G({G_12_15, G_8_11, G_4_7, G_0_3})
	);
	
	// G_0_7 = G_4_7 + P_4_7 * G_0_3
	not1 i_not1_1(.out(G_4_7_inv), .in1(G_4_7));
	nand2 i_nand2_1(.out(P_4_7_G_0_3_inv), .in1(P_4_7), .in2(G_0_3));
	nand2 i_nand2_2(.out(G_0_7), .in1(G_4_7_inv), .in2(P_4_7_G_0_3_inv));
	
	// G_8_15 = G_12_15 + P_12_15 * G_8_11
	not1 i_not1_2(.out(G_12_15_inv), .in1(G_12_15));
	nand2 i_nand2_3(.out(P_12_15_G_8_11_inv), .in1(P_12_15), .in2(G_8_11));
	nand2 i_nand2_4(.out(G_8_15), .in1(G_12_15_inv), .in2(P_12_15_G_8_11_inv));
	
	// G_0_15 = G_8_15 + P_8_15 * G_0_7
	not1 i_not1_3(.out(G_8_15_inv), .in1(G_8_15));
	nand2 i_nand2_5(.out(P_8_15_G_0_7_inv), .in1(P_8_15), .in2(G_0_7));
	nand2 i_nand2_6(.out(G_0_15), .in1(G_8_15_inv), .in2(P_8_15_G_0_7_inv));
	
	// P_0_7 = P_0_3 * P_4_7
	nand2 i_nand2_7(.out(P_0_7_inv), .in1(P_0_3), .in2(P_4_7));
	not1 i_not1_4(.out(P_0_7), .in1(P_0_7_inv));
	
	// P_8_15 = P_8_11 * P_12_15
	nand2 i_nand2_8(.out(P_8_15_inv), .in1(P_8_11), .in2(P_12_15));
	not1 i_not1_5(.out(P_8_15), .in1(P_8_15_inv));
	
	// P_0_15 = P_0_7 * P_8_15
	nand2 i_nand2_9(.out(P_0_15_inv), .in1(P_0_7), .in2(P_8_15));
	not1 i_not1_6(.out(P_0_15), .in1(P_0_15_inv));
	
	// c_out = c16 = G_0_15 + P_0_15 * c_in
	not1 i_not1_7(.out(G_0_15_inv), .in1(G_0_15));
	nand2 i_nand2_10(.out(P_0_15_c_in_inv), .in1(P_0_15), .in2(c_in));
	nand2 i_nand2_11(.out(c_out), .in1(G_0_15_inv), .in2(P_0_15_c_in_inv));
	
	// c8 = G_0_7 + P_0_7 * c_in
	not1 i_not1_8(.out(G_0_7_inv), .in1(G_0_7));
	nand2 i_nand2_12(.out(P_0_7_c_in_inv), .in1(P_0_7), .in2(c_in));
	nand2 i_nand2_13(.out(c8), .in1(G_0_7_inv), .in2(P_0_7_c_in_inv));
	
	// c4 = G_0_3 + P_0_3 * c_in
	not1 i_not1_9(.out(G_0_3_inv), .in1(G_0_3));
	nand2 i_nand2_14(.out(P_0_3_c_in_inv), .in1(P_0_3), .in2(c_in));
	nand2 i_nand2_15(.out(c4), .in1(G_0_3_inv), .in2(P_0_3_c_in_inv));
	
	// c12 = G_8_11 + P_8_11 * c8
	not1 i_not1_10(.out(G_8_11_inv), .in1(G_8_11));
	nand2 i_nand2_16(.out(P_8_11_c8_inv), .in1(P_8_11), .in2(c8));
	nand2 i_nand2_17(.out(c12), .in1(G_8_11_inv), .in2(P_8_11_c8_inv));
	
endmodule
