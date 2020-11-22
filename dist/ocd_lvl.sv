`include "./modules/defines.sv"

module ocd_lvl #(parameter
								 CLK_MHZ = 100,
								 PAR_MAX_VAL = 255,
								 ADDR_MAX = 4,
								 ADDR = 4
								)
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) pw_par,
				 input `wire(ADDR_MAX) addr,
				 input wire en,
				 output wire out
			 );

`reg(PAR_MAX_VAL) cnt = 0;

`reg(PAR_MAX_VAL) storage = 0;

always @(posedge clk) if (en && (addr == ADDR)) storage <= pw_par;

always @(posedge clk)
	cnt <= cnt ? cnt - 1 : PAR_MAX_VAL - 1;

assign out = cnt < storage;

endmodule
