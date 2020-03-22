`include "modules/include_all.sv"

localparam 	DELAY = 50,
						PERIOD = 20,
						EDGE_CNT_MAX = 3;

typedef enum { STATE_0, STATE_1, STATE_2, STATE_3 } State;

module entry (
				 input wire clk,
				 input wire data_raw,
				 output wire data,
				 output `reg(STATE_3) state = STATE_0,
				 output `reg(DELAY) tmr = DELAY - 1,
				 output wire uart_clk,
				 output wire uart_clk_2
			 );

`reg(EDGE_CNT_MAX) 	edge_cnt = 0;

wire	data_edge,
		 data_edge_p;

wire cond_1 = data_edge_p,
		 cond_2 = data_edge_p && (edge_cnt == EDGE_CNT_MAX - 1),
		 cond_3 = !tmr,
		 cond_0 = !tmr;

//pwm #(.clk_mhz(100), .freq_khz(500), .duty(25)) pwm_ins(.clk(clk), .rst(1'd0), .out(uart_clk));
edge_det edge_det_ins(.clk(clk), .sgn(data), .out_p(data_edge_p), .out(data_edge));
// clock domain crossing double trigger synchronizer: data_raw -> data
sync sync_ins(.clk(clk), .data_raw(data_raw), .data(data));

always @(posedge clk) begin
	// data edge detector
	if (data_edge_p) edge_cnt <= edge_cnt + 1;

	// timer
	case(state)
		STATE_2: tmr <= (!tmr) ? PERIOD - 1 : tmr - 1;
		STATE_3: tmr <= (data_edge || !tmr) ? PERIOD - 1 : tmr - 1;
	endcase

	// FSM
	case(state)
		STATE_0: if (cond_1) state <= STATE_1;
		STATE_1: if (cond_2) state <= STATE_2;
		STATE_2: if (cond_3) state <= STATE_3;
		STATE_3: if (cond_0) state <= STATE_0;
	endcase
end

endmodule
