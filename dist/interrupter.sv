`include "./modules/defines.sv"
module int_gen_160494775758309523168418574268 #(parameter
			 CLK_MHZ = 100,
			 PAR_MAX_VAL = 255
																							 )
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) freq_par,
				 input `wire(PAR_MAX_VAL) pw_par,
				 output wire out
			 );

localparam k = 100;	// for pw_par in microseconds

`reg(100 * CLK_MHZ) cnt = 0; // 500_000

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else begin
		case(freq_par)
			`lookup
		endcase
	end
end

assign out = cnt < k * pw_par;

endmodule

	module edge_det_160494775758309523168418574268
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



	module sync_160494775758309523168418574268 #(parameter
			WIDTH = 1
																							)
	(
		input wire clk,
		input wire[WIDTH-1:0] data_raw,
		output reg[WIDTH-1:0] data = 0
	);

reg[WIDTH-1:0] internal = 0;

always @(posedge clk)
	{ data, internal } <= { internal, data_raw };

endmodule


	module interrupter #(parameter
											 SKIP_CNT_MAX = 3
											)
	(
		input wire clk,
		input wire gen,
		input wire ocd,
		output wire out
	);

int_gen_160494775758309523168418574268 i(
																				 .clk(clk),
																				 .freq_par(8'd1),	// 100 -> 1 MHz -> 1us
																				 .pw_par(8'd50),
																				 .out(int_wire)
																			 );

edge_det_160494775758309523168418574268 gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p));

sync_160494775758309523168418574268 gen_d(
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
