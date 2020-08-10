`timescale 1ns/1ns
`include "entry.sv"

module test_entry;

reg clk_tb, uart_data_tb, uart_clk_tb;
wire is_data_ready_tb, out_tb;
`wire_2d(sh_reg_tb, CONF_PAR_MAX, CONF_PAR_4);
`wire(CONF_PAR_MAX) sh_0, sh_1, sh_2, sh_3, sh_4;

assign sh_0 = sh_reg_tb[0],
			 sh_1 = sh_reg_tb[1],
			 sh_2 = sh_reg_tb[2],
			 sh_3 = sh_reg_tb[3],
			 sh_4 = sh_reg_tb[4];


entry entry_inst(
				.clk(clk_tb),
				.uart_data(uart_data_tb),
				.sh_reg(sh_reg_tb)
			);

localparam test_data = 49'b0_00101100_10_01001100_10_00101100_10_01001100_1000101100, // 42424
					 packet_size = $bits(test_data);

// clk
always #CLK_FRAME_TB clk_tb = ~clk_tb;
always #FRAME_TB uart_clk_tb = ~uart_clk_tb;

initial #(2 * (packet_size + 2) * FRAME_TB) $finish;

initial begin
	clk_tb = 0;
	uart_data_tb = 1;
	uart_clk_tb = 0;

	for (int i = packet_size; i > 0; i--) begin
		#(2 * FRAME_TB) uart_data_tb = test_data[i-1];
		if (i == 1) #(2 * FRAME_TB) uart_data_tb = 1;
	end
end

// creating VCD file for signal analysis
initial begin
	$dumpfile("out.vcd");
	$dumpvars(0, test_entry);
end

// displaying meaning signals
initial $monitor(
		$stime,,
		clk_tb,,
		uart_clk_tb,,
		uart_data_tb,,
		sh_0,,
		sh_1,,
		sh_2,,
		sh_3,,
		sh_4,,
		out_tb
	);

endmodule
