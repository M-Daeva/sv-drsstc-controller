`include "common.sv"

// 9600 Hz uart module uses 54 LE


module entry (
				 input wire clk,
				 input wire uart_data,
				 output `wire_2d(sh_reg, CONF_PAR_MAX, CONF_PAR_4)
			 );
/*
gen gen_ins(
			.clk(clk),
			.en(is_data_ready),
			.inp(storage),
			.out(out)
		);
*/
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


endmodule
