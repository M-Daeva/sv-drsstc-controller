`include "modules/include_all.sv"


localparam 	GEN_CLK_FREQ = 100_000_000,
						TB_CLK_FREQ = 1_000_000_000,
						UART_FREQ = 960_000,

						FRAME_FREQ = 2 * UART_FREQ,
						FRAME = `div(GEN_CLK_FREQ, FRAME_FREQ),
						FRAME_TB = `div(TB_CLK_FREQ, FRAME_FREQ),
						CLK_FRAME_TB = `div(TB_CLK_FREQ, (2*GEN_CLK_FREQ)),

						STOR_MAX_VAL = 255,
						EDGE_CNT_MAX_1 = 3,
						EDGE_CNT_MAX_2 = 2;


`define frame_tb FRAME_TB
`define clk_frame_tb CLK_FRAME_TB
