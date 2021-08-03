module reg_file_tb();

	reg sim_Clk, sim_Reset, sim_WE1, sim_WE2;
	reg [4:0] sim_A11, sim_A21, sim_A12, sim_A22, sim_WA1, sim_WA2;
	reg [31:0] sim_WD1, sim_WD2;
	wire [31:0] sim_RD11, sim_RD21, sim_RD12, sim_RD22;

	reg_file dut(
	.Clk(sim_Clk),
	.Reset(sim_Reset),
	.WE1(sim_WE1),
	.WE2(sim_WE2),
	.A11(sim_A11),
	.A21(sim_A21),
	.A12(sim_A12),
	.A22(sim_A22),
	.WA1(sim_WA1),
	.WA2(sim_WA2),
	.WD1(sim_WD1),
	.WD2(sim_WD2),
	.RD11(sim_RD11),
	.RD21(sim_RD21),
	.RD12(sim_RD12),
	.RD22(sim_RD22)
	);

	// generate clock
	always begin
		sim_Clk <= 1;
		#5;
		sim_Clk <= 0;
		#5;
	end

	// test here
	initial begin
		// reset the register file first
		sim_Reset = 1;
		#10;
		sim_Reset = 0;

		// write some data to some registers
		sim_WE1 = 1'b1;
		sim_WE2 = 1'b1;
		sim_WA1 = 5'b00001;
		sim_WA2 = 5'b00010;
		sim_WD1 = 32'h6969ffff;
		sim_WD2 = 32'haaaaaaaa;
		#10;

		// write some more data
		sim_WA1 = 5'b00011;
		sim_WA2 = 5'b00100;
		sim_WD1 = 32'h42042069;
		sim_WD2 = 32'h33229999;
		#10;

		// read that same data
		sim_WE1 = 1'b0;
		sim_WE2 = 1'b0;
		sim_A11 = 5'b00001;
		sim_A21 = 5'b00010;
		sim_A12 = 5'b00011;
		sim_A22 = 5'b00100;
		#10;

		// reset the register file again
		sim_Reset = 1'b1;
		sim_WE1 = 1'bx;
		sim_WE2 = 1'bx;
		sim_WA1 = 5'bxxxxx;
		sim_WA2 = 5'bxxxxx;
		sim_WD1 = 32'hxxxxxxxx;
		sim_WD2 = 32'hxxxxxxxx;
		#10;

		$stop;
	end

endmodule
