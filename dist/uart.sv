`include "./modules/defines.sv"
module edge_det_160486547416805405059108529866
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


	/*
	0 - ref_gen
	1 - phase_shift
	2 - ocd_lvl
	3 - inter_freq
	4 - inter_duty
	*/

	typedef enum { CONF_PAR_[5] } Conf_par;

module uart #(parameter
							CONF_PAR_MAX = 255,
							FRAME_CNT_MAX_1 = 3 * 52,
							FRAME_CNT_MAX_2 = 2 * 52,
							DATA_BIT_CNT_MAX = 7
						 )
			 (
				 input wire clk,
				 input wire uart_data,
				 output `reg_2d(sh_reg, CONF_PAR_MAX, CONF_PAR_4)
				 //output `reg(CONF_PAR_MAX) storage = 0,
				 //output `reg(STATE_2) state = STATE_0
			 );

// initializing sh_reg with zeroes
initial for(int i = 0; i <= CONF_PAR_4; i++) sh_reg[i] = 0;

typedef enum { STATE_[3] } State;

`reg(FRAME_CNT_MAX_1) frame_cnt = FRAME_CNT_MAX_1;
`reg(STATE_2) state = STATE_0;
`reg(DATA_BIT_CNT_MAX) data_bit_cnt = DATA_BIT_CNT_MAX;
`reg(CONF_PAR_4) conf_par_cnt = CONF_PAR_4;
`reg(CONF_PAR_MAX) storage = 0;

// state transition conditions
wire cond_1 = data_edge_n,	// transmission start
		 cond_2 = !frame_cnt,	// first data bit
		 cond_0 = !data_bit_cnt;	// last data bit

edge_det_160486547416805405059108529866 uart_n(.clk(clk), .sgn(uart_data), .out_n(data_edge_n));

always @(posedge clk) begin
	// state values
	case(state)
		STATE_1: frame_cnt <= frame_cnt ? frame_cnt - 1 : FRAME_CNT_MAX_2;
		STATE_2: if (frame_cnt) frame_cnt <= frame_cnt - 1;
			else begin
				frame_cnt <= FRAME_CNT_MAX_2;
				data_bit_cnt <= data_bit_cnt - 1;
				storage <= {uart_data, storage[`width(CONF_PAR_MAX)-1:1]};
			end
	endcase

	// state transitions
	case(state)
		STATE_0: if (cond_1) state <= STATE_1;
		STATE_1: if (cond_2) begin
				state <= STATE_2;
				storage <= {uart_data, storage[`width(CONF_PAR_MAX)-1:1]};
			end
		STATE_2: if (cond_0) begin
				state <= STATE_0;
				sh_reg[conf_par_cnt] <= storage;
				conf_par_cnt <= conf_par_cnt ? conf_par_cnt - 1 : CONF_PAR_4;
				frame_cnt <= FRAME_CNT_MAX_1;
				data_bit_cnt <= DATA_BIT_CNT_MAX;
			end
	endcase
end

endmodule
