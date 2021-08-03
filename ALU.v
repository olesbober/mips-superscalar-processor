module ALU(input [31:0] In1, In2, input [3:0] Func, output reg [31:0] ALUout, output Zero);

 	wire [31:0] BB;		// output of first MUX in schematic connected to input B
 	wire [31:0] Sum;	// sum
 	wire Cout;		// carry out	
  
	assign BB = (Func[3]) ? ~In2 : In2 ; 
	assign {Cout, Sum} = Func[3] + In1 + BB ; 
	always @ (*) begin
		case (Func[2:0]) 					// Func[3] = 0 / Func[3] = 1
			3'b000 : ALUout <= In1 & BB;			// A AND B / A AND ~B
			3'b001 : ALUout <= In1 | BB;			// A OR B / A OR ~B
			3'b010 : ALUout <= Sum;				// + / -
			3'b011 : ALUout <= {31'd0, Sum[31]};		// NO OP / SLT
			3'b100 : ALUout <= In1 ^ BB;			// XOR / XNOR
			3'b101 : ALUout <= {BB, 16'd0};			// LUI / NO OP
		endcase
	end
	assign Zero = (ALUout == 0);
   
endmodule
