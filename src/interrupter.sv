`include "./modules/defines.sv"
`include "./modules/int_gen.sv"
`include "./modules/edge_det.sv"
`include "./modules/sync.sv"

module interrupter #(parameter
										 SKIP_CNT_MAX = 3
										)
			 (
				 input wire clk,
				 input wire gen,
				 input wire ocd,
				 output wire out
			 );

int_gen i(
					.clk(clk),
					.freq_par(8'd1),	// 100 -> 1 MHz -> 1us
					.pw_par(8'd50),
					.out(int_wire)
				);

edge_det gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p));

sync gen_d(
			 .clk(clk),
			 .data_raw(gen),
			 .data(gen_del)
		 );

typedef enum { STATE_0, STATE_1 } State;

`reg(STATE_1) state = STATE_0;
`reg(SKIP_CNT_MAX) skip_cnt = SKIP_CNT_MAX;
reg ff = 0;

// state transition conditions
wire cond_1 = ocd,
		 cond_0 = !skip_cnt;

always @(posedge clk) begin
	// state values
	case(state)
		STATE_0: if (gen_edge_p) ff <= !int_wire;
		STATE_1: if (gen_edge_p && skip_cnt) begin
				ff <= 0;
				skip_cnt <= skip_cnt - 1;
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

assign out = ff && gen_del;

endmodule
