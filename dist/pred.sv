`include "./modules/defines.sv"
module sync_1606036677913015184263933308406 #(parameter
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
								PRED_PARAMETER = 255,
								ADDR_MAX = 4,
								ADDR = 4
							 )
	(
		input wire clk,
		input wire sgn,
		input `wire(PRED_PARAMETER) shift,
		input `wire(ADDR_MAX) addr,
		input wire en,
		output reg sgn_pre = 0
	);

// cdc synchronizer
sync_1606036677913015184263933308406 #(.WIDTH(1))
																		 s1(
																			 .clk(clk),
																			 .data_raw(sgn),
																			 .data(sgn_s)
																		 );

`reg(PRED_PARAMETER) cnt = 0;	// no delay for first edge in first pulse

`reg(PRED_PARAMETER) storage = 0;

always @(posedge clk) if (en && (addr == ADDR)) storage <= shift;

always @(posedge clk) begin
	if (sgn_s ^ sgn_pre) begin
		if (cnt) cnt <= cnt - 1;
		else begin
			cnt <= storage - 1;
			sgn_pre <= sgn_s;
		end
	end
end

endmodule
