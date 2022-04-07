/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   output wire        err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   
   	wire [4:0] tag_out;
	wire [15:0] c_data_out;
	wire hit, dirty, valid;
	wire enable;
	wire [15:0] m_data_out;
	wire comp, write, valid_in;
	wire stall;
	wire [15:0] m_addr;
	wire wr, rd;
	wire [2:0] offset;
	wire [15:0] c_data_in;
	wire err_c0, err_mem, err_fsm;
	
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out),
                          .data_out             (c_data_out),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (err_c0),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (offset),
                          .data_in              (c_data_in),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));

   four_bank_mem mem(// Outputs
                     .data_out          (m_data_out),
                     .stall             (stall),
                     .busy              (),				// not used
                     .err               (err_mem),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (m_addr),
                     .data_in           (c_data_out),
                     .wr                (wr),
                     .rd                (rd));
   
	// your code here	
	cache_FSM cache_controller(
		.Done(Done),
		.Stall(Stall),
		.CacheHit(CacheHit),
		.err(err_fsm),
		.enable(enable),
		.offset(offset),
		.comp(comp),
		.write(write),
		.valid_in(valid_in),
		.addr(m_addr),
		.wr(wr),
		.rd(rd),
		.Rd(Rd),
		.Wr(Wr),
		.tag_in(Addr[15:11]),
		.index(Addr[10:3]),
		.offset_in(Addr[2:0]),
		.clk(clk),
		.rst(rst),
		.hit(hit),
		.dirty(dirty),
		.valid(valid),
		.tag_out(tag_out),
		.stall(stall)
	);
	
	assign c_data_in = comp ? DataIn : m_data_out;
	assign DataOut = c_data_out;
	assign err = err_c0 | err_mem | err_fsm;

endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
