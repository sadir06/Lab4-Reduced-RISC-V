// control_unit.sv
//   - ADDI (I-type)
//   - BNE  (B-type branch)

module control_unit (
    input  logic [6:0] opcode,   // instr[6:0]
    input  logic [2:0] funct3,   // instr[14:12]
    output logic       RegWrite,       // write to rd?
    output logic       ALUSrc,         // 1: use immediate, 0: use rs2
    output logic       Branch,         // is this a branch?
    output logic       IsBType,        // 1: use B-type immediate, 0: I-type
    output logic       ALUAdd,         // 1: ALU does add, 0: ALU does sub/compare
    output logic       CompareNotEqual // 1: branch on not equal (BNE)
);

    // RISC-V opcode constants
    localparam OPCODE_OP_IMM = 7'b0010011; // I-type arithmetic (ADDI)
    localparam OPCODE_BRANCH = 7'b1100011; // B-type branches (BNE, BEQ, etc)

    always_comb begin
        RegWrite        = 1'b0;
        ALUSrc          = 1'b0;
        Branch          = 1'b0;
        IsBType         = 1'b0;
        ALUAdd          = 1'b1;  // default to ADD
        CompareNotEqual = 1'b0;


        unique case (opcode)
            // ================================
            // I-TYPE: ADDI
            // ================================
            OPCODE_OP_IMM: begin
                // ADDI rd, rs1, imm
                RegWrite        = 1'b1;   // write result to rd
                ALUSrc          = 1'b1;   // second ALU operand is immediate
                Branch          = 1'b0;   // not a branch
                IsBType         = 1'b0;   // use I-type immediate
                ALUAdd          = 1'b1;   // ALU does add
                CompareNotEqual = 1'b0;   // not used
            end

            // ================================
            // B-TYPE: BNE
            // ================================
            OPCODE_BRANCH: begin
                // We only care about BNE here:
                //   funct3 = 3'b001 => BNE
                Branch          = 1'b1;                 // this is a branch
                IsBType         = 1'b1;                 // use B-type immediate format
                ALUSrc          = 1'b0;                 // compare rs1 and rs2
                RegWrite        = 1'b0;                 // branches don't write rd
                ALUAdd          = 1'b0;                 // ALU can be used as subtract/compare
                CompareNotEqual = (funct3 == 3'b001);   // 1 for BNE
            end

            default: begin
            end
        endcase
    end

endmodule
