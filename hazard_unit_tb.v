module hazard_unit_tb();

	 reg sim_ALUSrc1D, sim_ALUSrc2D,
	     sim_Branch1D,
	     sim_Jump1D, sim_Jump2D,
	     sim_MemtoReg1E, sim_MemtoReg2E,
	     sim_MemWrite1E, sim_MemWrite2D,
	     sim_Prediction1E, sim_Prediction2E,
	     sim_RegWrite1M, sim_RegWrite1W, sim_RegWrite2M, sim_RegWrite2W,
	     sim_Taken1E, sim_Taken2E;
   reg [4:0] sim_Rd1D,
	     sim_Rs1D, sim_Rs2D,
	     sim_Rs1E, sim_Rs2E,
	     sim_Rt1D, sim_Rt2D,
	     sim_Rt1E, sim_Rt2E,
	     sim_WriteReg1M, sim_WriteReg1W, sim_WriteReg2M, sim_WriteReg2W;
  reg [31:0] sim_ALUOut1E, sim_ALUOut2E;
	wire sim_Flush1D, sim_Flush2D, sim_Flush1E, sim_Flush2E, sim_Flush1M, sim_Flush2M,
	     sim_StallF, sim_Stall1D, sim_Stall2D, sim_Stall1E, sim_Stall2E, sim_Stall1M, sim_Stall2M, sim_StallW;
  wire [2:0] sim_ForwardA1E, sim_ForwardA2E, sim_ForwardB1E, sim_ForwardB2E;

	hazard_unit dut(
	.ALUSrc1D(sim_ALUSrc1D),
	.ALUSrc2D(sim_ALUSrc2D),
	.Branch1D(sim_Branch1D),
	.Jump1D(sim_Jump1D),
	.Jump2D(sim_Jump2D),
	.MemtoReg1E(sim_MemtoReg1E),
	.MemtoReg2E(sim_MemtoReg2E),
	.MemWrite1E(sim_MemWrite1E),
	.MemWrite2D(sim_MemWrite2D),
	.Prediction1E(sim_Prediction1E),
	.Prediction2E(sim_Prediction2E),
	.RegWrite1M(sim_RegWrite1M),
	.RegWrite1W(sim_RegWrite1W),
	.RegWrite2M(sim_RegWrite2M),
	.RegWrite2W(sim_RegWrite2W),
	.Taken1E(sim_Taken1E),
	.Taken2E(sim_Taken2E),
	.Rd1D(sim_Rd1D),
	.Rs1D(sim_Rs1D),
	.Rs2D(sim_Rs2D),
	.Rs1E(sim_Rs1E),
	.Rs2E(sim_Rs2E),
	.Rt1D(sim_Rt1D),
	.Rt2D(sim_Rt2D),
	.Rt1E(sim_Rt1E),
	.Rt2E(sim_Rt2E),
	.WriteReg1M(sim_WriteReg1M),
	.WriteReg1W(sim_WriteReg1W),
	.WriteReg2M(sim_WriteReg2M),
	.WriteReg2W(sim_WriteReg2W),
	.ALUOut1E(sim_ALUOut1E),
	.ALUOut2E(sim_ALUOut2E),
	.Flush1D(sim_Flush1D),
	.Flush2D(sim_Flush2D),
	.Flush1E(sim_Flush1E),
	.Flush2E(sim_Flush2E),
	.Flush1M(sim_Flush1M),
	.Flush2M(sim_Flush2M),
	.StallF(sim_StallF),
	.Stall1D(sim_Stall1D),
	.Stall2D(sim_Stall2D),
	.Stall1E(sim_Stall1E),
	.Stall2E(sim_Stall2E),
	.Stall1M(sim_Stall1M),
	.Stall2M(sim_Stall2M),
	.StallW(sim_StallW),
	.ForwardA1E(sim_ForwardA1E),
	.ForwardA2E(sim_ForwardA2E),
	.ForwardB1E(sim_ForwardB1E),
	.ForwardB2E(sim_ForwardB2E)
	);

	initial begin

		// test lwstall
		sim_MemtoReg1E = 1'b1;
		sim_Rs1D = 5'b00100;
		sim_Rt1E = 5'b00100;
		#10;
		sim_MemtoReg1E = 1'bx;
		sim_Rs1D = 5'bxxxxx;
		sim_Rt1E = 5'bxxxxx;

		// test memstall
		sim_MemWrite1E = 1'b1;
		sim_MemtoReg2E = 1'b1;
		sim_ALUOut1E = 32'h69696969;
		sim_ALUOut2E = 32'h69696969;
		#10;
		sim_MemWrite1E = 1'bx;
		sim_MemtoReg2E = 1'bx;
		sim_ALUOut1E = 32'hxxxxxxxx;
		sim_ALUOut2E = 32'hxxxxxxxx;

		// test samecyclestall
		sim_ALUSrc1D = 1'b0;
		sim_ALUSrc2D = 1'b0;
		sim_MemWrite2D = 1'b0;
		sim_Branch1D = 1'b1;
		sim_Jump2D = 1'b1;
		#10;
		sim_ALUSrc1D = 1'bx;
		sim_ALUSrc2D = 1'bx;
		sim_MemWrite2D = 1'bx;
		sim_Branch1D = 1'bx;
		sim_Jump2D = 1'bx;

		// test wrongprediction
		sim_Prediction1E = 1'b1;
		sim_Taken1E = 1'b0;
		#10;
		sim_Prediction1E = 1'bx;
		sim_Taken1E = 1'bx;
		sim_Prediction2E = 1'b0;
		sim_Taken2E = 1'b1;
		#10;
		sim_Prediction2E = 1'bx;
		sim_Taken2E = 1'bx;

		// test ForwardA1E
		sim_Rs1E = 5'b00100;
		sim_WriteReg2M = 5'b00100;
		sim_RegWrite2M = 1'b1;
		#10;
		sim_Rs1E = 5'bxxxxx;
		sim_WriteReg2M = 5'bxxxxx;
		sim_RegWrite2M = 1'bx;

		// test ForwardA2E
		sim_Rs2E = 5'b10000;
		sim_WriteReg1M = 5'b10000;
		sim_RegWrite1M = 1'b1;
		#10;
		sim_Rs2E = 5'bxxxxx;
		sim_WriteReg1M = 5'bxxxxx;
		sim_RegWrite1M = 1'b1;

		// test ForwardB1E
		sim_Rt1E = 5'b11111;
		sim_WriteReg2W = 5'b11111;
		sim_RegWrite2W = 1'b1;
		#10;
		sim_Rt1E = 5'bxxxxx;
		sim_WriteReg2W = 5'bxxxxx;
		sim_RegWrite2W = 1'bx;

		// test ForwardB2E
		sim_Rt2E = 5'b10101;
		sim_WriteReg1W = 5'b10101;
		sim_RegWrite1W = 1'b1;
		#10;
		sim_Rt2E = 5'bxxxxx;
		sim_WriteReg1W = 5'bxxxxx;
		sim_RegWrite1W = 1'bx;

		$stop;
	end

endmodule
