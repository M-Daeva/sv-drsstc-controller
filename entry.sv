`include "common.sv"

// 9600 Hz uart module uses 54 LE


module entry (
				 input wire clk,
				 input wire uart_data,
				 output `wire(STORAGE_MAX) storage,
				 output wire is_data_ready
			 );



uart #(
			 .STORAGE_MAX(STORAGE_MAX),
			 .FRAME_CNT_MAX_1(FRAME_CNT_MAX_1),
			 .FRAME_CNT_MAX_2(FRAME_CNT_MAX_2),
			 .DATA_BIT_CNT_MAX(DATA_BIT_CNT_MAX)
		 ) uart_ins(
			 .clk(clk),
			 .uart_data(uart_data),
			 .storage(storage),
			 .is_data_ready(is_data_ready)
		 );


endmodule
