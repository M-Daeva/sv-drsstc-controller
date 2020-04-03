`include "modules/include_all.sv"

/*
real uart frequency is 9600 Hz
assume 960 kHz for faster simulation
*/

localparam 	GEN_CLK_FREQ = 100_000_000,
						TB_CLK_FREQ = 1_000_000_000,
						UART_FREQ = 960_000,

						FRAME_FREQ = 2 * UART_FREQ,
						FRAME = `div(GEN_CLK_FREQ, FRAME_FREQ),
						FRAME_TB = `div(TB_CLK_FREQ, FRAME_FREQ),
						CLK_FRAME_TB = `div(TB_CLK_FREQ, (2 * GEN_CLK_FREQ)),

						STORAGE_MAX = 255,
						FRAME_CNT_MAX_1 = 3 * FRAME,
						FRAME_CNT_MAX_2 = 2 * FRAME,
						DATA_BIT_CNT_MAX = 7;
