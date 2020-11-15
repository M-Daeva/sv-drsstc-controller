`include "./modules/defines.sv"

module delay #(parameter
							 WIDTH = 2
							)
			 (
				 input wire clk,
				 input wire data_raw,
				 output wire data
			 );

reg[WIDTH-1:0] internal = 0;

always @(posedge clk) begin
	if (WIDTH == 1) internal <= data_raw;
	else internal <= { data_raw, internal[WIDTH-1:1] };
end

assign data = (WIDTH == 1) ? internal : internal[0];

endmodule
