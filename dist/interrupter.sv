`include "./modules/defines.sv"
module pwm_160478825394503044288640336992 #(parameter
			 CLK_MHZ = 50,
			 FREQ_KHZ = 400,
			 DUTY = 40
																					 )
			 (
				 input wire clk,
				 input wire rst,
				 output wire out
			 );

localparam cnt_max = `div(1000 * CLK_MHZ, FREQ_KHZ),
					 cnt_duty = `div(DUTY * cnt_max, 100);

`reg(cnt_max) cnt = cnt_max - 1;

assign out = cnt < cnt_duty;

always @(posedge clk)
	cnt <= (rst || !cnt) ? cnt_max - 1 : cnt - 1;

endmodule

	module edge_det_160478825394503044288640336992
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



	module sync_160478825394503044288640336992 #(parameter
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


	module interrupter (
		input wire clk,
		input wire gen,
		output wire out
	);

reg ff = 0;

pwm_160478825394503044288640336992 #(.CLK_MHZ(100),
																		 .FREQ_KHZ(25),
																		 .DUTY(50)
																		)
																	 inter
																	 (
																		 .clk(clk),
																		 .rst(1'b0),
																		 .out(pwm_wire)
																	 );

edge_det_160478825394503044288640336992 gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p));

sync_160478825394503044288640336992 gen_d(
																			.clk(clk),
																			.data_raw(gen),
																			.data(gen_del)
																		);

always @(posedge clk) if (gen_edge_p) ff <= !pwm_wire;

assign out = ff && gen_del;

endmodule
