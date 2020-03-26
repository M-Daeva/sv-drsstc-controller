`include "common.sv"



typedef enum { STATE_0, STATE_1, STATE_2 } State;

module entry (
				 input wire clk,
				 input wire uart_clk,
				 input wire uart_data,
				 output `reg(EDGE_CNT_MAX_1 * FRAME) edge_cnt = EDGE_CNT_MAX_1 * FRAME,
				 output `reg(STATE_2) state = STATE_0,
				 output `reg(STOR_MAX_VAL) storage_1 = 0,
				 output `reg(STOR_MAX_VAL) storage_2 = 0
			 );



wire data_edge_n;

wire cond_1 = data_edge_n,
		 cond_2 = !edge_cnt,
		 cond_0 = storage_1 == 5;

edge_det edge_det_ins(.clk(clk), .sgn(uart_data), .out_n(data_edge_n));

always @(posedge clk) begin
	// uart_clk
	case(state)
		STATE_1: edge_cnt <= edge_cnt ? edge_cnt - 1 : EDGE_CNT_MAX_2 * FRAME;
		STATE_2: edge_cnt <= edge_cnt ? edge_cnt - 1 : EDGE_CNT_MAX_2 * FRAME;
	endcase

	// FSM
	case(state)
		STATE_0: if (cond_1) state <= STATE_1;
		STATE_1: if (cond_2) state <= STATE_2;
		STATE_2: if (cond_0) state <= STATE_0;
	endcase
end

/*
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
*/
endmodule
