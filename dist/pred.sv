`include "./modules/defines.sv"
module sync_16054639060770353171673374719 #(parameter
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


	module pred #(parameter
								PRED_PARAMETER = 255
							 )
	(
		input wire clk,
		input wire sgn,
		input `wire(PRED_PARAMETER) shift,
		output reg sgn_pre = 0
	);

// cdc synchronizer
sync_16054639060770353171673374719 #(.WIDTH(1))
																	 s1(
																		 .clk(clk),
																		 .data_raw(sgn),
																		 .data(sgn_s)
																	 );

`reg(PRED_PARAMETER) cnt;
initial cnt = shift;

always @(posedge clk) begin
	if (sgn_s ^ sgn_pre) begin
		if (cnt) cnt <= cnt - 1;
		else begin
			cnt <= shift - 1;
			sgn_pre <= sgn_s;
		end
	end
end

endmodule
