module fullAdder_1b_tb;
	logic s, c_out, a, b, c_in;
	
	fullAdder_1b iDUT(.s(s), .c_out(c_out), .a(a), .b(b), .c_in(c_in));
	
	initial begin
		a = 0;
		b = 0;
		c_in = 0;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
		
		a = 0;
		b = 0;
		c_in = 1;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
			
		a = 0;
		b = 1;
		c_in = 0;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
			
		a = 0;
		b = 1;
		c_in = 1;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
			
		a = 1;
		b = 0;
		c_in = 0;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
			
		a = 1;
		b = 0;
		c_in = 1;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
			
		a = 1;
		b = 1;
		c_in = 0;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
			
		a = 1;
		b = 1;
		c_in = 1;
		#5;
		if((c_out * 2 + s) != (a + b + c_in))
			$stop();
		
		$display("tests passed");
		$stop();
		
	end

endmodule
