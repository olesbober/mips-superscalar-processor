module hazard_unit(input ALUSrc1D, ALUSrc2D,
			 Branch1D,
			 Jump1D, Jump2D,
			 MemtoReg1E, MemtoReg2E,
			 MemWrite1E, MemWrite2D,
			 Prediction1E, Prediction2E, 
			 RegWrite1M, RegWrite1W, RegWrite2M, RegWrite2W,
			 Taken1E, Taken2E,
	     input [4:0] Rd1D,
			 Rs1D, Rs2D,
			 Rs1E, Rs2E,
			 Rt1D, Rt2D,
			 Rt1E, Rt2E,
			 WriteReg1M, WriteReg1W, WriteReg2M, WriteReg2W,
	    input [31:0] ALUOut1E, ALUOut2E,
	      output reg Flush1D, Flush2D, Flush1E, Flush2E, Flush1M, Flush2M,
			 StallF, Stall1D, Stall2D, Stall1E, Stall2E, Stall1M, Stall2M, StallW,
	output reg [2:0] ForwardA1E, ForwardA2E, ForwardB1E, ForwardB2E);
	
	reg lwstall, memstall, samecyclestall, wrongprediction1, wrongprediction2;

	always @ (*) begin

		// INPUTS

		// lwstall logic
		// high when an instruction in Decode depends on a lw instruction in Execute
		lwstall = (((Rs1D == Rt1E) || (Rt1D == Rt1E) || (Rs2D == Rt1E) || (Rt2D == Rt1E)) && MemtoReg1E) ||
			  (((Rs1D == Rt2E) || (Rt1D == Rt2E) || (Rs2D == Rt2E) || (Rt2D == Rt2E)) && MemtoReg2E);

		// memstall logic
		// high when instruction 1 is a sw and instruction 2 is a lw with the same address
		memstall = MemWrite1E && MemtoReg2E && (ALUOut1E == ALUOut2E);

		// samecyclestall logic
		// high when instruction 2 depends on instruction 1, or if instruction 1 is a branch and instruction 2 is a jump
		if(!ALUSrc1D && !ALUSrc2D && !MemWrite2D) begin
			samecyclestall = ((Rs2D != 0) && (Rs2D == Rd1D)) || ((Rt2D != 0) && (Rt2D == Rd1D)) || (Branch1D && Jump2D);
		end else if(!ALUSrc1D && ALUSrc2D && !MemWrite2D) begin
			samecyclestall = (Rs2D != 0) && (Rs2D == Rd1D);
		end else if(ALUSrc1D && !ALUSrc2D && !MemWrite2D) begin
			samecyclestall = ((Rs2D != 0) && (Rs2D == Rt1D)) || ((Rt2D != 0) && (Rt2D == Rt1D));
		end else if(ALUSrc1D && ALUSrc2D && !MemWrite2D) begin
			samecyclestall = (Rs2D != 0) && (Rs2D == Rt1D);
		end else if(!ALUSrc1D && MemWrite2D) begin
			samecyclestall = ((Rt2D != 0) && (Rt2D == Rd1D)) || ((Rs2D != 0) && (Rs2D == Rd1D));
		end else if(ALUSrc1D && MemWrite2D) begin
			samecyclestall = ((Rt2D != 0) && (Rt2D == Rt1D)) || ((Rs2D != 0) && (Rs2D == Rt1D));
		end else begin
			samecyclestall = 1'b0;
		end

		// wrongprediction logic
		// high when a misprediction occurs
		wrongprediction1 = Taken1E ^ Prediction1E;
		wrongprediction2 = Taken2E ^ Prediction2E;

		// OUTPUTS

		// ForwardA1E logic
		if((Rs1E != 0) && (Rs1E == WriteReg2M) && (RegWrite2M))		ForwardA1E = 3'b001;
		else if((Rs1E != 0) && (Rs1E == WriteReg1M) && (RegWrite1M))	ForwardA1E = 3'b010;
		else if((Rs1E != 0) && (Rs1E == WriteReg2W) && (RegWrite2W))	ForwardA1E = 3'b011;
		else if((Rs1E != 0) && (Rs1E == WriteReg1W) && (RegWrite1W))	ForwardA1E = 3'b100;
		else								ForwardA1E = 3'b000;

		// ForwardA2E logic
		if((Rs2E != 0) && (Rs2E == WriteReg2M) && (RegWrite2M))		ForwardA2E = 3'b001;
		else if((Rs2E != 0) && (Rs2E == WriteReg1M) && (RegWrite1M))	ForwardA2E = 3'b010;
		else if((Rs2E != 0) && (Rs2E == WriteReg2W) && (RegWrite2W))	ForwardA2E = 3'b011;
		else if((Rs2E != 0) && (Rs2E == WriteReg1W) && (RegWrite1W))	ForwardA2E = 3'b100;
		else								ForwardA2E = 3'b000;

		// ForwardB1E logic
		if((Rt1E != 0) && (Rt1E == WriteReg2M) && (RegWrite2M))		ForwardB1E = 3'b001;
		else if((Rt1E != 0) && (Rt1E == WriteReg1M) && (RegWrite1M))	ForwardB1E = 3'b010;
		else if((Rt1E != 0) && (Rt1E == WriteReg2W) && (RegWrite2W))	ForwardB1E = 3'b011;
		else if((Rt1E != 0) && (Rt1E == WriteReg1W) && (RegWrite1W))	ForwardB1E = 3'b100;
		else								ForwardB1E = 3'b000;

		// ForwardB2E logic
		if((Rt2E != 0) && (Rt2E == WriteReg2M) && (RegWrite2M))		ForwardB2E = 3'b001;
		else if((Rt2E != 0) && (Rt2E == WriteReg1M) && (RegWrite1M))	ForwardB2E = 3'b010;
		else if((Rt2E != 0) && (Rt2E == WriteReg2W) && (RegWrite2W))	ForwardB2E = 3'b011;
		else if((Rt2E != 0) && (Rt2E == WriteReg1W) && (RegWrite1W))	ForwardB2E = 3'b100;
		else								ForwardB2E = 3'b000;

		// flush Decode 1:  if either of the instructions in Decode jump
		//		    if instruction 2 depends on instruction 1
		//		    if either of the instructions in Execute are mispredicted branches
		// flush Decode 2:  if instruction 1 is a jump
		//		    if the instruction 2 is a jump, and instruction 1 is not a branch or instruction 1 in Execute is a taken branch
		//		    if either of the instructions in Execute are mispredicted branches
		// flush Execute 1: if instruction 1 is a jump
		//		    if a lwstall occurs
		//		    if a memstall occurs
		//		    if either of the instructions in Execute are mispredicted branches	
		// flush Execute 2: if instruction 1 is a jump
		//		    if a lwstall occurs without a concurrent memstall
		//		    if instruction 2 depends on instruction 1
		//		    if either of the instructions in Execute are mispredicted branches
		// flush Memory 1:  if instruction 1 is a mispredicted branch
		// flush Memory 2:  if a memstall occurs
		//		    if the instruction 1 in Execute is a mispredictied branch

		Flush1D = Jump1D || (Jump2D && (~Branch1D && ~Taken1E)) || (samecyclestall && samecyclestall !== 1'bx) || wrongprediction1 || wrongprediction2;
		Flush2D = Jump1D || (Jump2D && (~Branch1D && ~Taken1E)) || wrongprediction1 || wrongprediction2;
		Flush1E = Jump1D || lwstall || memstall || wrongprediction1 || wrongprediction2;
		Flush2E = Jump1D || (lwstall && !memstall) || (samecyclestall && samecyclestall !== 1'bx) || wrongprediction1 || wrongprediction2;
		Flush1M = wrongprediction1;
		Flush2M = memstall || wrongprediction1;

		// stall Fetch:     if a lwstall occurs
		//		    if a memstall occurs
		//		    if instruction 2 depends on instruction 1
		// stall Decode 1:  if a lwstall occurs
		//		    if a memstall occurs
		// stall Decode 2:  if a lwstall occurs
		//		    if a memstall occurs
		//		    if instruction 2 depends on instruction 1
		// stall Execute 1: never stalls
		// stall Execute 2: if a memstall occurs
		// stall Memory 1:  never stalls
		// stall Memory 2:  never stalls
		// stall Writeback: never stalls

		StallF = lwstall || memstall || (samecyclestall && samecyclestall !== 1'bx);
		Stall1D = lwstall || memstall;
		Stall2D = lwstall || memstall || (samecyclestall && samecyclestall !== 1'bx);
		Stall1E = 1'b0;
		Stall2E = memstall;
		Stall1M = 1'b0;
		Stall2M = 1'b0;
		StallW = 1'b0;
	end

endmodule