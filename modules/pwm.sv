`include "modules/defines.sv"

module pwm #(parameter
						 clk_mhz = 50,
						 freq_khz = 400,
						 duty = 40
						)
			 (
				 input wire clk,
				 input wire rst,
				 output wire out
			 );

localparam cnt_max = `div(1000 * clk_mhz, freq_khz),
					 cnt_duty = `div(duty * cnt_max, 100);

`reg(cnt_max) cnt = cnt_max - 1;

assign out = cnt < cnt_duty;

always @(posedge clk)
	cnt <= (rst || !cnt) ? cnt_max - 1 : cnt - 1;

endmodule
