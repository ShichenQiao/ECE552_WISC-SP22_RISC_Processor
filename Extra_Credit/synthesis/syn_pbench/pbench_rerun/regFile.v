/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );
				
	parameter REGWIDTH = 16;

	input        clk, rst;
	input [2:0]  read1RegSel;
	input [2:0]  read2RegSel;
	input [2:0]  writeRegSel;
	input [REGWIDTH-1:0] writeData;
	input        writeEn;

	output reg [REGWIDTH-1:0] read1Data;
	output reg [REGWIDTH-1:0] read2Data;
	output        err;

	/* YOUR CODE HERE */
	wire [REGWIDTH-1:0] readData [0:7];
	reg [7:0] regWrite;
	wire [7:0] regWriteEn;
	wire [7:0] err_regs;
	reg err_regWrite, err_read1Data, err_read2Data;
	
	// decode writeRegSel to one-hot vector regWrite
	always @* begin
		err_regWrite = 1'b0;
		regWrite = 8'b0000_0000;
		
		case(writeRegSel)
			3'b000: regWrite = 8'b0000_0001;
			3'b001: regWrite = 8'b0000_0010;
			3'b010: regWrite = 8'b0000_0100;
			3'b011: regWrite = 8'b0000_1000;
			3'b100: regWrite = 8'b0001_0000;
			3'b101: regWrite = 8'b0010_0000;
			3'b110: regWrite = 8'b0100_0000;
			3'b111: regWrite = 8'b1000_0000;
			default: err_regWrite = 1'b1;
		endcase
	end
	
	// create Write Enable signals for the registers based on RF wrtieEN
	assign regWriteEn = writeEn ? regWrite : 8'b0000_0000;
	
	// instantiate R0 through R7
	register #(.REGWIDTH(REGWIDTH)) R0(
		.readData(readData[0]),
		.err(err_regs[0]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[0])
	);
	register #(.REGWIDTH(REGWIDTH)) R1(
		.readData(readData[1]),
		.err(err_regs[1]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[1])
	);
		register #(.REGWIDTH(REGWIDTH)) R2(
		.readData(readData[2]),
		.err(err_regs[2]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[2])
	);
		register #(.REGWIDTH(REGWIDTH)) R3(
		.readData(readData[3]),
		.err(err_regs[3]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[3])
	);
		register #(.REGWIDTH(REGWIDTH)) R4(
		.readData(readData[4]),
		.err(err_regs[4]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[4])
	);
		register #(.REGWIDTH(REGWIDTH)) R5(
		.readData(readData[5]),
		.err(err_regs[5]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[5])
	);
		register #(.REGWIDTH(REGWIDTH)) R6(
		.readData(readData[6]),
		.err(err_regs[6]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[6])
	);
		register #(.REGWIDTH(REGWIDTH)) R7(
		.readData(readData[7]),
		.err(err_regs[7]),
		.clk(clk),
		.rst(rst),
		.writeData(writeData),
		.writeEn(regWriteEn[7])
	);
	
	// select proper read1Data based on read1RegSel
	always @* begin
		err_read1Data = 1'b0;
		read1Data = {REGWIDTH{1'b0}};
		
		case(read1RegSel)
			3'b000: read1Data = readData[0];
			3'b001: read1Data = readData[1];
			3'b010: read1Data = readData[2];
			3'b011: read1Data = readData[3];
			3'b100: read1Data = readData[4];
			3'b101: read1Data = readData[5];
			3'b110: read1Data = readData[6];
			3'b111: read1Data = readData[7];
			default: err_read1Data = 1'b1;
		endcase
	end
	
	// select proper read2Data based on read2RegSel
	always @* begin
		err_read2Data = 1'b0;
		read2Data = {REGWIDTH{1'b0}};
	
		case(read2RegSel)
			3'b000: read2Data = readData[0];
			3'b001: read2Data = readData[1];
			3'b010: read2Data = readData[2];
			3'b011: read2Data = readData[3];
			3'b100: read2Data = readData[4];
			3'b101: read2Data = readData[5];
			3'b110: read2Data = readData[6];
			3'b111: read2Data = readData[7];
			default: err_read2Data = 1'b1;
		endcase
	end
	
	// generate overall err flag of the whole RF. Note that err_regs take care of writeData
	/*
	assign err = err_regWrite | err_read1Data | err_read2Data |			// detect invalid sel inputs
				 (writeEn === 1'bx) | (writeEn === 1'bz) |				// detect invalid writeEn
				 (|err_regs);					// err is also asserted if any indivisual register has an err
	*/
	assign err = err_regWrite | err_read1Data | err_read2Data | (|err_regs);

endmodule
