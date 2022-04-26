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
	wire victimway_in, victimway_out;
	wire victim;
	wire activeway;
	
	// LRU Cache increase CPI, so excluded for Phase 3
	/*
	// extra credit
	wire [255:0] lru_out, lru_in;
	wire [255:0] lru_base, lru_mask_0, lru_mask_1, lru_mask_2, lru_mask_3, lru_mask_4, lru_mask_5, lru_mask_6, lru_mask_7;
	wire lru_bit;
	*/
	
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
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
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
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
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
	
	assign hit = c0_hit | c1_hit;
	
	assign activeway = ((c0_valid & c0_hit) | (c1_valid & c1_hit)) ? (c1_valid & c1_hit) : victim;
	
	assign dirty = activeway ? c1_dirty : c0_dirty;
	assign valid = activeway ? c1_valid : c0_valid;
	assign tag_out = activeway ? c1_tag_out : c0_tag_out;
	assign c_data_out = activeway ? c1_data_out : c0_data_out;

	assign c0_write = activeway ? 1'b0 : write;
	assign c1_write = activeway ? write : 1'b0;
	
	// sudo-random replacement
	dff victimway(
		.q(victimway_out),
		.d(victimway_in),
		.clk(clk),
		.rst(rst)
	);
	assign victimway_in = Done ? ~victimway_out : victimway_out;
	
	/*
	Policy to choose victim:
		When installing a line after a cache miss, install in an invalid block if possible. 
		If both ways are invalid, install in way zero.
		If both ways are valid, and a block must be victimized, 
		use victimway (after already being inverted for this access) to indicate which way to use.
	*/
	assign victim = (c0_valid & c1_valid) ? ~victimway_out : c0_valid;

	// LRU Cache increase CPI, so excluded for Phase 3
	//assign victim = (c0_valid & c1_valid) ? lru_bit : c0_valid;
	
	assign c_data_in = (write & ~comp) ? m_data_out : DataIn;
	assign DataOut = c_data_out;
	assign err = ((Rd | Wr) & (err_c0 | err_c1)) | err_mem | err_fsm;
	
	// LRU Cache increase CPI, so excluded for Phase 3
	/*
	// extra credit: LRU Cache
	dff LRU[255:0](
		.q(lru_out),
		.d(lru_in),
		.clk(clk),
		.rst(rst)
	);
	
	// 8:256 decoder, equivalent to "assign lru_mask_7 = 1 << Addr[10:3];"
	assign lru_base = {{255{1'b0}}, 1'b1};
	assign lru_mask_0 = Addr[3] ? (lru_base << 1) : lru_base;
	assign lru_mask_1 = Addr[4] ? (lru_mask_0 << 2) : lru_mask_0;
	assign lru_mask_2 = Addr[5] ? (lru_mask_1 << 4) : lru_mask_1;
	assign lru_mask_3 = Addr[6] ? (lru_mask_2 << 8) : lru_mask_2;
	assign lru_mask_4 = Addr[7] ? (lru_mask_3 << 16) : lru_mask_3;
	assign lru_mask_5 = Addr[8] ? (lru_mask_4 << 32) : lru_mask_4;
	assign lru_mask_6 = Addr[9] ? (lru_mask_5 << 64) : lru_mask_5;
	assign lru_mask_7 = Addr[10] ? (lru_mask_6 << 128) : lru_mask_6;
	
	assign lru_bit = |(lru_out & lru_mask_7);
	
	assign lru_in = Done ? (activeway ? ((~lru_mask_7) & lru_out) : (lru_mask_7 | lru_out)) : lru_out;
	*/
	
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
