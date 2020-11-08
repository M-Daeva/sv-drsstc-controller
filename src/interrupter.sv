`include "./modules/defines.sv"
`include "./modules/int_gen.sv"
`include "./modules/edge_det.sv"
`include "./modules/sync.sv"

module interrupter (
				 input wire clk,
				 input wire gen,
				 output wire out
			 );

reg ff = 0;

int_gen i(
					.clk(clk),
					.freq_par(8'd4),	// 100 -> 1 MHz -> 1us
					.pw_par(8'd13),
					.out(int_wire)
				);

edge_det gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p));

sync gen_d(
			 .clk(clk),
			 .data_raw(gen),
			 .data(gen_del)
		 );

always @(posedge clk) if (gen_edge_p) ff <= !int_wire;

assign out = ff && gen_del;

endmodule
