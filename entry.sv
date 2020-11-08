`include "common.sv"

// 9600 Hz uart module uses 54 LE


module entry (
				 input wire clk,
				 input wire uart_data,
				 output `wire_2d(sh_reg, CONF_PAR_MAX, CONF_PAR_4),
				 //output wire[7:0] storage,
				 //output wire[1:0] state

				 output wire gen_out,

				 input wire fb_in,
				 output wire fb_out,

				 output wire sel_out,

				 output wire int_out
			 );

ref_gen rg1(
					.clk(clk),
					.inp(8'd0),
					.out(gen_out)
				);

pred p1(
			 .clk(clk),
			 .sgn(fb_in),
			 .shift(8'd30),
			 .sgn_pre(fb_out)
		 );

selector s1(
					 .clk(clk),
					 .gen(gen_out),
					 .fb(fb_out),
					 .out(sel_out)
				 );

interrupter i1(
							.clk(clk),
							.gen(sel_out),
							.out(int_out)
						);



/*
uart #(
			 .CONF_PAR_MAX(CONF_PAR_MAX),
			 .FRAME_CNT_MAX_1(FRAME_CNT_MAX_1),
			 .FRAME_CNT_MAX_2(FRAME_CNT_MAX_2),
			 .DATA_BIT_CNT_MAX(DATA_BIT_CNT_MAX)
		 ) uart_ins(
			 .clk(clk),
			 .uart_data(uart_data),
			 .sh_reg(sh_reg)
			 //.storage(storage),
			 //.state(state)
		 );
*/

endmodule
