`include "./modules/defines.sv"

module ocd_lvl #(parameter
								 CLK_MHZ = 100,
								 PAR_MAX_VAL = 255
								)
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) pw_par,
				 output wire out
			 );

`reg(PAR_MAX_VAL) cnt = 0;

always @(posedge clk)
	cnt <= cnt - 1;

assign out = cnt < pw_par;

endmodule
