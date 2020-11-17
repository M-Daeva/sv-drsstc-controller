`include "./modules/defines.sv"

module ref_gen #(parameter
								 CLK_MHZ = 100,
								 FREQ_MID_KHZ = 200,
								 GEN_PARAMETER = 255
								)
			 (
				 input wire clk,
				 input `wire(GEN_PARAMETER) inp,
				 output reg out = 0
			 );

localparam CNT_MIN = `div(500 * CLK_MHZ, FREQ_MID_KHZ) - `div(GEN_PARAMETER, 2);

`reg(CNT_MIN + GEN_PARAMETER - 1) cnt = 0;

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else begin
		cnt <= CNT_MIN + inp - 1;
		out <= ~out;
	end
end

endmodule
