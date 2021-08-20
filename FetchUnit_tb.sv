module FetchUnit_tb;
    bit Reset = 'b1,
        Start = 'b1,
        Clk;
    logic [9:0] counter;
    logic [8:0] Instruction;
    logic finished = 0;
    InstROM InstructionMemory(.InstAddress(counter), .InstOut(Instruction));
    ProgCtr ProgramCounter(.Reset, .Start, .Clk, .BranchRel(0), .ALUFlag(0), .Target(0), .ProgCtr(counter));
    initial begin
        #10ns Reset = 0;
        #10ns Start = 0;
        for (int i = 0; i < 30; i++) begin
            #10ns $displayb(Instruction);
            if (i == 29) finished = 1;
        end
        wait(finished);
        #10ns $stop;
    end

    always begin   // clock period = 10 Verilog time units
        #5ns  Clk = 'b1;
        #5ns  Clk = 'b0;
    end
endmodule