`include "./modules/defines.sv"
`include "./modules/pwm.sv"
`include "./modules/edge_det.sv"
`include "./modules/sync.sv"

module interrupter (
				 input wire clk,
				 input wire gen,
				 output wire out
			 );

reg ff = 0;

pwm #(.CLK_MHZ(100),
			.FREQ_KHZ(25),
			.DUTY(50)
		 )
		inter
		(
			.clk(clk),
			.rst(1'b0),
			.out(pwm_wire)
		);

edge_det gen_p(.clk(clk), .sgn(gen), .out_p(gen_edge_p));

sync gen_d(
			 .clk(clk),
			 .data_raw(gen),
			 .data(gen_del)
		 );

always @(posedge clk) if (gen_edge_p) ff <= !pwm_wire;

assign out = ff && gen_del;

endmodule
