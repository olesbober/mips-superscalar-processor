module branch_predictor_tb();

	reg sim_clk, sim_reset, sim_WE1, sim_WE2, sim_US1, sim_US2, sim_T1, sim_T2;
	reg [31:0] sim_RA1, sim_RA2, sim_WA1, sim_WA2, sim_WD1, sim_WD2;
	wire sim_P1, sim_P2;
	wire [31:0] sim_RD1, sim_RD2;

	branch_predictor dut(
	.clk(sim_clk),
	.reset(sim_reset),
	.WE1(sim_WE1),
	.WE2(sim_WE2),
	.US1(sim_US1),
	.US2(sim_US2),
	.T1(sim_T1),
	.T2(sim_T2),
	.RA1(sim_RA1),
	.RA2(sim_RA2),
	.WA1(sim_WA1),
	.WA2(sim_WA2),
	.WD1(sim_WD1),
	.WD2(sim_WD2),
	.P1(sim_P1),
	.P2(sim_P2),
	.RD1(sim_RD1),
	.RD2(sim_RD2)
	);

	// generate clock
	always begin
		sim_clk <= 1;
		#5;
		sim_clk <= 0;
		#5;
	end

	initial begin
		// first, reset everything
		sim_reset = 1'b1;
		#5;
		sim_reset = 1'b0;
		#5;	

		// store two branch addresses into the buffer
		sim_WE1 = 1'b1;
		sim_WE2 = 1'b1;
		sim_WA1 = 32'h00002222;
		sim_WD1 = 32'h69696969;
		sim_WA2 = 32'h00006969;
		sim_WD2 = 32'hffa12edc;
		#10;

		// now, let's see what happens when the first branch has this pattern: 1010101010
		// at the same time, use the same read_address to see the prediction
		sim_WE1 = 1'b0;
		sim_WE2 = 1'b0;
		sim_WA1 = 32'h00002222;
		sim_RA1 = 32'h00002222;
		sim_US1 = 1'b1;
		sim_T1 = 1'b1;
		#10;
		sim_T1 = 1'b0;
		#10;
		sim_T1 = 1'b1;
		#10;
		sim_T1 = 1'b0;
		#10;
		sim_T1 = 1'b1;
		#10;
		sim_T1 = 1'b0;
		#10;
		sim_T1 = 1'b1;
		#10;
		sim_T1 = 1'b0;
		#10;
		sim_T1 = 1'b1;
		#10;
		sim_T1 = 1'b0;
		#10;

		// now, let's see what happens when the second branch has this pattern: 1110001010
		// at the same time, use the same read_address to see the prediction
		sim_WA2 = 32'h00006969;
		sim_RA2 = 32'h00006969;
		sim_US1 = 1'b0;
		sim_US2 = 1'b1;
		sim_T2 = 1'b1;
		#10;
		sim_T2 = 1'b1;
		#10;
		sim_T2 = 1'b1;
		#10;
		sim_T2 = 1'b0;
		#10;
		sim_T2 = 1'b0;
		#10;
		sim_T2 = 1'b0;
		#10;
		sim_T2 = 1'b1;
		#10;
		sim_T2 = 1'b0;
		#10;
		sim_T2 = 1'b1;
		#10;
		sim_T2 = 1'b0;
		#10;

		// now, let's overwrite the predicted PCs with new branch target addresses
		sim_WE1 = 1'b1;
		sim_WE2 = 1'b1;
		sim_WA1 = 32'h00002222;
		sim_WD1 = 32'habcdef12;
		sim_WA2 = 32'h00006969;
		sim_WD2 = 32'h42042042;
		#20;

		$stop;
	end

endmodule