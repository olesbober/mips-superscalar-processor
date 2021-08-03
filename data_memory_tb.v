module data_memory_tb();
	
	reg sim_Clk, sim_RE1, sim_RE2, sim_WE1, sim_WE2;
	reg [31:0] sim_A1, sim_A2, sim_WD1, sim_WD2;
	wire [31:0] sim_RD1, sim_RD2;

	data_memory dut(
	.Clk(sim_Clk),
	.RE1(sim_RE1),
	.RE2(sim_RE2),
	.WE1(sim_WE1),
	.WE2(sim_WE2),
	.A1(sim_A1),
	.A2(sim_A2),
	.WD1(sim_WD1),
	.WD2(sim_WD2),
	.RD1(sim_RD1),
	.RD2(sim_RD2)
	);

  	always begin	// generate clock
		sim_Clk <= 1;
		#5;
		sim_Clk <= 0;
		#5;
  	end

	initial begin
		// write some data to the block
		sim_RE1 = 1'b0;
		sim_RE2 = 1'b0;
		sim_WE1 = 1'b1;
		sim_WE2 = 1'b1;
		sim_A1 = 32'h00000000;
		sim_WD1 = 32'hffff6969;
		sim_A2 = 32'h00000004;
		sim_WD2 = 32'h6969ffff;
		#10;

		sim_A1 = 32'h00000008;
		sim_WD1 = 32'h42042069;
		sim_A2 = 32'h00000100;
		sim_WD2 = 32'h7777777F;
		#10;

		// read the data back from the block, see if it's correct
		// use different write_data from what it's supposed to be to see if it's accidentally overwriting
		sim_RE1 = 1'b1;
		sim_RE2 = 1'b1;
		sim_WE1 = 1'b0;
		sim_WE2 = 1'b0;
		sim_A1 = 32'h00000000;
		sim_WD1 = 32'h12345678;
		sim_A2 = 32'h00000004;
		sim_WD2 = 32'hffffffff;
		#10;

		sim_A1 = 32'h00000008;
		sim_WD1 = 32'hFDECBA98;
		sim_A2 = 32'h00000100;
		sim_WD2 = 32'h2222222A;
		#10;

		$stop;
	end
endmodule
