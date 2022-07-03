/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 1

    a 4-bit (quad) 4-1 Mux template
*/
module mux4_1_4b(out, inA, inB, inC, inD, s);

    // parameter N for length of inputs and outputs (to use with larger inputs/outputs)
    parameter N = 4;

    output [N-1:0]  out;
    input [N-1:0]   inA, inB, inC, inD;
    input [1:0]     s;

    // YOUR CODE HERE
	mux4_1 imux4_1[N-1:0](.out(out), .inA(inA), .inB(inB), .inC(inC), .inD(inD), .s(s));

endmodule
