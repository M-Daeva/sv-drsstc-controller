`include "./modules/defines.sv"

module ref_gen #(parameter
								 CLK_MHZ = 100,
								 FREQ_MID_KHZ = 200,
								 GEN_PARAMETER = 255,
								 VALUE = 8'd127,
								 ADDR_MAX = 4,
								 ADDR = 4
								)
			 (
				 input wire clk,
				 input `wire(GEN_PARAMETER) data,
				 input `wire(ADDR_MAX) addr,
				 input wire en,
				 output reg out = 0
			 );

localparam CNT_MIN = `div(500 * CLK_MHZ, FREQ_MID_KHZ) - `div(GEN_PARAMETER, 2);

`reg(CNT_MIN + GEN_PARAMETER - 1) cnt = 0;

`reg(GEN_PARAMETER) storage = 0;

always @(posedge clk) if (en && (addr == ADDR)) storage <= data;

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else begin
		cnt <= CNT_MIN + storage - 1;
		out <= ~out;
	end
end

endmodule
