/*
	CS/ECE 552 Spring '22

	Filename        : cache_FSM.v
	Description     : This is the cache controller FSM.
*/
module cache_FSM(
	// Outputs
	Done, Stall, CacheHit, err,
	enable, offset, comp, write, valid_in,
	addr, wr, rd, set_critical,
	// Inputs
	Rd, Wr, tag_in, index, offset_in, clk, rst,
	hit, dirty, valid, tag_out, stall
	);
	
	input Rd;
	input Wr;
	input [4:0] tag_in;
	input [7:0] index;
	input [2:0] offset_in;
	input clk;
	input rst;
	input hit;
	input dirty;
	input valid;
	input [4:0] tag_out;
	input stall;
	
	output reg Done;
	output reg Stall;
	output reg CacheHit;
	output reg err;
	output reg enable;
	output reg [2:0] offset;
	output reg comp;
	output reg write;
	output reg valid_in;
	output reg [15:0] addr;
	output reg wr;
	output reg rd;
	
	output reg set_critical;
	
	// valid states
	localparam IDLE = 4'b0000;
	localparam WB0 = 4'b0001;
	localparam WB1 = 4'b0010;
	localparam WB2 = 4'b0011;
	localparam WB3 = 4'b0100;
	localparam ALLO0 = 4'b0101;
	localparam ALLO1 = 4'b0110;
	localparam ALLO2 = 4'b0111;
	localparam ALLO3 = 4'b1000;
	localparam ALLO4 = 4'b1001;
	localparam ALLO5 = 4'b1010;
	localparam RDDONE = 4'b1011;
	localparam WRDONE = 4'b1100;
	
	// state reg
	wire [3:0] state;
	reg [3:0] nxt_state;
	dff state_reg [3:0](
		.q(state),
		.d(nxt_state),
		.clk(clk),
		.rst(rst)
	);
	
	wire critical_out;
	reg clr_critical;
	dff critical(
		.q(critical_out),
		.d(set_critical ? 1'b1 : clr_critical ? 1'b0 : critical_out),
		.clk(clk),
		.rst(rst)
	);
	
	// FSM
	always @(*) begin
		Done = 1'b0;
		Stall = 1'b1;
		CacheHit = 1'b0;
		err = 1'b0;
		enable = 1'b1;
		offset = 3'b000;
		comp = 1'b0;
		write = 1'b0;
		valid_in = 1'b0;
		addr = 16'h0000;
		wr = 1'b0;
		rd = 1'b0;
		set_critical = 1'b0;
		clr_critical = 1'b0;
		nxt_state = state;
		
		case(state)
			IDLE: begin
				nxt_state = (Rd | Wr) ? ((hit & valid) ? IDLE : (~hit & valid & dirty) ? WB0 : ALLO0) : IDLE;
				comp = Rd | Wr;
				offset = offset_in;
				write = Wr;
				Done = (Rd | Wr) & (hit & valid);
				CacheHit = hit & valid;
				Stall = (Rd | Wr) & ~(hit & valid);
			end
			
			WB0: begin
				nxt_state = stall ? WB0 : WB1;
				wr = 1'b1;
				addr = {tag_out, index, 3'b000};
				offset = 3'b000;
			end
			
			WB1: begin
				nxt_state = stall ? WB1 : WB2;
				wr = 1'b1;
				addr = {tag_out, index, 3'b010};
				offset = 3'b010;
			end
			
			WB2: begin
				nxt_state = stall ? WB2 : WB3;
				wr = 1'b1;
				addr = {tag_out, index, 3'b100};
				offset = 3'b100;
			end
			
			WB3: begin
				nxt_state = stall ? WB3 : ALLO0;
				wr = 1'b1;
				addr = {tag_out, index, 3'b110};
				offset = 3'b110;
			end
			
			ALLO0: begin
				nxt_state = stall ? ALLO0 : ALLO1;
				rd = 1'b1;
				//addr = {tag_in, index, 3'b000};
				addr = {tag_in, index, offset_in};
			end
			
			ALLO1: begin
				nxt_state = stall ? ALLO1 : ALLO2;
				rd = 1'b1;
				addr = {tag_in, index, (offset_in == 3'b000) ? 3'b010 :
									   (offset_in == 3'b010) ? 3'b100 :
									   (offset_in == 3'b100) ? 3'b110 :
									   3'b000};
			end
			
			ALLO2: begin
				nxt_state = stall ? ALLO2 : ALLO3;
				write = 1'b1;
				rd = 1'b1;
				addr = {tag_in, index, (offset_in == 3'b000) ? 3'b100 :
									   (offset_in == 3'b010) ? 3'b110 :
									   (offset_in == 3'b100) ? 3'b000 :
									   3'b010};
				offset = offset_in;
				//Done = Rd;
				set_critical = 1'b1;
			end
			
			ALLO3: begin
				nxt_state = stall ? ALLO3 : ALLO4;
				write = 1'b1;
				rd = 1'b1;
				addr = {tag_in, index, (offset_in == 3'b000) ? 3'b110 :
									   (offset_in == 3'b010) ? 3'b000 :
									   (offset_in == 3'b100) ? 3'b010 :
									   3'b100};
				offset = (offset_in == 3'b000) ? 3'b010 :
					     (offset_in == 3'b010) ? 3'b100 :
					     (offset_in == 3'b100) ? 3'b110 :
						 3'b000;
				//Stall = critical_out;
			end
			
			ALLO4: begin
				nxt_state = ALLO5;
				write = 1'b1;
				offset = (offset_in == 3'b000) ? 3'b100 :
						 (offset_in == 3'b010) ? 3'b110 :
						 (offset_in == 3'b100) ? 3'b000 :
						 3'b010;
				//Stall = critical_out;
			end
			
			ALLO5: begin
				nxt_state = Wr ? WRDONE : RDDONE;
				write = 1'b1;
				valid_in = 1'b1;
				offset = (offset_in == 3'b000) ? 3'b110 :
						 (offset_in == 3'b010) ? 3'b000 :
						 (offset_in == 3'b100) ? 3'b010 :
						 3'b100;
				//Stall = critical_out;
				clr_critical = 1'b1;
			end
			
			RDDONE: begin
				nxt_state = IDLE;
				Done = Rd;
				comp = 1'b1;
				offset = offset_in;
			end

			WRDONE: begin
				nxt_state = IDLE;
				Done = Wr;
				comp = 1'b1;
				write = 1'b1;
				offset = offset_in;
			end
			
			default: begin
				err = 1'b1;
				enable = 1'b1;
			end
		endcase
	end

endmodule
