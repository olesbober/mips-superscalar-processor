module datapath_tb();

	reg sim_Clk, sim_Reset;

	datapath dut(
	.Clk(sim_Clk),
	.Reset(sim_Reset)
	);

	// generate clock
	always begin
		sim_Clk <= 1;
		#5;
		sim_Clk <= 0;
		#5;
	end

	initial begin
		// reset everything
		sim_Reset = 1;
		#10;
		sim_Reset = 0;
	end

endmodule
