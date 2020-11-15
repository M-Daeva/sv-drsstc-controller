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

localparam FREQ_KHZ = `div(1000 * CLK_MHZ, PAR_MAX_VAL);

`reg(PAR_MAX_VAL) cnt = PAR_MAX_VAL - 1;

always @(posedge clk)
	cnt <= !cnt ? PAR_MAX_VAL - 1 : cnt - 1;

assign out = cnt < pw_par;

endmodule
