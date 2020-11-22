`include "./modules/defines.sv"
`include "./modules/int_gen.sv"
`include "./modules/edge_det.sv"
`include "./modules/sync.sv"
`include "./modules/delay.sv"

module interrupter #(parameter
										 CLK_MHZ = 100,
										 FREQ_MIN_HZ = 10_000,
										 PW_STEP_MUL = 1,
										 SKIP_CNT_MAX = 3,
										 PAR_MAX_VAL = 255,
										 ADDR_MAX = 4,
										 ADDR = 4,
										 ADDR2 = 4
										)
			 (
				 input wire clk,
				 input wire gen,
				 input wire ocd,
				 input `wire(PAR_MAX_VAL) data,
				 //input `wire(PAR_MAX_VAL) pw_par,
				 input `wire(ADDR_MAX) addr,
				 input wire en,
				 output wire out_p,
				 output wire out_n
			 );

`reg(PAR_MAX_VAL) storage_fr = 0, storage_pw = 0;

// cdc synchronizer
sync #(.WIDTH(1))
		 s1(
			 .clk(clk),
			 .data_raw(ocd),
			 .data(ocd_s)
		 );

int_gen #(.CLK_MHZ(CLK_MHZ),
					.FREQ_MIN_HZ(FREQ_MIN_HZ),
					.PW_STEP_MUL(PW_STEP_MUL),
					.PAR_MAX_VAL(PAR_MAX_VAL))
				i(
					.clk(clk),
					.freq_par(storage_fr),
					.pw_par(storage_pw),
					.out(int_wire)
				);

edge_det gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p), .out(gen_edge));

// ff delay matching
delay #(.WIDTH(1))
			d1(
				.clk(clk),
				.data_raw(gen),
				.data(gen_del)
			);

typedef enum { STATE_0, STATE_1 } State;

`reg(STATE_1) state = STATE_0;
`reg(SKIP_CNT_MAX) skip_cnt = SKIP_CNT_MAX;
reg ff = 0;



// state transition conditions
wire cond_1 = ocd_s,
		 cond_0 = !skip_cnt;

always @(posedge clk) if (en && (addr == ADDR)) storage_fr <= data;
always @(posedge clk) if (en && (addr == ADDR2)) storage_pw <= data;

always @(posedge clk) begin
	// state values
	case(state)
		STATE_0: if (gen_edge_p) ff <= !int_wire;
		STATE_1: if (gen_edge && skip_cnt) begin
				ff <= 0;
				if (gen) skip_cnt <= skip_cnt - 1;
			end
	endcase

	// state transitions
	case(state)
		STATE_0: if (cond_1) state <= STATE_1;
		STATE_1: if (cond_0) begin
				state <= STATE_0;
				skip_cnt <= SKIP_CNT_MAX;
			end
	endcase
end

assign out_p = ff && gen_del,
			 out_n = ff && ~gen_del;

endmodule
