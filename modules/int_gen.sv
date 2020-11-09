`include "./modules/defines.sv"

module int_gen #(parameter
								 CLK_MHZ = 100,
								 PAR_MAX_VAL = 255
								)
			 (
				 input wire clk,
				 input `wire(PAR_MAX_VAL) freq_par,
				 input `wire(PAR_MAX_VAL) pw_par,
				 output wire out
			 );

localparam k = 100;	// for pw_par in microseconds

`reg(100 * CLK_MHZ) cnt = 0; // 500_000

always @(posedge clk) begin
	if (cnt) cnt <= cnt - 1;
	else begin
		case(freq_par)
			`lookup
		endcase
	end
end

assign out = cnt < k * pw_par;

endmodule
