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

localparam K1 = 20,
					 K2 = 15,
					 K3 = 9,
					 CNT_MAX = (1 << K1) + (PAR_MAX_VAL << K2) - 1;

`reg(CNT_MAX) cnt = 0;

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else cnt <= (1 << K1) + (freq_par << K2) - 1;
end

assign out = cnt < (pw_par << K3);

endmodule
