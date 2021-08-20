module LFSR (
	input logic	NextLFSR,
				RegWrite,
	input logic [1:0] RegDest,
	input logic [6:0] DataIn,
	output logic [6:0] State
);
	logic[6:0] NextTap, NextState, Tap;
	logic[0:0] NextStateBit;
	logic StateChanged = 0;
	// Lookup table to handle 10-bit program counter jumps w/ only 2 bits
	LUT LUT1(.TapIndex (DataIn[3:0]),
         .Tap(NextTap)
    );

	always_latch begin
		if (RegWrite && RegDest == 2'b01) State = DataIn;
		else if (RegWrite && RegDest == 2'b10) Tap = NextTap; 
		NextState = Tap & State;
		NextStateBit = ^NextState;
		if (NextLFSR && !StateChanged) begin
			State = {State[5:0],NextStateBit};
			StateChanged = 1;
		end
		if (StateChanged && !NextLFSR) begin
			StateChanged = 0;
		end
	end

endmodule