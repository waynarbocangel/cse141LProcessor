/* CSE141L
   possible lookup table for PC target
   leverage a few-bit pointer to a wider number
   Lookup table acts like a function: here Target = f(Addr);
 in general, Output = f(Input); lots of potential applications 
*/
module LUT(
  input       [ 3:0] TapIndex,
  output logic[ 6:0] Tap
  );

always_comb begin
  case(TapIndex)		   
	3'b000:		Tap = 8'h60;   // -16, i.e., move back 16 lines of machine code
	3'b001:		Tap = 8'h48;
	3'b010:		Tap = 8'h78;
	3'b011:		Tap = 8'h72;
	3'b100:		Tap = 8'h6A;
	3'b101:		Tap = 8'h69;
	3'b110:		Tap = 8'h5C;
	3'b111:		Tap = 8'h7E;
	default:	Tap = 8'h7B;
  endcase
end

endmodule