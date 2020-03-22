`include "modules/defines.sv"

module sync #(parameter
							width = 1
						 )
			 (
				 input wire clk,
				 input wire[width-1:0] data_raw,
				 output reg[width-1:0] data = 0
			 );

reg[width-1:0] internal = 0;

always @(posedge clk)
	{ data, internal } <= { internal, data_raw };

endmodule
