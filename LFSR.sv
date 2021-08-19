module LFSR (
	input logic	NextLFSR,
				RegWrite,
	input[1:0] logic RegDest,
	input[6:0] logic DataIn,
	output logic[6:0] State
);
	logic[6:0] NextTap, NextState, Tap;
	logic[0:0] NextStateBit;
	// Lookup table to handle 10-bit program counter jumps w/ only 2 bits
	LUT LUT1(.TapIndex (DataIn[3:0]),
         .Tap(NextTap)
    );

	always_latch begin
		if (RegWrite && RegDest == 2'b01) State = DataIn;
		else if (RegWrite && RegDest == 2'b10) Tap = NextTap; 
		NextState = Tap & State;
		NextStateBit = ^NextState;
	end

	always_ff @(posedge NextLFSR) begin 
		State <= {State[5:0],NextStateBit};
	end

endmodule