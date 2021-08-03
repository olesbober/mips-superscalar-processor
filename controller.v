module controller (input [5:0] OP, Func,
		   output reg MemtoReg, MemRead, MemWrite,
		   output reg ALUSrcA,
		   output reg RegDst, RegWrite,
		   output reg Jump, Branch, 
		   output reg Se_ze,
		   output reg [3:0] ALU_Op);

	// All signals:
	// MemtoReg:		1 if something in memory needs to be written to a register, 0 otherwise
	// MemRead:		1 if data memory needs to be read from, 0 otherwise
	// MemWrite:		1 if something needs to be written to data memory, 0 otherwise
	// ALUSrcA:		1 if the ALU needs to use an immediate value, 0 if both operands are in registers
	// RegDst:		1 if R-Type instruction, 0 otherwise
	// RegWrite:		1 if the register file needs to be accessed, 0 otherwise
	// Jump:		1 if jump instruction, 0 otherwise
	// Branch:		1 if branch instruction, 0 otherwise
	// Se_ze:		1 if sign extension needs to be used, 0 if zero extension needs to be used
	// ALU_Op [3:0]:	selects the ALU operation needed for instruction
	
	always @ (*) begin
		casex(OP)
			6'b000000: // R-TYPE
			begin
				casex(Func)	
					6'b100000: // ADD
					begin
						ALU_Op = 4'b0010;
					end
					6'b100001: // ADDU
					begin
						ALU_Op = 4'b0010;
					end
					6'b100010: // SUB
					begin
						ALU_Op = 4'b1010;
					end
					6'b100011: // SUBU
					begin
						ALU_Op = 4'b1010;
					end
					6'b100100: // AND
					begin
						ALU_Op = 4'b0000;
					end
					6'b100101: // OR
					begin
						ALU_Op = 4'b0001;
					end
					6'b100110: // XOR
					begin
						ALU_Op = 4'b0100;
					end
					6'b101010: // SLT
					begin
						ALU_Op = 4'b1011;
					end
					6'b101011: // SLTU
					begin
						ALU_Op = 4'b1011;
					end
					6'b101000: // XNOR (I will be using Func code 40, 6'b101000)
					begin
						ALU_Op = 4'b1100;
					end
				endcase
				RegWrite = 1'b1;
				RegDst = 1'b1;
				ALUSrcA = 1'b0;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				Se_ze = 1'b0;				
				if(Func == 6'b000000) begin	// for dealing with bubbles (or NOP)
					RegWrite = 1'b0;
					RegDst = 1'b0;
					ALUSrcA = 1'b0;
					Branch = 1'b0;
					MemRead = 1'b0;
					MemWrite = 1'b0;
					MemtoReg = 1'b0;
					Jump = 1'b0;
					ALU_Op = 4'bxxxx;
					Se_ze = 1'b0;
				end
			end
			6'b001000: // ADDI
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b0010;
				Se_ze = 1'b1;
			end
			6'b001001: // ADDIU
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b0010;
				Se_ze = 1'b1;
			end
			6'b001100: // ANDI
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b0000;
				Se_ze = 1'b0;
			end
			6'b001101: // ORI
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b0001;
				Se_ze = 1'b0;
			end
			6'b001110: // XORI
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b0100;
				Se_ze = 1'b0;
			end
			6'b001010: // SLTI
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b1011;
				Se_ze = 1'b1;
			end
			6'b001011: // SLTIU
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b1011;
				Se_ze = 1'b1;
			end
			6'b100011: // LW
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b1;
				MemWrite = 1'b0;
				MemtoReg = 1'b1;
				Jump = 1'b0;
				ALU_Op = 4'b0010;
				Se_ze = 1'b1;
			end
			6'b101011: // SW
			begin
				RegWrite = 1'b0;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b1;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b0010;
				Se_ze = 1'b1;
			end
			6'b001111: // LUI
			begin
				RegWrite = 1'b1;
				RegDst = 1'b0;
				ALUSrcA = 1'b1;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b1;
				Jump = 1'b0;
				ALU_Op = 4'b0101;
				Se_ze = 1'b1;
			end
			6'b000100: // BEQ
			begin
				RegWrite = 1'b0;
				RegDst = 1'b0;
				ALUSrcA = 1'b0;
				Branch = 1'b1;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b1010;
				Se_ze = 1'b1;
			end
			6'b000101: // BNE
			begin
				RegWrite = 1'b0;
				RegDst = 1'b0;
				ALUSrcA = 1'b0;
				Branch = 1'b1;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b0;
				ALU_Op = 4'b1010;
				Se_ze = 1'b1;
			end
			6'b000010: // J
			begin
				RegWrite = 1'b0;
				RegDst = 1'b0;
				ALUSrcA = 1'b0;
				Branch = 1'b0;
				MemRead = 1'b0;
				MemWrite = 1'b0;
				MemtoReg = 1'b0;
				Jump = 1'b1;
				ALU_Op = 4'b0000;
				Se_ze = 1'b0;
			end
			default: // illegal operation
			begin
				RegWrite = 1'bx;
				RegDst = 1'bx;
				ALUSrcA = 1'bx;
				Branch = 1'bx;
				MemRead = 1'bx;
				MemWrite = 1'bx;
				MemtoReg = 1'bx;
				Jump = 1'bx;
				ALU_Op = 4'bxxxx;
				Se_ze = 1'bx;
			end
		endcase
	end
endmodule