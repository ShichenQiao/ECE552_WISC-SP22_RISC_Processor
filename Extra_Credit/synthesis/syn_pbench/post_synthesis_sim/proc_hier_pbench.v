`timescale 1ns/10ps
/* $Author: karu $ */
/* $LastChangedDate: 2009-03-04 23:09:45 -0600 (Wed, 04 Mar 2009) $ */
/* $Rev: 45 $ */
module proc_hier_pbench();

   /* BEGIN DO NOT TOUCH */
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   // End of automatics
   

   wire [15:0] PC;
   wire [15:0] Inst;           /* This should be the 16 bits of the FF that
                                  stores instructions fetched from instruction memory
                               */
   wire        RegWrite;       /* Whether register file is being written to */
   wire [2:0]  WriteRegister;  /* What register is written */
   wire [15:0] WriteData;      /* Data */
   wire        MemWrite;       /* Similar as above but for memory */
   wire        MemRead;
   wire [15:0] MemAddress;
   wire [15:0] MemDataIn;
   wire [15:0] MemDataOut;
   wire        DCacheHit;
   wire        ICacheHit;
   wire        DCacheReq;
   wire        ICacheReq;
   

   wire        Halt;         /* Halt executed and in Memory or writeback stage */
        
   integer     inst_count;
   integer     trace_file;
   integer     sim_log_file;
     
   integer     DCacheHit_count;
   integer     ICacheHit_count;
   integer     DCacheReq_count;
   integer     ICacheReq_count;
   
   proc_hier DUT();

   

   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.log and verilogsim.ptrace for output");
      inst_count = 0;
      DCacheHit_count = 0;
      ICacheHit_count = 0;
      DCacheReq_count = 0;
      ICacheReq_count = 0;

      trace_file = $fopen("verilogsim.ptrace");
      sim_log_file = $fopen("verilogsim.log");
      
   end

   always @ (posedge DUT.c0.clk) begin
      if (!DUT.c0.rst) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
         if (DCacheHit) begin
            DCacheHit_count = DCacheHit_count + 1;      
         end    
         if (ICacheHit) begin
            ICacheHit_count = ICacheHit_count + 1;      
         end    
         if (DCacheReq) begin
            DCacheReq_count = DCacheReq_count + 1;      
         end    
         if (ICacheReq) begin
            ICacheReq_count = ICacheReq_count + 1;      
         end    

         $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x",
                   DUT.c0.cycle_count,
                   PC,
                   Inst,
                   RegWrite,
                   WriteRegister,
                   WriteData,
                   MemRead,
                   MemWrite,
                   MemAddress,
                   MemDataIn);
         if (RegWrite) begin
            $fdisplay(trace_file,"REG: %d VALUE: 0x%04x",
                      WriteRegister,
                      WriteData );            
         end
         if (MemRead) begin
            $fdisplay(trace_file,"LOAD: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataOut );
         end

         if (MemWrite) begin
            $fdisplay(trace_file,"STORE: ADDR: 0x%04x VALUE: 0x%04x",
                      MemAddress, MemDataIn  );
         end
         if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", DUT.c0.cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachehit_count %d\n", DCacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachehit_count %d\n", ICacheHit_count);
            $fdisplay(sim_log_file, "SIMLOG:: dcachereq_count %d\n", DCacheReq_count);
            $fdisplay(sim_log_file, "SIMLOG:: icachereq_count %d\n", ICacheReq_count);

            $fclose(trace_file);
            $fclose(sim_log_file);
            #5;
            $finish;
         end 
      end
      
   end

   /* END DO NOT TOUCH */

   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */

   // Edit the example below. You must change the signal
   // names on the right hand side
    
   //assign PC = DUT.p0.fetch_stage.PC;
   //assign PC = DUT.p0.syn_PC;
   assign PC = {DUT.p0.\syn_PC<15> , DUT.p0.\syn_PC<14> , DUT.p0.\syn_PC<13> , 
        DUT.p0.\syn_PC<12> , DUT.p0.\syn_PC<11> , DUT.p0.\syn_PC<10> , DUT.p0.\syn_PC<9> , DUT.p0.\syn_PC<8> , 
        DUT.p0.\syn_PC<7> , DUT.p0.\syn_PC<6> , DUT.p0.\syn_PC<5> , DUT.p0.\syn_PC<4> , DUT.p0.\syn_PC<3> , 
        DUT.p0.\syn_PC<2> , DUT.p0.\syn_PC<1> , DUT.p0.\syn_PC<0> };
   
   //assign Inst = DUT.p0.fetch_stage.Instruction;
   //assign Inst = DUT.p0.syn_Inst;
   assign Inst = {DUT.p0.\syn_Inst<15> , DUT.p0.\syn_Inst<14> , DUT.p0.\syn_Inst<13> , DUT.p0.\syn_Inst<12> , DUT.p0.\syn_Inst<11> , 
        DUT.p0.\syn_Inst<10> , DUT.p0.\syn_Inst<9> , DUT.p0.\syn_Inst<8> , DUT.p0.\syn_Inst<7> , 
        DUT.p0.\syn_Inst<6> , DUT.p0.\syn_Inst<5> , DUT.p0.\syn_Inst<4> , DUT.p0.\syn_Inst<3> , 
        DUT.p0.\syn_Inst<2> , DUT.p0.\syn_Inst<1> , DUT.p0.\syn_Inst<0> };
   
   //assign RegWrite = DUT.p0.decode_stage.i_RF_bypass.writeEn;
   assign RegWrite = DUT.p0.syn_RegWrite;
   // Is register file being written to, one bit signal (1 means yes, 0 means no)

   //assign WriteRegister = DUT.p0.decode_stage.i_RF_bypass.writeRegSel;
   //assign WriteRegister = DUT.p0.syn_WriteRegister;
   assign WriteRegister = {DUT.p0.\syn_WriteRegister<2> , DUT.p0.\syn_WriteRegister<1> , DUT.p0.\syn_WriteRegister<0> };
   // The name of the register being written to. (3 bit signal)
   
   //assign WriteData = DUT.p0.decode_stage.i_RF_bypass.writeData;
   //assign WriteData = DUT.p0.syn_WriteData;
   assign WriteData = {DUT.p0.\syn_WriteData<15> , DUT.p0.\syn_WriteData<14> , DUT.p0.\syn_WriteData<13> , DUT.p0.\syn_WriteData<12> , 
        DUT.p0.\syn_WriteData<11> , DUT.p0.\syn_WriteData<10> , DUT.p0.\syn_WriteData<9> , 
        DUT.p0.\syn_WriteData<8> , DUT.p0.\syn_WriteData<7> , DUT.p0.\syn_WriteData<6> , 
        DUT.p0.\syn_WriteData<5> , DUT.p0.\syn_WriteData<4> , DUT.p0.\syn_WriteData<3> , 
        DUT.p0.\syn_WriteData<2> , DUT.p0.\syn_WriteData<1> , DUT.p0.\syn_WriteData<0> };
   // Data being written to the register. (16 bits)
   
   //assign MemRead = DUT.p0.memory_stage.Data_Cache.Rd & DUT.p0.memory_stage.Data_Cache.Done;
   assign MemRead = DUT.p0.syn_MemRead;
   // Is memory being read, one bit signal (1 means yes, 0 means no)
   
   //assign MemWrite = DUT.p0.memory_stage.Data_Cache.Wr & DUT.p0.memory_stage.Data_Cache.Done;
   assign MemWrite = DUT.p0.syn_MemWrite;
   // Is memory being written to (1 bit signal)
   
   //assign MemAddress = DUT.p0.memory_stage.XOut;
   //assign MemAddress = DUT.p0.syn_MemAddress;
   assign MemAddress = {DUT.p0.\syn_MemAddress<15> , DUT.p0.\syn_MemAddress<14> , DUT.p0.\syn_MemAddress<13> , DUT.p0.\syn_MemAddress<12> , 
        DUT.p0.\syn_MemAddress<11> , DUT.p0.\syn_MemAddress<10> , DUT.p0.\syn_MemAddress<9> , 
        DUT.p0.\syn_MemAddress<8> , DUT.p0.\syn_MemAddress<7> , DUT.p0.\syn_MemAddress<6> , 
        DUT.p0.\syn_MemAddress<5> , DUT.p0.\syn_MemAddress<4> , DUT.p0.\syn_MemAddress<3> , 
        DUT.p0.\syn_MemAddress<2> , DUT.p0.\syn_MemAddress<1> , DUT.p0.\syn_MemAddress<0> };
   // Address to access memory with (for both reads and writes to memory, 16 bits)
   
   //assign MemDataIn = DUT.p0.memory_stage.WriteData;
   //assign MemDataIn = DUT.p0.syn_MemDataIn;
   assign MemDataIn = {DUT.p0.\syn_MemDataIn<15> , DUT.p0.\syn_MemDataIn<14> , 
        DUT.p0.\syn_MemDataIn<13> , DUT.p0.\syn_MemDataIn<12> , DUT.p0.\syn_MemDataIn<11> , 
        DUT.p0.\syn_MemDataIn<10> , DUT.p0.\syn_MemDataIn<9> , DUT.p0.\syn_MemDataIn<8> , 
        DUT.p0.\syn_MemDataIn<7> , DUT.p0.\syn_MemDataIn<6> , DUT.p0.\syn_MemDataIn<5> , 
        DUT.p0.\syn_MemDataIn<4> , DUT.p0.\syn_MemDataIn<3> , DUT.p0.\syn_MemDataIn<2> , 
        DUT.p0.\syn_MemDataIn<1> , DUT.p0.\syn_MemDataIn<0> };
   // Data to be written to memory for memory writes (16 bits)
   
   //assign MemDataOut = DUT.p0.memory_stage.MemOut;
   //assign MemDataOut = DUT.p0.syn_MemDataOut;
   assign MemDataOut = {DUT.p0.\syn_MemDataOut<15> , DUT.p0.\syn_MemDataOut<14> , DUT.p0.\syn_MemDataOut<13> , 
        DUT.p0.\syn_MemDataOut<12> , DUT.p0.\syn_MemDataOut<11> , DUT.p0.\syn_MemDataOut<10> , 
        DUT.p0.\syn_MemDataOut<9> , DUT.p0.\syn_MemDataOut<8> , DUT.p0.\syn_MemDataOut<7> , 
        DUT.p0.\syn_MemDataOut<6> , DUT.p0.\syn_MemDataOut<5> , DUT.p0.\syn_MemDataOut<4> , 
        DUT.p0.\syn_MemDataOut<3> , DUT.p0.\syn_MemDataOut<2> , DUT.p0.\syn_MemDataOut<1> , 
        DUT.p0.\syn_MemDataOut<0> };
   // Data read from memory for memory reads (16 bits)

   // new added 05/03
   assign ICacheReq = 1'b0;
   // Signal indicating a valid instruction read request to cache
   // Above assignment is a dummy example
   
   assign ICacheHit = 1'b0;
   // Signal indicating a valid instruction cache hit
   // Above assignment is a dummy example

   assign DCacheReq = 1'b0;
   // Signal indicating a valid instruction data read or write request to cache
   // Above assignment is a dummy example
   //    
   assign DCacheHit = 1'b0;
   // Signal indicating a valid data cache hit
   // Above assignment is a dummy example
   
   assign Halt = DUT.p0.halt_WB;
   // Processor halted
   
   
   /* Add anything else you want here */

   
endmodule

// DUMMY LINE FOR REV CONTROL :0:
