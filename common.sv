`include "./dist/uart.sv"
`include "./dist/ref_gen.sv"
`include "./dist/pred.sv"
`include "./dist/selector.sv"
`include "./dist/interrupter.sv"
`include "./dist/ocd_lvl.sv"

/*
real uart frequency is 9600 Hz
assume 960 kHz for faster simulation
*/

localparam 	GEN_CLK_FREQ = 100_000_000,
						TB_CLK_FREQ = 1_000_000_000,
						UART_FREQ = 320_000,

						FRAME_FREQ = 2 * UART_FREQ,
						FRAME = `div(GEN_CLK_FREQ, FRAME_FREQ),
						FRAME_TB = `div(TB_CLK_FREQ, FRAME_FREQ),
						CLK_FRAME_TB = `div(TB_CLK_FREQ, (2 * GEN_CLK_FREQ)),

						CONF_PAR_MAX = 255,
						FRAME_CNT_MAX_1 = 3 * FRAME,
						FRAME_CNT_MAX_2 = 2 * FRAME,
						DATA_BIT_CNT_MAX = 7,

						GEN_CLK_FREQ_MHZ = 100,
						INTER_FREQ_MIN_HZ = 1_000;
