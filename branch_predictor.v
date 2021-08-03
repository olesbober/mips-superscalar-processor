module branch_predictor(input clk, reset, WE1, WE2, US1, US2, T1, T2, input [31:0] RA1, RA2, WA1, WA2, WD1, WD2, output P1, P2, output [31:0] RD1, RD2);

	// this is a local-history two-level predictor with a target address cache of 2^10 entries, a BHT of 2^12 entries, and a PHT of 2^12 entries

	wire [9:0] read_index1, read_index2, write_index1, write_index2;			// PC prediction is indexed with last ten bits of the PC
	wire [11:0] bht_read_index1, bht_read_index2, bht_write_index1, bht_write_index2;	// branch prediction is indexed with the last ten bits of the PC and the branch history table
	wire [11:0] pht_read_index1, pht_read_index2, pht_write_index1, pht_write_index2;
	reg [1:0] branch_history_table [4095:0];						// 4096 elements, 2 bits wide
	reg [31:0] predicted_pc [1023:0];							// 1024 elements, 32 bits wide
	reg [1:0] pattern_history_table [4095:0];						// 4096 elements, 2 bits wide
	integer i;

	assign read_index1 = RA1[11:2];								// last 10 bits of PC are used for indexing
	assign read_index2 = RA2[11:2];								// ignore the last two bits of PC because of byte addressing
	assign write_index1 = WA1[11:2];
	assign write_index2 = WA2[11:2];
	assign bht_read_index1 = RA1[13:2];							// last 12 bits of PC used for BHT indexing
	assign bht_read_index2 = RA2[13:2];
	assign bht_write_index1 = WA1[13:2];
	assign bht_write_index2 = WA2[13:2];
	assign pht_read_index1 = {read_index1, branch_history_table[bht_read_index1]};		// create the PHT indexes
	assign pht_read_index2 = {read_index2, branch_history_table[bht_read_index2]};
	assign pht_write_index1 = {write_index1, branch_history_table[bht_write_index1]};
	assign pht_write_index2 = {write_index2, branch_history_table[bht_write_index2]};

	always @ (posedge clk) begin
		if(reset) begin
			for(i = 0; i < 1024; i = i + 1) begin
				predicted_pc[i] = 32'hxxxxxxxx;
			end
			for(i = 0; i < 4096; i = i + 1) begin
				branch_history_table[i] = 2'b00;
				pattern_history_table[i] = 2'b00;
			end
		end
		if(WE1) begin
			predicted_pc[write_index1] = WD1;					// store the predicted PC in the buffer, will keep the state as it was for simplicty
		end
		if(WE2) begin
			predicted_pc[write_index2] = WD2;
		end
		if(US1) begin
			// BRANCH HISTORY TABLE
			branch_history_table[bht_write_index1] = {branch_history_table[bht_write_index1][0], T1};

			// PATTERN HISTORY TABLE
			if(pattern_history_table[pht_write_index1] == 2'b00) begin		// STRONGLY NOT TAKEN STATE
				if(T1 == 1'b1) begin						// if branch was T1
					pattern_history_table[pht_write_index1] = 2'b01;	// set state to weakly not taken
				end								// if branch was not taken, stay in strongly not taken state
			end else if(pattern_history_table[pht_write_index1] == 2'b01) begin	// WEAKLY NOT TAKEN STATE
				if(T1 == 1'b1) begin						// if branch was taken
					pattern_history_table[pht_write_index1] = 2'b10;	// set state to weakly taken
				end else begin							// if branch was not taken
					pattern_history_table[pht_write_index1] = 2'b00;	// set state to strongly not taken
				end
			end else if(pattern_history_table[pht_write_index1] == 2'b10) begin	// WEAKLY TAKEN STATE
				if(T1 == 1'b1) begin						// if branch was taken
					pattern_history_table[pht_write_index1] = 2'b11;	// set state to strongly taken
				end else begin							// if branch was not taken
					pattern_history_table[pht_write_index1] = 2'b01;	// set state to weakly not taken
				end
			end else begin								// STRONGLY TAKEN STATE
				if(T1 == 1'b0) begin						// if branch was not taken
					pattern_history_table[pht_write_index1] = 2'b10;	// set state to weakly taken
				end								// if branch was taken, stay in strongly taken state
			end
		end
		if(US2) begin
			// BRANCH HISTORY TABLE
			branch_history_table[bht_write_index2] = {branch_history_table[bht_write_index2][0], T2};

			// PATTERN HISTORY TABLE
			if(pattern_history_table[pht_write_index2] == 2'b00) begin		// STRONGLY NOT TAKEN STATE
				if(T2 == 1'b1) begin						// if branch was T1
					pattern_history_table[pht_write_index2] = 2'b01;	// set state to weakly not taken
				end								// if branch was not taken, stay in strongly not taken state
			end else if(pattern_history_table[pht_write_index2] == 2'b01) begin	// WEAKLY NOT TAKEN STATE
				if(T2 == 1'b1) begin						// if branch was taken
					pattern_history_table[pht_write_index2] = 2'b10;	// set state to weakly taken
				end else begin							// if branch was not taken
					pattern_history_table[pht_write_index2] = 2'b00;	// set state to strongly not taken
				end
			end else if(pattern_history_table[pht_write_index2] == 2'b10) begin	// WEAKLY TAKEN STATE
				if(T2 == 1'b1) begin						// if branch was taken
					pattern_history_table[pht_write_index2] = 2'b11;	// set state to strongly taken
				end else begin							// if branch was not taken
					pattern_history_table[pht_write_index2] = 2'b01;	// set state to weakly not taken
				end
			end else begin								// STRONGLY TAKEN STATE
				if(T2 == 1'b0) begin						// if branch was not taken
					pattern_history_table[pht_write_index2] = 2'b10;	// set state to weakly taken
				end								// if branch was taken, stay in strongly taken state
			end
		end
	end

	assign RD1 = predicted_pc[read_index1];
	assign RD2 = predicted_pc[read_index2];
	assign P1 = pattern_history_table[pht_read_index1][1];	// MSB of the state in the PHT is the prediction
	assign P2 = pattern_history_table[pht_read_index2][1];

endmodule