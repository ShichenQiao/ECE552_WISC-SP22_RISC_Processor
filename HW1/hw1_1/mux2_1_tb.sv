module mux2_1_tb();

	logic inA, inB, s, out;
	
	mux2_1 iDUT(.out(out), .inA(inA), .inB(inB), .s(s));
	
	initial begin
		inA = 0;
		inB = 0;
		s = 0;
		#5;
		if(out !== 0)
			$stop();
		
		inA = 0;
		inB = 0;
		s = 1;
		#5;
		if(out !== 0)
			$stop();
			
		inA = 0;
		inB = 1;
		s = 0;
		#5;
		if(out !== 0)
			$stop();
			
		inA = 0;
		inB = 1;
		s = 1;
		#5;
		if(out !== 1)
			$stop();
			
		inA = 1;
		inB = 0;
		s = 0;
		#5;
		if(out !== 1)
			$stop();
			
		inA = 1;
		inB = 0;
		s = 1;
		#5;
		if(out !== 0)
			$stop();
			
		inA = 1;
		inB = 1;
		s = 0;
		#5;
		if(out !== 1)
			$stop();
			
		inA = 1;
		inB = 1;
		s = 1;
		#5;
		if(out !== 1)
			$stop();
		
		$display("tests passed");
		$stop();
		
	end

endmodule
