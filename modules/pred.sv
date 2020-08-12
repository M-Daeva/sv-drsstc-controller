`include "modules/defines.sv"

module pred #(parameter
							PRED_PARAMETER = 10
						 )
			 (
				 input wire clk,
				 input wire sgn,
				 //input `wire(PRED_PARAMETER) shift,
				 output reg sgn_pre = 0
			 );

localparam CNT_MAX = 255;

`reg(CNT_MAX) cnt = PRED_PARAMETER;

always @(posedge clk) begin
	if (sgn && ~sgn_pre) begin
		if (cnt) cnt <= cnt - 1;
		else begin
			cnt <= PRED_PARAMETER;
			sgn_pre <= sgn;
		end
	end
end

endmodule
