`include "common.sv"

// 9600 Hz uart module uses 43 LE

typedef enum { STATE_0, STATE_1, STATE_2 } State;

module entry (
				 input wire clk,
				 input wire uart_data,
				 output `reg(FRAME_CNT_MAX_1 * FRAME) frame_cnt = FRAME_CNT_MAX_1 * FRAME,
				 output `reg(STATE_2) state = STATE_0,
				 output `reg(STORAGE_MAX) storage = 0,
				 output reg is_data_ready = 0
			 );

`reg(DATA_BIT_CNT_MAX) data_bit_cnt = DATA_BIT_CNT_MAX;

wire data_edge_n;

// state transition conditions
wire cond_1 = data_edge_n,	// transmission start
		 cond_2 = !frame_cnt,	// first data bit
		 cond_0 = !data_bit_cnt;	// last data bit

edge_det edge_det_ins(.clk(clk), .sgn(uart_data), .out_n(data_edge_n));

always @(posedge clk) begin
	// state values
	case(state)
		STATE_0: is_data_ready <= 0;
		STATE_1: frame_cnt <= frame_cnt ? frame_cnt - 1 : FRAME_CNT_MAX_2 * FRAME;
		STATE_2: if (frame_cnt) frame_cnt <= frame_cnt - 1;
			else begin
				frame_cnt <= FRAME_CNT_MAX_2 * FRAME;
				data_bit_cnt <= data_bit_cnt - 1;
				storage <= {uart_data, storage[`width(STORAGE_MAX)-1:1]};
			end
	endcase

	// state transitions
	case(state)
		STATE_0: if (cond_1) state <= STATE_1;
		STATE_1: if (cond_2) state <= STATE_2;
		STATE_2: if (cond_0) begin
				state <= STATE_0;
				is_data_ready <= 1;
				frame_cnt <= FRAME_CNT_MAX_1 * FRAME;
				data_bit_cnt <= DATA_BIT_CNT_MAX;
			end
	endcase
end

endmodule
