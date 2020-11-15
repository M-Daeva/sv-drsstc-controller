`include "./modules/defines.sv"

module int_gen #(parameter
								 CLK_MHZ = 100,
								 FREQ_MIN_HZ = 10_000,
								 PW_STEP_MUL = 1,
								 PAR_MAX_VAL = 255
								)
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) freq_par,
				 input `wire(PAR_MAX_VAL) pw_par,
				 output wire out
			 );

localparam FREQ_RATIO = `div(1_000_000 * CLK_MHZ, FREQ_MIN_HZ);

`reg(FREQ_RATIO) cnt = 0;

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else begin
		case(freq_par)
			`lookup
		endcase
	end
end

assign out = cnt < PW_STEP_MUL * pw_par;

endmodule
