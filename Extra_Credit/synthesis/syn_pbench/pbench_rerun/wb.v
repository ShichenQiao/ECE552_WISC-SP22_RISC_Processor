/*
	CS/ECE 552 Spring '22

	Filename        : wb.v
	Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (
	// Outputs
	err, WBdata,
	// Inputs
	link, PC_plus_two, MemtoReg, MemOut, XOut
);
	input link;
	input [15:0] PC_plus_two;
	input MemtoReg;
	input [15:0] MemOut;
	input [15:0] XOut;
	
	output err;
	output [15:0] WBdata;
	
	// write back data to the register file
	assign WBdata = link ? PC_plus_two : (MemtoReg ? MemOut : XOut);
	
	/*
	// catch any input error
	assign err = (link === 1'bz) | (link === 1'bx) |
				 (MemtoReg === 1'bz) | (MemtoReg === 1'bx) |
				 (^PC_plus_two === 1'bz) | (^PC_plus_two === 1'bx) |
				 (^MemOut === 1'bz) | (^MemOut === 1'bx);
	*/
	assign err = 1'b0;			// for synthesis
	
endmodule
