`timescale 1ns/1ns
`include "entry.sv"

module test_entry;

reg clk_tb, uart_data_tb, uart_clk_tb;
wire is_data_ready_tb;
`wire(STATE_2)	state_tb;
`wire(STORAGE_MAX) storage_tb;
`wire(FRAME_CNT_MAX_1) frame_cnt_tb;

entry entry_inst(
				.clk(clk_tb),
				.uart_data(uart_data_tb),
				.frame_cnt(frame_cnt_tb),
				.state(state_tb),
				.storage(storage_tb),
				.is_data_ready(is_data_ready_tb)
			);

localparam test_data = 19'b0_0010_1100_10_0100_1100, // 42
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
		state_tb,,
		frame_cnt_tb,,
		storage_tb,,
		is_data_ready_tb
	);

endmodule
