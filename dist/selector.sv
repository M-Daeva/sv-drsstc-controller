`include "./modules/defines.sv"
module edge_det_1623504042553017272534662432726
			 (
				 input wire clk,
				 input wire sgn,
				 output wire out_p,
				 output wire out_n,
				 output wire out
			 );

reg sgn_pre = 0;

assign out_p = sgn && ~sgn_pre,
			 out_n = ~sgn && sgn_pre,
			 out = sgn ^ sgn_pre;

always @(posedge clk)
	if (out) sgn_pre <= sgn;

endmodule


	module selector #(parameter
										CLK_MHZ = 100,
										PERIODS_TO_SWITCH = 4,
										RESET_TIMEOUT_US = 4
									 )
	(
		input wire clk,
		input wire gen,
		input wire fb,
		output wire out
	);

typedef enum { STATE_0, STATE_1 } State;

localparam TIMEOUT_CNT_MAX = CLK_MHZ * PERIODS_TO_SWITCH;

`reg(TIMEOUT_CNT_MAX) timeout_cnt = TIMEOUT_CNT_MAX - 1;
`reg(PERIODS_TO_SWITCH) per_to_sw_cnt = PERIODS_TO_SWITCH;
`reg(STATE_1) state = STATE_0;

edge_det_1623504042553017272534662432726 edge_det_gen(.clk(clk), .sgn(gen), .out_n(gen_edge_n));
edge_det_1623504042553017272534662432726 edge_det_fb(.clk(clk), .sgn(fb), .out_n(fb_edge_n));

// state transition conditions
wire cond_1 = !per_to_sw_cnt && fb_edge_n,	// some gen periods passed
		 cond_0 = !timeout_cnt && !gen;	// no signal on fb input

always @(posedge clk) begin
	// state values
	case(state)
		STATE_0: if (gen_edge_n) per_to_sw_cnt <= per_to_sw_cnt ? per_to_sw_cnt - 1 : PERIODS_TO_SWITCH;
		STATE_1: if (fb) timeout_cnt <= TIMEOUT_CNT_MAX - 1;
			else if (timeout_cnt) timeout_cnt <= timeout_cnt - 1;
	endcase

	// state transitions
	case(state)
		STATE_0: if (cond_1) state <= STATE_1;
		STATE_1: if (cond_0) begin
				state <= STATE_0;
				timeout_cnt <= TIMEOUT_CNT_MAX - 1;
			end
	endcase
end

assign out = state == STATE_0 ? gen : fb;

endmodule
