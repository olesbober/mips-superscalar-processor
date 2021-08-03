module ALU_tb();

	reg [31:0] sim_In1, sim_In2, file_ALUout;
	reg [3:0] sim_Func;
	wire sim_Zero;
	wire [31:0] sim_ALUout;
	reg [31:0] data[0:131];	// 132 memory words (lines), 32 bits wide
	integer i;
	
	ALU dut(
	.In1(sim_In1),
	.In2(sim_In2),
	.Func(sim_Func),
	.ALUout(sim_ALUout),
	.Zero(sim_Zero)
	);

	initial $readmemh("ALU.tv", data);

	initial begin
        	for (i = 0; i < 132; i = i + 4) begin
			sim_Func = data[i];
			sim_In1 = data[i + 1];
			sim_In2 = data[i + 2];
			file_ALUout = data[i + 3];
			#50
			$display("f: %d, a: %h, b: %h, expected y: %h, actual y: %h, zero: %b", sim_Func, sim_In1, sim_In2, file_ALUout, sim_ALUout, sim_Zero);
		end
	end
endmodule