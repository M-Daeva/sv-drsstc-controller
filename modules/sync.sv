`include "modules/defines.sv"

module sync #(parameter
							WIDTH = 1
						 )
			 (
				 input wire clk,
				 input wire[WIDTH-1:0] data_raw,
				 output reg[WIDTH-1:0] data = 0
			 );

reg[WIDTH-1:0] internal = 0;

always @(posedge clk)
	{ data, internal } <= { internal, data_raw };

endmodule
