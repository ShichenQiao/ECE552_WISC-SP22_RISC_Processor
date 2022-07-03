/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 1 read
   port, a write enable, a reset, and a clock input.  
*/
module register (
                // Outputs
                readData, err,
                // Inputs
                clk, rst, writeData, writeEn
                );
				
	parameter REGWIDTH = 16;
	
	input clk, rst;
    input [REGWIDTH-1:0] writeData;
    input writeEn;

    output [REGWIDTH-1:0] readData;
    output err;
	
	wire [REGWIDTH-1:0] D;				// actural inputs to the DFFs
	
	// when enable, take writeData as D, otherwise, take Q as D to be not modified
	assign D = writeEn ? writeData : readData;
	
	dff iREG[REGWIDTH-1:0](
        .q(readData),
        .d(D),
		.clk(clk),
		.rst(rst)
    );
	
	/*
	// assume that an error only happens in a register if the input or enable is an unknown value
	assign err = (writeEn === 1'bx) |
				 (writeEn === 1'bz) |
				 (^writeData === 1'bx) |
				 (^writeData === 1'bz);
	*/
	assign err = 1'b0;			// for synthesis

endmodule
