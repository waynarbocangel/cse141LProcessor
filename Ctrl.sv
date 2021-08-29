// CSE141L
import definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
	input[ 8:0] Instruction,	   // machine code
	output logic	MemWrite,
					BranchEn,
					ALUSrc,
					RegWrite,
					NextLFSR,
					RegOut1,
					RegOut2,
					Ack,      // "done w/ program"
	output logic[1:0] 	MemToReg,
  						RegDest,
	output logic [3:0] ALUOp
  );

logic [1:0] S;

always_latch begin
	MemWrite = 0;
	BranchEn = 0;
	ALUSrc = 0;
	RegWrite = 0;
	NextLFSR = 0;
	RegOut1 = 0;
	RegOut2 = 0;
	MemToReg = 2'b00;
	RegDest = 2'b00;
	ALUOp = 4'b0000;
	if (Instruction[8:6] == 3'b110) begin
		S = Instruction[1:0];
	end
	else begin
		if (Instruction[8:6] == 3'b000 && S == 2'b00) begin
			MemToReg = 2'b01;
		end

		if (Instruction[8:6] == 3'b001 && S == 2'b11) begin
			MemToReg = 2'b11;
			RegDest = 2'b01;
		end

		if (Instruction[8:6] == 3'b011 && S == 2'b01) begin
			MemToReg = 2'b10;
			RegDest = 2'b10;
		end

		if (Instruction[8:6] == 3'b000 && S == 2'b01) begin
			MemWrite = 1;
		end

		if ((Instruction[8:6] == 3'b011 && (S == 2'b10 || S == 2'b11)) || (Instruction[8:6] == 3'b100 && S == 2'b01)) begin
			BranchEn = 1;
		end

		if ((Instruction[8:6] == 3'b000 && (S == 2'b00 || S == 2'b01)) || Instruction[8:6] == 3'b001) begin
			ALUSrc = 1;
		end

		if ((S != 2'b01 && (Instruction[8:6] == 3'b000 || Instruction[8:6] == 3'b010)) || Instruction[8:6] == 3'b001 || (Instruction[8:6] == 3'b011 && (S == 2'b00 || S == 2'b01)) || (Instruction[8:6] == 3'b100 && S == 2'b00)) begin
			RegWrite = 1;
		end

		if (Instruction[8:6] == 3'b010 && S == 2'b01) begin
			NextLFSR = 1;
		end

		if ((Instruction[8:6] == 3'b010 && S == 2'b00) && (Instruction[8:6] == 3'b100 && S == 2'b00)) begin
			RegOut1 = 1;
			RegOut2 = 1;
		end
		
		case (Instruction[8:6])
			3'b000: begin
				if (S == 2'b11) ALUOp = 4'b0001;
			end
			3'b001: begin
				if (S == 2'b00) ALUOp = 4'b0010;
				else if (S == 2'b01) ALUOp = 4'b0011;
				else ALUOp = 4'b0100; 
			end
			3'b010: begin
				if (S == 2'b11) ALUOp = 4'b0110;
				else ALUOp = 4'b0101;
			end
			3'b011: begin
				if (S == 2'b10) ALUOp = 4'b1000;
				else if (S == 2'b11) ALUOp = 4'b1001;
				else ALUOp = 4'b0111;
			end
			3'b100: begin
				if (S == 2'b00) ALUOp = 4'b1010;
				else ALUOp = 4'b1011;
			end 
		endcase

	end
end

assign Ack = (Instruction[8:6] == 3'b111) ? 1 : 0;

endmodule

