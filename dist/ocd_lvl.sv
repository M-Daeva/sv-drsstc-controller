`include "./modules/defines.sv"

module ocd_lvl #(parameter
								 CLK_MHZ = 100,
								 FREQ_KHZ = 100,
								 PAR_MAX_VAL = 100
								)
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) pw_par,
				 output wire out
			 );

localparam cnt_max = `div(1000 * CLK_MHZ, FREQ_KHZ),
					 k = `div(cnt_max, PAR_MAX_VAL);

`reg(cnt_max) cnt = cnt_max - 1;

always @(posedge clk)
	cnt <= !cnt ? cnt_max - 1 : cnt - 1;

assign out = cnt < k * pw_par;

endmodule
