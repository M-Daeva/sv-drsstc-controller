`include "./modules/defines.sv"
`include "./modules/sync.sv"

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
sync #(.WIDTH(1))
		 s1(
			 .clk(clk),
			 .data_raw(sgn),
			 .data(sgn_s)
		 );

`reg(PRED_PARAMETER) cnt = 0;	// no delay for first edge in first pulse

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
