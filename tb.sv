`timescale 1ns/1ps
`include "entry.sv"

module test_entry;

reg clk_tb, data_tb;
wire data_tb_2,
		 uart_clk_tb,
		 uart_clk_tb_2;
wire[1:0]	state_tb;
wire[5:0] tmr_tb;


//устанавливаем экземпляр тестируемого модуля
//entry entry_inst(tclk, data, out, state_value);
entry entry_inst(
				.clk(clk_tb),
				.data_raw(data_tb),
				.data(data_tb_2),
				.state(state_tb),
				.tmr(tmr_tb),
				.uart_clk(uart_clk_tb),
				.uart_clk_2(uart_clk_tb_2)
			);

int i = 0;

//моделируем сигнал тактовой частоты
always #5 clk_tb = ~clk_tb;

//от начала времени...

initial begin
	clk_tb = 0;
	data_tb = 0;
	#100 data_tb = 0;

	for (i = 0; i < 20; i = i + 1)
		#100 data_tb = ~data_tb;
end


//always #100 data_tb = ~data_tb;



//заканчиваем симуляцию в момент времени "400"
initial #5000 $finish;


//создаем файл VCD для последующего анализа сигналов
initial begin
	$dumpfile("out.vcd");
	$dumpvars(0, test_entry);
end


//наблюдаем на некоторыми сигналами системы
initial $monitor(
		$stime,,
		clk_tb,,,
		data_tb,,
		data_tb_2,,
		state_tb,,
		tmr_tb,,
		uart_clk_tb,,
		uart_clk_tb_2
	);

/*
`define s(a) ($clog2(a)+1)'(a)
initial $display(`s(-330));
*/

endmodule
