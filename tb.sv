`timescale 1ns/1ns
`include "entry.sv"

module test_entry;

reg clk_tb, uart_data_tb, uart_clk_tb;
`wire(STATE_2)	state_tb;
`wire(STOR_MAX_VAL) storage_1_tb, storage_2_tb;
`wire(EDGE_CNT_MAX_1 * FRAME) edge_cnt_tb;


entry entry_inst(
				.clk(clk_tb),
				.uart_clk(uart_clk_tb),
				.uart_data(uart_data_tb),
				.edge_cnt(edge_cnt_tb),
				.state(state_tb),
				.storage_1(storage_1_tb),
				.storage_2(storage_2_tb)
			);

int packet_size = 19;
int arr = 19'b0_0010_1100_10_0100_1100; // 42



//моделируем сигнал тактовой частоты
always #`clk_frame_tb clk_tb = ~clk_tb;
always #`frame_tb uart_clk_tb = ~uart_clk_tb;

initial begin
	clk_tb = 0;
	uart_data_tb = 1;
	uart_clk_tb = 0;

	for (int i = packet_size; i > 0; i--) begin
		#(2 * `frame_tb) uart_data_tb = arr[i-1];
		if (i == 1) #(2 * `frame_tb) uart_data_tb = 1;
	end
end

initial #(2 * (packet_size + 2) * `frame_tb) $finish;

//создаем файл VCD для последующего анализа сигналов
initial begin
	$dumpfile("out.vcd");
	$dumpvars(0, test_entry);
end


//наблюдаем на некоторыми сигналами системы
initial $monitor(
		$stime,
		clk_tb,
		uart_clk_tb,
		uart_data_tb,
		state_tb,
		edge_cnt_tb,
		storage_1_tb,
		storage_2_tb
	);



endmodule
