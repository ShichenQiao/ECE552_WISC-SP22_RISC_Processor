module test();
	parameter REGWIDTH = 16;
	
	logic        clk, rst;
	logic [2:0]  read1RegSel;
	logic [2:0]  read2RegSel;
	logic [2:0]  writeRegSel;
	logic [REGWIDTH-1:0] writeData;
	logic        writeEn;

	logic [REGWIDTH-1:0] read1Data;
	logic [REGWIDTH-1:0] read2Data;
	logic        err;
	
	regFile #(.REGWIDTH(REGWIDTH)) iRF(
		.read1Data(read1Data),
		.read2Data(read2Data),
		.err(err),
		.clk(clk),
		.rst(rst),
		.read1RegSel(read1RegSel),
		.read2RegSel(read2RegSel),
		.writeRegSel(writeRegSel),
		.writeData(writeData),
		.writeEn(writeEn)
	);
	
	initial begin
		clk = 0;
		rst = 1;
		read1RegSel = 3'b000;
		read2RegSel = 3'b000;
		writeRegSel = 3'b000;
		writeData = 16'h0000;
		writeEn = 1'b0;
		@(negedge clk) rst = 0;
		repeat(5) @(posedge clk);
		if(err != 0)
			$display("Error.");
			
		@(negedge clk);
		read1RegSel = 3'b0x0;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		read1RegSel = 3'b111;
		repeat(5) @(posedge clk);
		
		@(negedge clk);
		read1RegSel = 3'bzzz;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		read1RegSel = 3'b101;
		repeat(5) @(posedge clk);
		
		@(negedge clk);
		read2RegSel = 3'bzxz;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		read2RegSel = 3'b00x;
		repeat(5) @(posedge clk);
		
		@(negedge clk);
		read2RegSel = 3'bz10;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		read2RegSel = 3'b101;
		repeat(5) @(posedge clk);
		
		@(negedge clk);
		writeRegSel = 3'bxxx;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		writeRegSel = 3'b010;
		@(negedge clk);
		writeRegSel = 3'b0z1;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		writeRegSel = 3'b111;
		repeat(5) @(posedge clk);
		
		
		@(negedge clk);
		writeData = 16'b0010_0011_1010_x011;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		writeData = 16'b0010_0011_1010_0011;
		@(negedge clk);
		writeData = 16'b0010_0011_1zz0_1011;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		writeData = 16'hzz00;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		writeData = 16'bxxxx;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		writeData = 16'b0010_0011_1110_1011;
		repeat(5) @(posedge clk);
		
		@(negedge clk);
		writeEn = 1'bx;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		@(negedge clk);
		writeEn = 1'bz;
		@(posedge clk);
		if(err != 1)
			$display("Error.");
		
		$stop();
		
	end
	
	always
		#5 clk = ~clk;

endmodule
