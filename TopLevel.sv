// Revision Date:    2020.08.05
// Design Name:    BasicProcessor
// Module Name:    TopLevel 
// CSE141L
// partial only										   
module TopLevel(		   // you will have the same 3 ports
    input        Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );

wire [ 9:0] PgmCtr,        // program counter
			PCTarg;
wire [ 8:0] Instruction;   // our 9-bit opcode
wire [ 7:0] ReadA, ReadB;  // reg_file outputs
wire [ 7:0] InA, InB, 	   // ALU operand inputs
            ALU_out;       // ALU result
wire [ 7:0] RegWriteValue, // data in to reg file
	   	    MemReadValue;  // data out from data_memory
wire        MemWrite,	   // data_memory write enable
			BranchEn,	   // to program counter: branch enable
			ALUSrc,
			RegWrite,	   // reg_file write enable
			NextLFSR,
			RegOut1,
			RegOut2,
			BranchFlag;		   // ALU output = 0 flag
wire [1:0]	MemToReg,
			RegDest;
wire [3:0]	ALUOp;
logic[15:0] CycleCt;	   // standalone; NOT PC!

// Fetch stage = Program Counter + Instruction ROM
  ProgCtr PC1 (		             // this is the program counter module
	.Reset        (Reset),   // reset to 0
	.Start        (Start),   // SystemVerilog shorthand for .grape(grape) is just .grape 
	.Clk          (Clk),   //    here, (Clk) is required in Verilog, optional in SystemVerilog
	.BranchRel    (BranchEn),  // branch enable
	.ALUFlag	  (ALUFlag),
    .Target       (PCTarg),   // "where to?" or "how far?" during a jump or branch
	.ProgCtr      (PgmCtr)	 // program count = index to instruction memory
	);					  

// instruction memory -- holds the machine code pointed to by program counter
  InstROM #(.W(9)) IR1(
	.InstAddress  (PgmCtr), 
	.InstOut      (Instruction)
	);

// Decode stage = Control Decoder + Reg_file
// Control decoder
  Ctrl Ctrl1 (
	.Instruction  	(Instruction) ,  // from instr_ROM
	.MemWrite		(MemWrite),
	.BranchEn    	(BranchEn),  // to PC
	.ALUSrc			(ALUSrc),
	.RegWrite      	(RegWrite),  // register file write enable
	.NextLFSR		(NextLFSR),
	.RegOut1		(RegOut1),
	.RegOut2		(RegOut2),
	.MemToReg		(MemToReg),
	.RegDest		(RegDest),
	.ALUOp			(ALUOp),
    .Ack          	(Ack)	   // "done" flag
  );

// reg file
	RegFile #(.W(8),.A(3)) RF1 (			  // D(3) makes this 8 elements deep
 	  .Clk,
	  .RegWrite  (RegWrite), 
	  .RegOut1	 (RegOut1),
	  .RegOut2	 (RegOut2),
	  .NextLFSR	 (NextLFSR),
	  .RegDest	 (RegDest),
	  .RaddrA    (Instruction[5:3]),        //concatenate with 0 to give us 4 bits
	  .RaddrB    (Instruction[2:0]), 
	  .Waddr     (Instruction[5:3]), 	      // mux above
	  .DataIn    (RegWriteValue), 
	  .DataOutA  (ReadA), 
	  .DataOutB  (ReadB)
	);
/* one pointer, two adjacent read accesses: 
  (sample optional approach)
	.raddrA ({Instruction[5:3],1'b0});
	.raddrB ({Instruction[5:3],1'b1});
*/
    assign InA = ReadA;						  // connect RF out to ALU in
	assign InB = ALUSrc ? {5'b00000, Instruction[2:0]} : ReadB;	          			  // interject switch/mux if needed/desired
// controlled by Ctrl1 -- must be high for load from data_mem; otherwise usually low
	assign RegWriteValue = (MemToReg == 2'b00)? ALU_out : ((MemToReg == 2'b01) ? MemReadValue : ((MemToReg == 2'b10) ? {2'b00, Instruction[5:0]} : ReadA));  // 2:1 switch into reg_file
    ALU ALU1  (
	  .InputA  (InA),
	  .InputB  (InB), 
	  .OP      (ALUOp),
	  .Out     (ALU_out),                    //regWriteValue),
	  .BranchFlag (BranchFlag)                       // status flag; may have others, if desired
	  );
  
	DataMem DM1(
		.DataAddress  (ALU_out), 
		.MemWrite     (MemWrite), 
		.DataIn       (ReadA), 
		.DataOut      (MemReadValue) , 
		.Clk,
		.Reset		  (Reset)
	);
	
/* count number of instructions executed
      not part of main design, potentially useful
      This one halts when Ack is high  
*/
always_ff @(posedge Clk)
  if (Reset)	   // if(start)
  	CycleCt <= 0;
  else if(Ack == 0)   // if(!halt)
  	CycleCt <= CycleCt+16'b1;

endmodule