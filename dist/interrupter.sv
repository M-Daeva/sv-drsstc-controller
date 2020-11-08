`include "./modules/defines.sv"
module int_gen_160486547415602987277149564336 #(parameter
			 CLK_MHZ = 100,
			 PAR_MAX_VAL = 255
																							 )
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) freq_par,
				 input `wire(PAR_MAX_VAL) pw_par,
				 output wire out
			 );

localparam k = 100;

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

	module edge_det_160486547415602987277149564336
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



	module sync_160486547415602987277149564336 #(parameter
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

int_gen_160486547415602987277149564336 i(
																				 .clk(clk),
																				 .freq_par(8'd4),	// 100 -> 1 MHz -> 1us
																				 .pw_par(8'd13),
																				 .out(int_wire)
																			 );

edge_det_160486547415602987277149564336 gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p));

sync_160486547415602987277149564336 gen_d(
																			.clk(clk),
																			.data_raw(gen),
																			.data(gen_del)
																		);

always @(posedge clk) if (gen_edge_p) ff <= !int_wire;

assign out = ff && gen_del;

endmodule
