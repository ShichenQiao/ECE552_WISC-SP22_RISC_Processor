/*
    CS/ECE 552 Spring '22
    Homework #1, Problem 1

    3 input NOR
*/
module nor3 (out,in1,in2,in3);
    output out;
    input  in1,in2,in3;
    assign out = ~(in1 | in2 | in3);
endmodule
