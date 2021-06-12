`include "./modules/defines.sv"

module pwm #(parameter
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

always @(posedge clk)
	cnt <= (rst || !cnt) ? cnt_max - 1 : cnt - 1;

assign out = cnt < cnt_duty;

endmodule
