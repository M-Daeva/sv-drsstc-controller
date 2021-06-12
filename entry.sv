`include "common.sv"

module entry (
				 input wire clk,	// PIN_12

				 input wire uart_data,	// PIN_17


				 //output wire gen_out,

				 input wire fb_in,	// PIN_33
				 //output wire fb_out,

				 //output wire sel_out,

				 output wire ocd_lvl_out,	// PIN_50

				 output wire buck_lvl_out,	// PIN_77
				 output wire buck_lvl_out_n,	// PIN_76

				 input wire int_ocd,	// PIN_35
				 output wire int_out_p,	// PIN_91
				 output wire int_out_n	// PIN_88
			 );

`wire(CONF_PAR_MAX) data_bus;
`wire(CONF_PAR_4) addr_bus;

assign buck_lvl_out_n = ~buck_lvl_out;

// assign uart_ref_gen = sh_reg[4],
// 			 uart_pred = sh_reg[3],
// 			 uart_ocd_lvl = sh_reg[2],
// 			 uart_int_freq = sh_reg[1],
// 			 uart_int_pw = sh_reg[0];

uart #(
			 .CONF_PAR_MAX(CONF_PAR_MAX),
			 .FRAME_CNT_MAX_1(FRAME_CNT_MAX_1),
			 .FRAME_CNT_MAX_2(FRAME_CNT_MAX_2),
			 .DATA_BIT_CNT_MAX(DATA_BIT_CNT_MAX)
		 ) uart_ins(
			 .clk(clk),
			 .uart_data(uart_data),
			 //.sh_reg(sh_reg)

			 .storage(data_bus),
			 .conf_par_cnt(addr_bus),
			 .is_data_ready(en)
		 );

ref_gen #(.CLK_MHZ(GEN_CLK_FREQ_MHZ),
					.FREQ_MID_KHZ(200),
					.GEN_PARAMETER(255),
					.VALUE(8'd127),	// 8d'127 - 200 kHz
					.ADDR_MAX(ADDR_MAX),
					.ADDR(REF_GEN_ADDR))
				rg1(
					.clk(clk),
					.data(data_bus),	// 8d'127 - 200 kHz
					.addr(addr_bus),
					.en(en),
					.out(gen_out)
				);

pred #(.ADDR_MAX(ADDR_MAX),
			 .ADDR(PRED_ADDR))
		 p1(
			 .clk(clk),
			 .sgn(~fb_in),	// fb signal on comparator neg input
			 .shift(data_bus),	//8'd30
			 .addr(addr_bus),
			 .en(en),
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
							.PW_STEP_MUL(500),	// 1 step - 5 us
							.SKIP_CNT_MAX(3),	// rewrite lookup -> harmonical step
							.PAR_MAX_VAL(255),
							.ADDR_MAX(ADDR_MAX),
							.ADDR(FREQ_ADDR),
							.ADDR2(PW_ADDR))
						i1(
							.clk(clk),
							.gen(sel_out),
							.ocd(int_ocd),
							.data(data_bus),	// frequency multiplier 8'd10
							//	.pw_par(8'd1),		// pulse width multiplier 8'd1
							.addr(addr_bus),
							.en(en),
							.out_p(int_out_p),
							.out_n(int_out_n)
						);

ocd_lvl #(.CLK_MHZ(GEN_CLK_FREQ_MHZ),
					.PAR_MAX_VAL(200),	// 500 kHz
					.ADDR_MAX(ADDR_MAX),
					.ADDR(OCD_ADDR))
				o(
					.clk(clk),
					.pw_par(data_bus),
					.addr(addr_bus),
					.en(en),
					.out(ocd_lvl_out)
				);

ocd_lvl #(.CLK_MHZ(GEN_CLK_FREQ_MHZ),
					.PAR_MAX_VAL(250),	// 400 kHz
					.ADDR_MAX(ADDR_MAX),
					.ADDR(BUCK_ADDR))
				b(
					.clk(clk),
					.pw_par(data_bus),
					.addr(addr_bus),
					.en(en),
					.out(buck_lvl_out)
				);

endmodule
