module reg_file(input Clk, Reset, WE1, WE2, input [4:0] A11, A21, A12, A22, WA1, WA2, input [31:0] WD1, WD2, output [31:0] RD11, RD21, RD12, RD22);

	integer	i;
	reg [31:0] regfile [31:0];

	always @ (posedge Clk) begin
		if(Reset) begin
			for (i = 0; i < 32; i = i + 1) begin
				regfile[i] <= 0;
			end
		end
		if(WE1) begin
			regfile[WA1] <= WD1;
		end
		if(WE2) begin
			regfile[WA2] <= WD2;
		end
	end

	assign RD11 = (A11 != 0) ? regfile[A11] : 0;
	assign RD21 = (A21 != 0) ? regfile[A21] : 0;
	assign RD12 = (A12 != 0) ? regfile[A12] : 0;
	assign RD22 = (A22 != 0) ? regfile[A22] : 0;

endmodule