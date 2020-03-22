module edge_det
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
