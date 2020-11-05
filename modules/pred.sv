`include "modules/defines.sv"

module pred #(parameter
							PRED_PARAMETER = 255
						 )
			 (
				 input wire clk,
				 input wire sgn,
				 input `wire(PRED_PARAMETER) shift,
				 output reg sgn_pre = 0
			 );


`reg(PRED_PARAMETER) cnt;	// rewrite inital value as shift
initial cnt = shift;

always @(posedge clk) begin
	if (sgn ^ sgn_pre) begin
		if (cnt) cnt <= cnt - 1;
		else begin
			cnt <= shift - 1;
			sgn_pre <= sgn;
		end
	end
end

endmodule
