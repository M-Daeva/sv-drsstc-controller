`include "./modules/defines.sv"
module int_gen_162350404254708459262516540007 #(parameter
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

localparam K1 = 20,
					 K2 = 15,
					 K3 = 9,
					 CNT_MAX = (1 << K1) + (PAR_MAX_VAL << K2) - 1;

`reg(CNT_MAX) cnt = 0;

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else cnt <= (1 << K1) + (freq_par << K2) - 1;
end

assign out = cnt < (pw_par << K3);

endmodule

	module edge_det_162350404254708459262516540007
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



	module sync_162350404254708459262516540007 #(parameter
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



	module delay_162350404254708459262516540007 #(parameter
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

`reg(PAR_MAX_VAL) storage_fr = 0, storage_pw = 0;	// 0 - 95.4 Hz, 8 - 40.96 us

// cdc synchronizer
sync_162350404254708459262516540007 #(.WIDTH(1))
																		s1(
																			.clk(clk),
																			.data_raw(ocd),
																			.data(ocd_s)
																		);

int_gen_162350404254708459262516540007 #(.CLK_MHZ(CLK_MHZ),
																			 .FREQ_MIN_HZ(FREQ_MIN_HZ),
																			 .PW_STEP_MUL(PW_STEP_MUL),
																			 .PAR_MAX_VAL(PAR_MAX_VAL))
																			 i(
																				 .clk(clk),
																				 .freq_par(storage_fr),
																				 .pw_par(storage_pw),
																				 .out(int_wire)
																			 );

edge_det_162350404254708459262516540007 gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p), .out(gen_edge));

// ff delay_162350404254708459262516540007 matching
delay_162350404254708459262516540007 #(.WIDTH(1))
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

assign out_p = ~ff && gen_del,	// due to mic4423 inverted inputs
			 out_n = ~ff && ~gen_del;

endmodule
