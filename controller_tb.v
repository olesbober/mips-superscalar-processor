module controller_tb();

	reg [5:0] sim_OP, sim_Func;
	wire sim_MemtoReg, sim_MemRead, sim_MemWrite, sim_ALUSrcA, sim_RegDst, sim_RegWrite, sim_Jump, sim_Branch, sim_Se_ze;
	wire [3:0] sim_ALU_Op;

	controller dut(
	.OP(sim_OP),
	.Func(sim_Func),
	.MemtoReg(sim_MemtoReg),
	.MemRead(sim_MemRead),
	.MemWrite(sim_MemWrite),
	.ALUSrcA(sim_ALUSrcA),
	.RegDst(sim_RegDst),
	.RegWrite(sim_RegWrite),
	.Jump(sim_Jump),
	.Branch(sim_Branch),
	.Se_ze(sim_Se_ze),
	.ALU_Op(sim_ALU_Op)
	);

	// start test
	initial begin
		// instruction: ADD
		sim_OP = 6'b000000;
		sim_Func = 6'b100000;
		#10;

		// instruction: ADDU
		sim_OP = 6'b000000;
		sim_Func = 6'b100001;
		#10;
		
		// instruction: SUB
		sim_OP = 6'b000000;
		sim_Func = 6'b100010;
		#10;

		// instruction: SUBU
		sim_OP = 6'b000000;
		sim_Func = 6'b100011;
		#10;

		// instruction: AND
		sim_OP = 6'b000000;
		sim_Func = 6'b100100;
		#10;

		// instruction: OR
		sim_OP = 6'b000000;
		sim_Func = 6'b100101;
		#10;

		// instruction: XOR
		sim_OP = 6'b000000;
		sim_Func = 6'b100110;
		#10;

		// instruction: XNOR (using Func code 40)
		sim_OP = 6'b000000;
		sim_Func = 6'b101000;
		#10;

		// instruction: SLT
		sim_OP = 6'b000000;
		sim_Func = 6'b101010;
		#10;

		// instruction: SLTU
		sim_OP = 6'b000000;
		sim_Func = 6'b101011;
		#10;

		// don't need Func for non R-Type instructions
		sim_Func = 6'bxxxxxx;
		#10;

		// instruction: ADDI
		sim_OP = 6'b001000;
		#10;

		// instruction: ADDIU
		sim_OP = 6'b001001;
		#10;

		// instruction: ANDI
		sim_OP = 6'b001100;
		#10;

		// instruction: ORI
		sim_OP = 6'b001101;
		#10;

		// instruction: XORI
		sim_OP = 6'b001110;
		#10;

		// instruction: SLTI
		sim_OP = 6'b001010;
		#10;

		// instruction: SLTIU
		sim_OP = 6'b001011;
		#10;

		// instruction: LW
		sim_OP = 6'b100011;
		#10;

		// instruction: SW
		sim_OP = 6'b101011;
		#10;

		// instruction: LUI
		sim_OP = 6'b001111;
		#10;

		// instruction: BNE
		sim_OP = 6'b000101;
		#10;

		// instruction: BEQ
		sim_OP = 6'b000100;
		#10;

		// instruction: J
		sim_OP = 6'b000010;
		#10;

		$stop;
	end

endmodule
