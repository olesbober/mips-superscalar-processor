module inst_memory_tb();
	
	reg [31:0] sim_A1, sim_A2;
	wire [31:0] sim_RD1, sim_RD2;
	integer i;

	inst_memory dut(
	.A1(sim_A1),
	.A2(sim_A2),
	.RD1(sim_RD1),
	.RD2(sim_RD2)
	);

	initial begin
		// check which data is at all addresses in inst_memory
		for(i = 0; i < 60; /* number of lines in fibonacci_sequence.dat * 4 */ i = i + 8) begin // byte addressable
			sim_A1 = i;
			sim_A2 = i + 4;
			#10;
		end
	end

endmodule
