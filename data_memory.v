module data_memory(input Clk, RE1, RE2, WE1, WE2, input [31:0] A1, A2, WD1, WD2, output reg [31:0] RD1, RD2);

	reg [31:0] RAM [999:0];	// 1000 elements, 32 bits wide

	always @ (posedge Clk) begin
		if(RE1) begin
			RD1 = RAM[A1[31:0]];
		end
		if(RE2) begin
			RD2 = RAM[A2[31:0]];
		end
		if(WE1) begin
			RAM[A1[31:0]] = WD1;
		end
		if(WE2) begin
			RAM[A2[31:0]] = WD2;
		end
	end

endmodule