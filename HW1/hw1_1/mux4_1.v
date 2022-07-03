/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 1

    4-1 mux template
*/
module mux4_1(out, inA, inB, inC, inD, s);
    output       out;
    input        inA, inB, inC, inD;
    input [1:0]  s;

    // YOUR CODE HERE
	wire mux1_out, mux2_out;			// output of the first-level muxes
	
	// 4:1 mux, s = 00 outputs inA, s = 01 outputs inB, s = 10 outputs inC, s = 11 outputs inD
	mux2_1 i_mux2_1_1(.out(mux1_out), .inA(inA), .inB(inB), .s(s[0]));
	mux2_1 i_mux2_1_2(.out(mux2_out), .inA(inC), .inB(inD), .s(s[0]));
	mux2_1 i_mux2_1_3(.out(out), .inA(mux1_out), .inB(mux2_out), .s(s[1]));
      
endmodule
