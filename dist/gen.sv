`include "./modules/defines.sv"

module gen #(parameter
						 CLK_MHZ = 100,
						 FREQ_KHZ_MIN = 100,	// actual range from 200 to 400
						 FREQ_KHZ_MAX = 400,
						 GEN_PARAMETER = 255
						)
			 (
				 input wire clk,
				 input wire en,
				 input `wire(GEN_PARAMETER) inp,
				 output reg out = 0
			 );

localparam CNT_MIN = `div(500 * CLK_MHZ, FREQ_KHZ_MAX),
					 CNT_MAX = `div(500 * CLK_MHZ, FREQ_KHZ_MIN);

`reg(GEN_PARAMETER) gen_param = 0;
`reg(CNT_MAX) cnt = CNT_MIN - 1 + GEN_PARAMETER;

always @(posedge clk) begin
	if (en) gen_param <= inp;

	if (cnt) cnt <= cnt - 1;
	else begin
		cnt <= CNT_MIN - 1 + gen_param;
		out <= ~out;
	end
end

endmodule
