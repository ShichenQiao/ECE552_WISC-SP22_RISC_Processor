/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 2
    
    a 4-bit CLA module
*/
module cla_4b(sum, c_out, a, b, c_in, P, G);

    // declare constant for size of inputs, outputs (N)
    parameter   N = 4;

    output [N-1:0] sum;
    output         c_out;
    input [N-1: 0] a, b;
    input          c_in;

    // YOUR CODE HERE
	output P, G;								// group propagate and generate signals

	// signals to construct and hold gi and pi
	wire [N-1:0] g, g_inv;						// gi = ai * bi
	wire [N-1:0] p, p_inv;						// pi = ai + bi
	
	// helper wires to construct c, P, and G, only works for N == 4
	wire c3, c2, c1;							// carry signals between the 4 full adders
	wire p0c0_inv;								// intermediate signals for c1
	wire p1g0_inv, p1p0c0_inv;					// intermediate signals for c2
	wire p2g1_inv, p2p1g0_inv;					// intermediate signals for c3_temp
	wire c3_temp;								// c3_temp = g2 + p2 * g1 + p2 * p1 * g0
	wire p2p1p0c0, c3_inv;						// intermediate signals for c3
	wire p3g2_inv, p3p2g1_inv;					// intermediate signals for c4_temp
	wire c4_temp;								// c4_temp = g3 + p3 * g2 + p3 * p2 * g1
	wire p3p2p1_inv, p3p2p1g0, p3p2p1p0c0;		// intermediate signals for c4
	wire c4_inv;								// intermediate signals for c4
	wire G_inv;
	
	// construct generate and propagate signals
	nand2 i_nand2_1[N-1:0](.out(g_inv), .in1(a), .in2(b));
	nor2 i_nor2_1[N-1:0](.out(p_inv), .in1(a), .in2(b));
	not1 i_not1_1[N-1:0](.out(g), .in1(g_inv));					// gi = ai * bi
	not1 i_not1_2[N-1:0](.out(p), .in1(p_inv));					// pi = ai + bi
	
	// performing addition
	fullAdder_1b i_fullAdder_1b[N-1:0](
		.s(sum), 
		.c_out(),					// not used
		.a(a), 
		.b(b), 
		.c_in({c3, c2, c1, c_in})
	);
	
	// c1 = !(!g0 * !(p0 * c0)) = g0 + p0 * c0
	nand2 i_nand2_2(.out(p0c0_inv), .in1(p[0]), .in2(c_in));
	nand2 i_nand2_3(.out(c1), .in1(g_inv[0]), .in2(p0c0_inv));
	
	// c2 = !(!(g1) * !(p1 * g0) * !(p1 * p0 * c0)) = g1 + p1 * g0 + p1 * p0 * c0
	nand2 i_nand2_4(.out(p1g0_inv), .in1(p[1]), .in2(g[0]));
	nand3 i_nand3_1(.out(p1p0c0_inv), .in1(p[1]), .in2(p[0]), .in3(c_in));
	nand3 i_nand3_2(.out(c2), .in1(g_inv[1]), .in2(p1g0_inv), .in3(p1p0c0_inv));
	
	// c3 = (g2 + p2 * g1 + p2 * p1 * g0) + (p2 * p1) * (p0 * c0)
	nand2 i_nand2_5(.out(p2g1_inv), .in1(p[2]), .in2(g[1]));
	nand3 i_nand3_3(.out(p2p1g0_inv), .in1(p[2]), .in2(p[1]), .in3(g[0]));
	nand3 i_nand3_4(.out(c3_temp), .in1(g_inv[2]), .in2(p2g1_inv), .in3(p2p1g0_inv));
	nor3 i_nor3_1(.out(p2p1p0c0), .in1(p_inv[2]), .in2(p_inv[1]), .in3(p0c0_inv));
	nor2 i_nor2_2(.out(c3_inv), .in1(c3_temp), .in2(p2p1p0c0));
	not1 i_not1_3(.out(c3), .in1(c3_inv));
	
	// c_out = c4 = (g3 + p3 * g2 + p3 * p2 * g1) + (p3 * p2 * p1) * g0 + (p3 * p2 * p1) * (p0 * c0)
	nand2 i_nand2_6(.out(p3g2_inv), .in1(p[3]), .in2(g[2]));
	nand3 i_nand3_5(.out(p3p2g1_inv), .in1(p[3]), .in2(p[2]), .in3(g[1]));
	nand3 i_nand3_6(.out(c4_temp), .in1(g_inv[3]), .in2(p3g2_inv), .in3(p3p2g1_inv));
	nand3 i_nand3_7(.out(p3p2p1_inv), .in1(p[3]), .in2(p[2]), .in3(p[1]));
	nor2 i_nor2_3(.out(p3p2p1g0), .in1(p3p2p1_inv), .in2(g_inv[0]));
	nor2 i_nor2_4(.out(p3p2p1p0c0), .in1(p3p2p1_inv), .in2(p0c0_inv));
	nor3 i_nor3_2(.out(c4_inv), .in1(c4_temp), .in2(p3p2p1g0), .in3(p3p2p1p0c0));
	not1 i_not1_4(.out(c_out), .in1(c4_inv));
	
	// G = (g3 + p3 * g2 + p3 * p2 * g1) + (p3 * p2 * p1 * g0)
	nor2 i_nor2_5(.out(G_inv), .in1(c4_temp), .in2(p3p2p1g0));
	not1 i_not1_5(.out(G), .in1(G_inv));
	
	// P = p3 * p2 * p1 * p0
	nor2 i_nor2_6(.out(P), .in1(p3p2p1_inv), .in2(p_inv[0]));

endmodule
