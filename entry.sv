`include "common.sv"

// 9600 Hz uart module uses 54 LE


module entry (
				 input wire clk,
				 input wire uart_data,
				 output `wire_2d(sh_reg, CONF_PAR_MAX, CONF_PAR_4),
				 //output wire[7:0] storage,
				 //output wire[1:0] state
				 output wire out,
				 output wire out_pred
			 );

gen gen_ins(
			.clk(clk),
			.en(1'b1),
			.inp(8'd0),
			.out(out)
		);



pred pred_ins(
			 .clk(clk),
			 .sgn(out),
			 .shift(8'd62),
			 .sgn_pre(out_pred)
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
