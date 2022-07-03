/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module critical_mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err, CRI_out, ending,
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
   
   output wire 		  CRI_out;
   output wire 		  ending;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   
    wire [4:0] tag_out, c0_tag_out, c1_tag_out;
	wire [15:0] c_data_out, c0_data_out, c1_data_out;
	wire hit, c0_hit, c1_hit;
	wire dirty, c0_dirty, c1_dirty;
	wire valid, c0_valid, c1_valid;
	wire enable;
	wire [15:0] m_data_out;
	wire comp;
	wire write, c0_write, c1_write;
	wire valid_in;
	wire stall;
	wire [15:0] m_addr;
	wire wr, rd;
	wire [2:0] offset;
	wire [15:0] c_data_in;
	
	wire err_c0, err_c1, err_mem, err_fsm;
	wire victim;
	wire activeway;
	
	// extra credit
	wire [255:0] lru_out, lru_in;
	wire [255:0] lru_base, lru_mask_0, lru_mask_1, lru_mask_2, lru_mask_3, lru_mask_4, lru_mask_5, lru_mask_6, lru_mask_7;
	wire lru_bit;
	
	wire latch_inputs;
	wire [15:0] Addr_latch;
    wire [15:0] DataIn_latch;
    wire        Rd_latch;
    wire        Wr_latch;
	
	wire [15:0] Addr_eff;
    wire [15:0] DataIn_eff;
    wire        Rd_eff;
    wire        Wr_eff;
	
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (c0_tag_out),
                          .data_out             (c0_data_out),
                          .hit                  (c0_hit),
                          .dirty                (c0_dirty),
                          .valid                (c0_valid),
                          .err                  (err_c0),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr_eff[15:11]),
                          .index                (Addr_eff[10:3]),
                          .offset               (offset),
                          .data_in              (c_data_in),
                          .comp                 (comp),
                          .write                (c0_write),
                          .valid_in             (valid_in));
   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (c1_tag_out),
                          .data_out             (c1_data_out),
                          .hit                  (c1_hit),
                          .dirty                (c1_dirty),
                          .valid                (c1_valid),
                          .err                  (err_c1),
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr_eff[15:11]),
                          .index                (Addr_eff[10:3]),
                          .offset               (offset),
                          .data_in              (c_data_in),
                          .comp                 (comp),
                          .write                (c1_write),
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
	critical_cache_FSM cache_controller(
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
		.Rd(Rd_eff),
		.Wr(Wr_eff),
		.tag_in(Addr_eff[15:11]),
		.index(Addr_eff[10:3]),
		.offset_in(Addr_eff[2:0]),
		.clk(clk),
		.rst(rst),
		.hit(hit),
		.dirty(dirty),
		.valid(valid),
		.tag_out(tag_out),
		.stall(stall),
		.CRI_out(CRI_out),
		.latch_inputs(latch_inputs),
		.ending(ending)
	);
	
	assign hit = c0_hit | c1_hit;
	
	assign activeway = ((c0_valid & c0_hit) | (c1_valid & c1_hit)) ? (c1_valid & c1_hit) : victim;
	
	assign dirty = activeway ? c1_dirty : c0_dirty;
	assign valid = activeway ? c1_valid : c0_valid;
	assign tag_out = activeway ? c1_tag_out : c0_tag_out;
	assign c_data_out = activeway ? c1_data_out : c0_data_out;

	assign c0_write = activeway ? 1'b0 : write;
	assign c1_write = activeway ? write : 1'b0;
	
	assign victim = (c0_valid & c1_valid) ? lru_bit : c0_valid;
	
	assign c_data_in = (write & ~comp) ? m_data_out : DataIn_eff;
	assign DataOut = CacheHit ? c_data_out : m_data_out;
	assign err = ((Rd_eff | Wr_eff) & (err_c0 | err_c1)) | err_mem | err_fsm;
	
	// extra credit
	dff LRU[255:0](
		.q(lru_out),
		.d(lru_in),
		.clk(clk),
		.rst(rst)
	);
	
	// 8:256 decoder, equivalent to "assign lru_mask_7 = 1 << Addr[10:3];"
	assign lru_base = {{255{1'b0}}, 1'b1};
	assign lru_mask_0 = Addr_eff[3] ? (lru_base << 1) : lru_base;
	assign lru_mask_1 = Addr_eff[4] ? (lru_mask_0 << 2) : lru_mask_0;
	assign lru_mask_2 = Addr_eff[5] ? (lru_mask_1 << 4) : lru_mask_1;
	assign lru_mask_3 = Addr_eff[6] ? (lru_mask_2 << 8) : lru_mask_2;
	assign lru_mask_4 = Addr_eff[7] ? (lru_mask_3 << 16) : lru_mask_3;
	assign lru_mask_5 = Addr_eff[8] ? (lru_mask_4 << 32) : lru_mask_4;
	assign lru_mask_6 = Addr_eff[9] ? (lru_mask_5 << 64) : lru_mask_5;
	assign lru_mask_7 = Addr_eff[10] ? (lru_mask_6 << 128) : lru_mask_6;
	
	assign lru_bit = |(lru_out & lru_mask_7);
	
	assign lru_in = Done ? (activeway ? ((~lru_mask_7) & lru_out) : (lru_mask_7 | lru_out)) : lru_out;
	
	dff addr_latch [15:0](
		.q(Addr_latch),
		.d(latch_inputs ? Addr : Addr_latch),
		.clk(clk),
		.rst(rst)
	);
	
	dff datain_latch [15:0](
		.q(DataIn_latch),
		.d(latch_inputs ? DataIn : DataIn_latch),
		.clk(clk),
		.rst(rst)
	);
	
	dff rd_latch(
		.q(Rd_latch),
		.d(latch_inputs ? Rd : Rd_latch),
		.clk(clk),
		.rst(rst)
	);
	
	dff wr_latch(
		.q(Wr_latch),
		.d(latch_inputs ? Wr : Wr_latch),
		.clk(clk),
		.rst(rst)
	);
	
	assign Addr_eff = latch_inputs ? Addr : Addr_latch;
	assign DataIn_eff = latch_inputs ? DataIn : DataIn_latch;
	assign Rd_eff = latch_inputs ? Rd : Rd_latch;
	assign Wr_eff = latch_inputs ? Wr : Wr_latch;

	
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
