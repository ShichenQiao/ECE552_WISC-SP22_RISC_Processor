/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

	// OR all the err ouputs for every sub-module and assign it as this
	// err output
	wire errF, errD, errX, errM, errW;
	assign err = errF | errD | errX | errM | errW;

	// As desribed in the homeworks, use the err signal to trap corner
	// cases that you think are illegal in your statemachines
   
	/* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
	fetch fetch_stage(
		.err(errF),
		.Instruction(),
		.PC_plus_two(),
		.clk(),
		.rst(),
		.halt(),
		.nxt_PC()
		.createdump()
	);
	
	decode decode_stage(
		.err(errD),
		.read1Data(),
		.read2Data(),
		.immExt(),
		.funct(),
		.clk(),
		.rst(),
		.Instruction(),
		.WBdata()
	);
	
	execute execute_stage(
		.err(errX),
		.XOut(),
		.CmpOut(),
		.read1Data(),
		.read2Data(),
		.immExt(),
		.funct(),
		.CmpOp()
	);
	
	memory memory_stage(
		.err(errM),
		.MemOut(),
		.clk(),
		.rst(),
		.XOut(),
		.WriteData(),
		.MemWrite(),
		.MemRead(),
		.link()
	);
	
	wb write_back_stage(
		.err(errW),
		.WBdata(),
		.link(),
		.PC_plus_two(),
		.MemtoReg(),
		.MemOut(),
		.CmpSet(),
		.CmpOut(),
		.XOut()
	);
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
