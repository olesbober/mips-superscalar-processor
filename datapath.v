module datapath(input Clk, Reset);
	
	// WIRES IN NEXTPC STAGE
	wire [31:0] PC1JumpN, PC2JumpN, PCCBN, PCCNBN, PCJN, PCPN, PCPredict1N, PCPredict2N;

	// WIRES IN FETCH STAGE
	wire Prediction1F, Prediction2F, StallF;
	wire [31:0] Instr1F, Instr2F, PC1F, PC1Plus8F, PC2F;

	// WIRES IN DECODE STAGE
	wire ALUSrc1D, ALUSrc2D, Branch1D, Branch2D, Flush1D, Flush2D, Jump1D, Jump2D, MemRead1D, MemRead2D, MemtoReg1D, MemtoReg2D, MemWrite1D, MemWrite2D,
	     Prediction1D, Prediction2D, RegDst1D, RegDst2D, RegWrite1D, RegWrite2D, SeZe1D, SeZe2D, Stall1D, Stall2D;
	wire [3:0] ALUControl1D, ALUControl2D;
	wire [4:0] Rd1D, Rd2D, Rs1D, Rs2D, Rt1D, Rt2D;
	wire [31:0] ExtImm1D, ExtImm2D, Instr1D, Instr2D, PC1D, PC2D, PC1Plus4D, PC2Plus4D, PCBranch1D, PCBranch2D,
		    RD11D, RD12D, RD21D, RD22D, SignExt1D, SignExt2D, ZeroExt1D, ZeroExt2D;

	// WIRES IN EXECUTE STAGE
	wire ALUSrc1E, ALUSrc2E, Branch1E, Branch2E, BufferWrite1E, BufferWrite2E, Correction1E, Correction2E, EqNe1E, EqNe2E, Flush1E, Flush2E, MemRead1E,
	     MemRead2E, MemtoReg1E, MemtoReg2E, MemWrite1E, MemWrite2E, PCSrc1E, PCSrc2E, Prediction1E, Prediction2E,  RegDst1E, RegDst2E, RegWrite1E,
	     RegWrite2E, Stall1E, Stall2E, Taken1E, Taken2E, Zero1E, Zero2E;
	wire [2:0] ForwardA1E, ForwardA2E, ForwardB1E, ForwardB2E;
	wire [3:0] ALUControl1E, ALUControl2E;
	wire [4:0] Rd1E, Rd2E, Rs1E, Rs2E, Rt1E, Rt2E, WriteReg1E, WriteReg2E;
	wire [31:0] ALUOut1E, ALUOut2E, ExtImm1E, ExtImm2E, PC1E, PC2E, PC1Plus4E, PC2Plus4E, PCBranch1E, PCBranch2E, RD11E, RD12E, RD21E, RD22E, SrcA1E,
		    SrcA2E, SrcB1E, SrcB2E, WriteData1E, WriteData2E;

	// WIRES IN MEMORY STAGE
	wire Flush1M, Flush2M, MemRead1M, MemRead2M, MemtoReg1M, MemtoReg2M, MemWrite1M, MemWrite2M, RegWrite1M, RegWrite2M, Stall1M, Stall2M;
	wire [4:0] WriteReg1M, WriteReg2M;
	wire [31:0] ALUOut1M, ALUOut2M, ReadData1M, ReadData2M, WriteData1M, WriteData2M;

	// WIRES IN WRITEBACK STAGE
	wire MemtoReg1W, MemtoReg2W, RegWrite1W, RegWrite2W, StallW;
	wire [4:0] WriteReg1W, WriteReg2W;
	wire [31:0] ALUOut1W, ALUOut2W, ReadData1W, ReadData2W, Result1W, Result2W;

	// NEXTPC STAGE
	assign PC1JumpN = {PC1Plus4D[31:28], Instr1D[25:0], 2'b00};
	assign PC2JumpN = {PC2Plus4D[31:28], Instr2D[25:0], 2'b00};
	mux4#(32) pcp_mux(PC1Plus8F, PCPredict2N, PCPredict1N, PCPredict1N, {Prediction1F, Prediction2F}, PCPN);
	mux4#(32) pcj_mux(PCPN, PC2JumpN, PC1JumpN, PC1JumpN, {Jump1D, Jump2D && (~Branch1E || (Branch1E && (Prediction1E ^ Taken1E)))}, PCJN);
	mux4#(32) pccb_mux(PCJN, PC2Plus4E, PC1Plus4E, PC1Plus4E, {Correction1E, Correction2E}, PCCBN);
	mux4#(32) pccnb_mux(PCCBN, PCBranch2E, PCBranch1E, PCBranch1E, {BufferWrite1E, BufferWrite2E}, PCCNBN);

	// PIPELINE BETWEEN NEXTPC AND FETCH
	flopr#(32) nf_pipeline1(Clk, Reset, ~StallF, PCCNBN, PC1F);

	// FETCH STAGE
	assign PC2F = PC1F + 32'h4;
	branch_predictor branch_target_buffer(Clk, Reset, BufferWrite1E, BufferWrite2E, Branch1E && ~ Stall1E, Branch2E && ~Stall2E, Taken1E, Taken2E,
					      PC1F, PC2F, PC1E, PC2E, PCBranch1E, PCBranch2E, Prediction1F, Prediction2F, PCPredict1N, PCPredict2N);
	inst_memory instruction_memory(PC1F, PC2F, Instr1F, Instr2F);
	assign PC1Plus8F = PC1F + 32'h8;

	// PIPELINE BETWEEN FETCH AND DECODE
	flopr#(1) fd_pipeline_1(Clk, Flush1D || Reset, ~Stall1D, Prediction1F, Prediction1D);
	flopr#(1) fd_pipeline_2(Clk, Flush2D || Reset, ~Stall2D, Prediction2F, Prediction2D);
	flopr#(32) fd_pipeline_3(Clk, Flush1D || Reset, ~Stall1D, PC1F, PC1D);
	flopr#(32) fd_pipeline_4(Clk, Flush2D || Reset, ~Stall2D, PC2F, PC2D);
	flopr#(32) fd_pipeline_5(Clk, Flush1D || Reset, ~Stall1D, Instr1F, Instr1D);
	flopr#(32) fd_pipeline_6(Clk, Flush2D || Reset, ~Stall2D, Instr2F, Instr2D);
	flopr#(32) fd_pipeline_7(Clk, Flush1D || Reset, ~Stall1D, PC2F, PC1Plus4D);
	flopr#(32) fd_pipeline_8(Clk, Flush2D || Reset, ~Stall2D, PC1Plus8F, PC2Plus4D);

	// DECODE STAGE
	assign Rd1D = Instr1D[15:11];
	assign Rd2D = Instr2D[15:11];
	assign Rs1D = Instr1D[25:21];
	assign Rs2D = Instr2D[25:21];
	assign Rt1D = Instr1D[20:16];
	assign Rt2D = Instr2D[20:16];
	controller control_unit1(Instr1D[31:26], Instr1D[5:0], MemtoReg1D, MemRead1D, MemWrite1D, ALUSrc1D, RegDst1D, RegWrite1D, Jump1D,
				 Branch1D, SeZe1D, ALUControl1D);
	controller control_unit2(Instr2D[31:26], Instr2D[5:0], MemtoReg2D, MemRead2D, MemWrite2D, ALUSrc2D, RegDst2D, RegWrite2D, Jump2D,
				 Branch2D, SeZe2D, ALUControl2D);
	reg_file register_file(~Clk, Reset, RegWrite1W, RegWrite2W, Instr1D[25:21], Instr1D[20:16], Instr2D[25:21], Instr2D[20:16],
			       WriteReg1W, WriteReg2W, Result1W, Result2W, RD11D, RD21D, RD12D, RD22D);
	assign SignExt1D = {{16{Instr1D[15]}}, Instr1D[15:0]};
	assign SignExt2D = {{16{Instr2D[15]}}, Instr2D[15:0]};
	assign ZeroExt1D = {16'h0000, Instr1D[15:0]};
	assign ZeroExt2D = {16'h0000, Instr2D[15:0]};
	assign PCBranch1D = {SignExt1D[29:0], 2'b00} + PC1Plus4D;
	assign PCBranch2D = {SignExt2D[29:0], 2'b00} + PC2Plus4D;
	mux2#(32) seze1_mux(ZeroExt1D, SignExt1D, SeZe1D, ExtImm1D);
	mux2#(32) seze2_mux(ZeroExt2D, SignExt2D, SeZe2D, ExtImm2D);

	// PIPELINE BETWEEN DECODE AND EXECUTE
	flopr#(1) de_pipeline_1(Clk, Flush1E || Reset, ~Stall1E, Branch1D, Branch1E);
	flopr#(1) de_pipeline_2(Clk, Flush2E || Reset, ~Stall2E, Branch2D, Branch2E);
	flopr#(1) de_pipeline_3(Clk, Flush1E || Reset, ~Stall1E, RegWrite1D, RegWrite1E);
	flopr#(1) de_pipeline_4(Clk, Flush2E || Reset, ~Stall2E, RegWrite2D, RegWrite2E);
	flopr#(1) de_pipeline_5(Clk, Flush1E || Reset, ~Stall1E, MemRead1D, MemRead1E);
	flopr#(1) de_pipeline_6(Clk, Flush2E || Reset, ~Stall2E, MemRead2D, MemRead2E);
	flopr#(1) de_pipeline_7(Clk, Flush1E || Reset, ~Stall1E, MemtoReg1D, MemtoReg1E);
	flopr#(1) de_pipeline_8(Clk, Flush2E || Reset, ~Stall2E, MemtoReg2D, MemtoReg2E);
	flopr#(1) de_pipeline_9(Clk, Flush1E || Reset, ~Stall1E, MemWrite1D, MemWrite1E);
	flopr#(1) de_pipeline_10(Clk, Flush2E || Reset, ~Stall2E, MemWrite2D, MemWrite2E);
	flopr#(4) de_pipeline_11(Clk, Flush1E || Reset, ~Stall1E, ALUControl1D, ALUControl1E);
	flopr#(4) de_pipeline_12(Clk, Flush2E || Reset, ~Stall2E, ALUControl2D, ALUControl2E);
	flopr#(1) de_pipeline_13(Clk, Flush1E || Reset, ~Stall1E, ALUSrc1D, ALUSrc1E);
	flopr#(1) de_pipeline_14(Clk, Flush2E || Reset, ~Stall2E, ALUSrc2D, ALUSrc2E);
	flopr#(1) de_pipeline_15(Clk, Flush1E || Reset, ~Stall1E, RegDst1D, RegDst1E);
	flopr#(1) de_pipeline_16(Clk, Flush2E || Reset, ~Stall2E, RegDst2D, RegDst2E);
	flopr#(1) de_pipeline_17(Clk, Flush1E || Reset, ~Stall1E, Instr1D[26], EqNe1E);
	flopr#(1) de_pipeline_18(Clk, Flush2E || Reset, ~Stall2E, Instr2D[26], EqNe2E);
	flopr#(32) de_pipeline_19(Clk, Flush1E || Reset, ~Stall1E, RD11D, RD11E);
	flopr#(32) de_pipeline_20(Clk, Flush2E || Reset, ~Stall2E, RD12D, RD12E);
	flopr#(32) de_pipeline_21(Clk, Flush1E || Reset, ~Stall1E, RD21D, RD21E);
	flopr#(32) de_pipeline_22(Clk, Flush2E || Reset, ~Stall2E, RD22D, RD22E);
	flopr#(5) de_pipeline_23(Clk, Flush1E || Reset, ~Stall1E, Rs1D, Rs1E);
	flopr#(5) de_pipeline_24(Clk, Flush2E || Reset, ~Stall2E, Rs2D, Rs2E);
	flopr#(5) de_pipeline_25(Clk, Flush1E || Reset, ~Stall1E, Rt1D, Rt1E);
	flopr#(5) de_pipeline_26(Clk, Flush2E || Reset, ~Stall2E, Rt2D, Rt2E);
	flopr#(5) de_pipeline_27(Clk, Flush1E || Reset, ~Stall1E, Rd1D, Rd1E);
	flopr#(5) de_pipeline_28(Clk, Flush2E || Reset, ~Stall2E, Rd2D, Rd2E);
	flopr#(32) de_pipeline_29(Clk, Flush1E || Reset, ~Stall1E, ExtImm1D, ExtImm1E);
	flopr#(32) de_pipeline_30(Clk, Flush2E || Reset, ~Stall2E, ExtImm2D, ExtImm2E);
	flopr#(32) de_pipeline_31(Clk, Flush1E || Reset, ~Stall1E, PCBranch1D, PCBranch1E);
	flopr#(32) de_pipeline_32(Clk, Flush2E || Reset, ~Stall2E, PCBranch2D, PCBranch2E);
	flopr#(32) de_pipeline_33(Clk, Flush1E || Reset, ~Stall1E, PC1D, PC1E);
	flopr#(32) de_pipeline_34(Clk, Flush2E || Reset, ~Stall2E, PC2D, PC2E);
	flopr#(1) de_pipeline_35(Clk, Flush1E || Reset, ~Stall1E, Prediction1D, Prediction1E);
	flopr#(1) de_pipeline_36(Clk, Flush2E || Reset, ~Stall2E, Prediction2D, Prediction2E);
	flopr#(32) de_pipeline_37(Clk, Flush1E || Reset, ~Stall1E, PC1Plus4D, PC1Plus4E);
	flopr#(32) de_pipeline_38(Clk, Flush2E || Reset, ~Stall2E, PC2Plus4D, PC2Plus4E);

	// EXECUTE STAGE
	assign BufferWrite1E = Taken1E && ~Prediction1E;
	assign BufferWrite2E = Taken2E && ~Prediction2E;
	assign Correction1E = ~Taken1E && Prediction1E;
	assign Correction2E = ~Taken2E && Prediction2E;
	mux2#(5) regdst1_mux(Rt1E, Rd1E, RegDst1E, WriteReg1E);
	mux2#(5) regdst2_mux(Rt2E, Rd2E, RegDst2E, WriteReg2E);
	mux8#(32) forwarda1e_mux(RD11E, ALUOut2M, ALUOut1M, Result2W, Result1W, 32'hxxxxxxxx, 32'hxxxxxxxx, 32'hxxxxxxxx, ForwardA1E, SrcA1E);
	mux8#(32) forwarda2e_mux(RD12E, ALUOut2M, ALUOut1M, Result2W, Result1W, 32'hxxxxxxxx, 32'hxxxxxxxx, 32'hxxxxxxxx, ForwardA2E, SrcA2E);
	mux8#(32) forwardb1e_mux(RD21E, ALUOut2M, ALUOut1M, Result2W, Result1W, 32'hxxxxxxxx, 32'hxxxxxxxx, 32'hxxxxxxxx, ForwardB1E, WriteData1E);
	mux8#(32) forwardb2e_mux(RD22E, ALUOut2M, ALUOut1M, Result2W, Result1W, 32'hxxxxxxxx, 32'hxxxxxxxx, 32'hxxxxxxxx, ForwardB2E, WriteData2E);
	mux2#(32) regimm1_mux(WriteData1E, ExtImm1E, ALUSrc1E, SrcB1E);
	mux2#(32) regimm2_mux(WriteData2E, ExtImm2E, ALUSrc2E, SrcB2E);
	ALU alu1(SrcA1E, SrcB1E, ALUControl1E, ALUOut1E, Zero1E);
	ALU alu2(SrcA2E, SrcB2E, ALUControl2E, ALUOut2E, Zero2E);
	mux2#(1) equality1_mux(Zero1E, ~Zero1E, EqNe1E, PCSrc1E);
	mux2#(1) equality2_mux(Zero2E, ~Zero2E, EqNe2E, PCSrc2E);
	assign Taken1E = Branch1E && PCSrc1E;
	assign Taken2E = Branch2E && PCSrc2E;

	// PIPELINE BETWEEN EXECUTE AND MEMORY
	flopr#(1) em_pipeline_1(Clk, Flush1M || Reset, ~Stall1M, RegWrite1E, RegWrite1M);
	flopr#(1) em_pipeline_2(Clk, Flush2M || Reset, ~Stall2M, RegWrite2E, RegWrite2M);
	flopr#(1) em_pipeline_3(Clk, Flush1M || Reset, ~Stall1M, MemRead1E, MemRead1M);
	flopr#(1) em_pipeline_4(Clk, Flush2M || Reset, ~Stall2M, MemRead2E, MemRead2M);
	flopr#(1) em_pipeline_5(Clk, Flush1M || Reset, ~Stall1M, MemtoReg1E, MemtoReg1M);
	flopr#(1) em_pipeline_6(Clk, Flush2M || Reset, ~Stall2M, MemtoReg2E, MemtoReg2M);
	flopr#(1) em_pipeline_7(Clk, Flush1M || Reset, ~Stall1M, MemWrite1E, MemWrite1M);
	flopr#(1) em_pipeline_8(Clk, Flush2M || Reset, ~Stall2M, MemWrite2E, MemWrite2M);
	flopr#(32) em_pipeline_9(Clk, Flush1M || Reset, ~Stall1M, ALUOut1E, ALUOut1M);
	flopr#(32) em_pipeline_10(Clk, Flush2M || Reset, ~Stall2M, ALUOut2E, ALUOut2M);
	flopr#(32) em_pipeline_11(Clk, Flush1M || Reset, ~Stall1M, WriteData1E, WriteData1M);
	flopr#(32) em_pipeline_12(Clk, Flush2M || Reset, ~Stall2M, WriteData2E, WriteData2M);
	flopr#(5) em_pipeline_13(Clk, Flush1M || Reset, ~Stall1M, WriteReg1E, WriteReg1M);
	flopr#(5) em_pipeline_14(Clk, Flush2M || Reset, ~Stall2M, WriteReg2E, WriteReg2M);

	// MEMORY STAGE
	data_memory data_mem(~Clk, MemRead1M, MemRead2M, MemWrite1M, MemWrite2M, ALUOut1M, ALUOut2M, WriteData1M, WriteData2M, ReadData1M, ReadData2M);

	// PIPELINE BETWEEN MEMORY AND WRITEBACK
	flopr#(1) mw_pipeline_1(Clk, Reset, ~StallW, RegWrite1M, RegWrite1W);
	flopr#(1) mw_pipeline_2(Clk, Reset, ~StallW, RegWrite2M, RegWrite2W);
	flopr#(1) mw_pipeline_3(Clk, Reset, ~StallW, MemtoReg1M, MemtoReg1W);
	flopr#(1) mw_pipeline_4(Clk, Reset, ~StallW, MemtoReg2M, MemtoReg2W);
	flopr#(32) mw_pipeline_5(Clk, Reset, ~StallW, ReadData1M, ReadData1W);
	flopr#(32) mw_pipeline_6(Clk, Reset, ~StallW, ReadData2M, ReadData2W);
	flopr#(32) mw_pipeline_7(Clk, Reset, ~StallW, ALUOut1M, ALUOut1W);
	flopr#(32) mw_pipeline_8(Clk, Reset, ~StallW, ALUOut2M, ALUOut2W);
	flopr#(5) mw_pipeline_9(Clk, Reset, ~StallW, WriteReg1M, WriteReg1W);
	flopr#(5) mw_pipeline_10(Clk, Reset, ~StallW, WriteReg2M, WriteReg2W);

	// WRITEBACK STAGE
	mux2#(32) result1_mux(ALUOut1W, ReadData1W, MemtoReg1W, Result1W);
	mux2#(32) result2_mux(ALUOut2W, ReadData2W, MemtoReg2W, Result2W);

	// HAZARD UNIT
	hazard_unit haz_unit(ALUSrc1D, ALUSrc2D, Branch1D, Jump1D, Jump2D, MemtoReg1E, MemtoReg2E, MemWrite1E, MemWrite2D, Prediction1E, Prediction2E,
			     RegWrite1M, RegWrite1W, RegWrite2M, RegWrite2W, Taken1E, Taken2E, Rd1D, Rs1D, Rs2D, Rs1E, Rs2E, Rt1D, Rt2D, Rt1E, Rt2E, WriteReg1M,
			     WriteReg1W, WriteReg2M, WriteReg2W, ALUOut1E, ALUOut2E, Flush1D, Flush2D, Flush1E, Flush2E, Flush1M, Flush2M, StallF, Stall1D, Stall2D,
			     Stall1E, Stall2E, Stall1M, Stall2M, StallW, ForwardA1E, ForwardA2E, ForwardB1E, ForwardB2E);

endmodule

// flip-flop with reset and enable
module flopr#(parameter WIDTH=8) (input clk, reset, enable, input [WIDTH-1:0] d, output reg [WIDTH-1:0] q);
	always @(posedge clk) begin
		if (reset) q <= 0;
		else if (enable) q <= d;
	end
endmodule

module mux2#(parameter WIDTH=8) (input [WIDTH-1:0] d0, d1, input s, output [WIDTH-1:0] y);
	assign y = s ? d1 : d0;
endmodule

module mux4#(parameter WIDTH=8) (input [WIDTH-1:0] d0, d1, d2, d3, input [1:0] s, output reg [WIDTH-1:0] y);
	always @(*) begin
		casex(s)
			2'b00: y = d0;
			2'b01: y = d1;
			2'b10: y = d2;
			2'b11: y = d3;
		endcase
	end
endmodule

module mux8#(parameter WIDTH=8) (input [WIDTH-1:0] d0, d1, d2, d3, d4, d5, d6, d7, input [2:0] s, output reg [WIDTH-1:0] y);
	always @(*) begin
		casex(s)
			3'b000: y = d0;
			3'b001: y = d1;
			3'b010: y = d2;
			3'b011: y = d3;
			3'b100: y = d4;
			3'b101: y = d5;
			3'b110: y = d6;
			3'b111: y = d7;
		endcase
	end
endmodule