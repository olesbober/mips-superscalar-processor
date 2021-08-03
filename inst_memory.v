module inst_memory(input [31:0] A1, A2, output [31:0] RD1, RD2);

	reg [31:0] RAM [63:0]; // 64 elements, 32 bits wide

	initial begin
		$readmemh("fibonacci_sequence.dat", RAM);
	end
	
	assign RD1 = RAM[A1[31:2]];
	assign RD2 = RAM[A2[31:2]];

endmodule