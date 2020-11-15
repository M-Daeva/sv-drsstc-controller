`include "./modules/defines.sv"
module int_gen_160546390607402675699788025321 #(parameter
			 CLK_MHZ = 100,
			 FREQ_MIN_HZ = 10_000,
			 PW_STEP_MUL = 1,
			 PAR_MAX_VAL = 255
																							 )
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) freq_par,
				 input `wire(PAR_MAX_VAL) pw_par,
				 output wire out
			 );

localparam FREQ_RATIO = `div(1_000_000 * CLK_MHZ, FREQ_MIN_HZ);

`reg(FREQ_RATIO) cnt = 0;

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else begin
		case(freq_par)
			`lookup
		endcase
	end
end

assign out = cnt < PW_STEP_MUL * pw_par;

endmodule

	module edge_det_160546390607402675699788025321
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



	module sync_160546390607402675699788025321 #(parameter
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



	module delay_160546390607402675699788025321 #(parameter
			WIDTH = 2
																							 )
	(
		input wire clk,
		input wire data_raw,
		output wire data
	);

reg[WIDTH-1:0] internal = 0;

always @(posedge clk) begin
	if (WIDTH == 1) internal <= data_raw;
	else internal <= { data_raw, internal[WIDTH-1:1] };
end

assign data = (WIDTH == 1) ? internal : internal[0];

endmodule


	module interrupter #(parameter
											 CLK_MHZ = 100,
											 FREQ_MIN_HZ = 10_000,
											 PW_STEP_MUL = 1,
											 SKIP_CNT_MAX = 3,
											 PAR_MAX_VAL = 255
											)
	(
		input wire clk,
		input wire gen,
		input wire ocd,
		input `wire(PAR_MAX_VAL) freq_par,
		input `wire(PAR_MAX_VAL) pw_par,
		output wire out_p,
		output wire out_n
	);

// cdc synchronizer
sync_160546390607402675699788025321 #(.WIDTH(1))
																		s1(
																			.clk(clk),
																			.data_raw(ocd),
																			.data(ocd_s)
																		);

int_gen_160546390607402675699788025321 #(.CLK_MHZ(CLK_MHZ),
																			 .FREQ_MIN_HZ(FREQ_MIN_HZ),
																			 .PW_STEP_MUL(PW_STEP_MUL),
																			 .PAR_MAX_VAL(PAR_MAX_VAL))
																			 i(
																				 .clk(clk),
																				 .freq_par(freq_par),
																				 .pw_par(pw_par),
																				 .out(int_wire)
																			 );

edge_det_160546390607402675699788025321 gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p));

// ff delay_160546390607402675699788025321 matching
delay_160546390607402675699788025321 #(.WIDTH(1))
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

assign out_p = ff && gen_del,
			 out_n = ff && ~gen_del;

endmodule
