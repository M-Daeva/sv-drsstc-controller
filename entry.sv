`include "common.sv"

module entry (
				 input wire clk,

				 input wire uart_data,
				 output `wire_2d(sh_reg, CONF_PAR_MAX, CONF_PAR_4),

				 output wire gen_out,

				 input wire fb_in,
				 output wire fb_out,

				 output wire sel_out,

				 output wire ocd_lvl_out,

				 input wire int_ocd,
				 output wire int_out_p,
				 output wire int_out_n
			 );

// assign uart_ref_gen = sh_reg_tb[4],
// 			 uart_pred = sh_reg_tb[3],
// 			 uart_ocd_lvl = sh_reg_tb[2],
// 			 uart_int_freq = sh_reg_tb[1],
// 			 uart_int_pw = sh_reg_tb[0],

uart #(
			 .CONF_PAR_MAX(CONF_PAR_MAX),
			 .FRAME_CNT_MAX_1(FRAME_CNT_MAX_1),
			 .FRAME_CNT_MAX_2(FRAME_CNT_MAX_2),
			 .DATA_BIT_CNT_MAX(DATA_BIT_CNT_MAX)
		 ) uart_ins(
			 .clk(clk),
			 .uart_data(uart_data),
			 .sh_reg(sh_reg)
		 );

ref_gen #(.CLK_MHZ(GEN_CLK_FREQ_MHZ),
					.FREQ_MID_KHZ(200),
					.GEN_PARAMETER(255))
				rg1(
					.clk(clk),
					.inp(8'd127),	// 8d'127 - 200 kHz
					.out(gen_out)
				);

pred p1(
			 .clk(clk),
			 .sgn(fb_in),
			 .shift(8'd30),	//8'd30
			 .sgn_pre(fb_out)
		 );

selector #(.CLK_MHZ(GEN_CLK_FREQ_MHZ),
					 .PERIODS_TO_SWITCH(4),
					 .RESET_TIMEOUT_US(4))
				 s1(
					 .clk(clk),
					 .gen(gen_out),
					 .fb(fb_out),
					 .out(sel_out)
				 );

interrupter #(.CLK_MHZ(GEN_CLK_FREQ_MHZ),
							.FREQ_MIN_HZ(INTER_FREQ_MIN_HZ),
							.PW_STEP_MUL(5),
							.SKIP_CNT_MAX(3),	// rewrite lookup -> harmonical step
							.PAR_MAX_VAL(255))
						i1(
							.clk(clk),
							.gen(sel_out),
							.ocd(int_ocd),
							.freq_par(8'd10),	// frequency multiplier
							.pw_par(8'd1),		// pulse width multiplier
							.out_p(int_out_p),
							.out_n(int_out_n)
						);

ocd_lvl #(.CLK_MHZ(GEN_CLK_FREQ_MHZ),
					.PAR_MAX_VAL(200))
				o(
					.clk(clk),
					.pw_par(8'd87),
					.out(ocd_lvl_out)
				);

endmodule
