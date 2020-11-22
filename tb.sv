`timescale 1ns/1ns
`include "entry.sv"

module test_entry;

reg clk_tb = 0, uart_data_tb = 1, uart_clk_tb = 0, fb_tb = 0, fb_mask = 1, ocd_tb = 0;

`wire_2d(sh_reg_tb, CONF_PAR_MAX, CONF_PAR_4);
`wire(CONF_PAR_MAX) uart_ref_gen, uart_pred, uart_int_freq, uart_int_pw, uart_ocd_lvl;
wire gen_out_tb, fb_in_tb, fb_out_tb, sel_out_tb, ocd_lvl_out_tb, int_ocd_tb, int_out_p_tb, int_out_n_tb;

// 0 - ref_gen
// 1 - phase_shift
// 2 - ocd_lvl
// 3 - inter_freq
// 4 - inter_duty

assign uart_ref_gen = sh_reg_tb[4],
			 uart_pred = sh_reg_tb[3],
			 uart_ocd_lvl = sh_reg_tb[2],
			 uart_int_freq = sh_reg_tb[1],
			 uart_int_pw = sh_reg_tb[0],

			 fb_in_tb = fb_tb && fb_mask,
			 int_ocd_tb = ocd_tb;


entry entry_inst(
				.clk(clk_tb),

				.uart_data(uart_data_tb),
				//.sh_reg(sh_reg_tb),

				//.gen_out(gen_out_tb),

				.fb_in(fb_in_tb),
				//.fb_out(fb_out_tb),

				//.sel_out(sel_out_tb),

				.ocd_lvl_out(ocd_lvl_out_tb),

				.int_ocd(int_ocd_tb),
				.int_out_p(int_out_p_tb),
				.int_out_n(int_out_n_tb)
			);

localparam test_data = 49'b0_11111110_10_00111100_10_11101010_10_00000000_10_01000000,
					 packet_size = $bits(test_data);

// clk
always #CLK_FRAME_TB clk_tb = ~clk_tb;
always #FRAME_TB uart_clk_tb = ~uart_clk_tb;

localparam mul = 3;
initial #(mul * 2 * (packet_size + 2) * FRAME_TB) $finish;

initial begin
	for (int i = packet_size; i > 0; i--) begin
		#(2 * FRAME_TB) uart_data_tb = test_data[i-1];
		if (i == 1) #(2 * FRAME_TB) uart_data_tb = 1;
	end
end


// fb and ocd
int i = 0;

initial begin
	#5500;
	while (1'b1) begin
		#2500 fb_tb = ~fb_tb;
		i++;
		ocd_tb = (i == 12) || (i == 89) ? 1 : 0;
	end
end

initial begin
	#0;
	while (1'b1) begin
		#(25 * 2500) fb_mask = ~fb_mask;
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

		// uart_ref_gen,,
		// uart_pred,,
		// uart_int_freq,,
		// uart_int_pw,,
		// uart_ocd_lvl,,

		// gen_out_tb,,

		fb_in_tb,,
		//fb_out_tb,,

		//sel_out_tb,,

		ocd_lvl_out_tb,,

		int_ocd_tb,,
		int_out_p_tb,,
		int_out_n_tb,,
	);

endmodule
