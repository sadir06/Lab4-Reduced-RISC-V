// top.sv
// Single-cycle “reduced” RISC-V CPU
// Supports: ADDI (I-type) and BNE (B-type)
// Exposes register x10 (a0) as the output.

module top #(
    parameter ADDR_WIDTH = 8,          // instruction address bits for RAM
    parameter DATA_WIDTH = 32          // 32-bit datapath
)(
    input  logic                   clk,
    input  logic                   rst,
    output logic [DATA_WIDTH-1:0]  a0
);

    // ==============================
    // PC and Instruction Fetch
    // ==============================
    logic [31:0] pc, pc_next;
    logic [31:0] inc_pc, branch_pc;

    logic [31:0] instr;

    // PC register
    pc_reg pc_reg_i (
        .clk     (clk),
        .rst     (rst),
        .pc_next (pc_next),
        .pc      (pc)
    );

    // Instruction memory (asynchronous)
    // Use word address = pc[ADDR_WIDTH+1 : 2] (drop the 2 LSBs)
    ram #(
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (32)
    ) prog_mem (
        .addr (pc[ADDR_WIDTH+1:2]),
        .dout (instr)
    );

    // Compute pc + 4 (sequential) and pc + ImmOp (branch)
    assign inc_pc    = pc + 32'd4;

    // ImmOp will be driven by imm_gen below, but we can declare it now
    logic [31:0] ImmOp;
    assign branch_pc = pc + ImmOp;


    // ==============================
    // Instruction Decode
    // ==============================
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [4:0] rs1, rs2, rd;

    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];


    // ==============================
    // Control Unit
    // ==============================
    logic RegWrite;
    logic ALUSrc;
    logic Branch;
    logic IsBType;
    logic ALUAdd;
    logic CompareNotEqual;

    control_unit cu (
        .opcode          (opcode),
        .funct3          (funct3),
        .RegWrite        (RegWrite),
        .ALUSrc          (ALUSrc),
        .Branch          (Branch),
        .IsBType         (IsBType),
        .ALUAdd          (ALUAdd),
        .CompareNotEqual (CompareNotEqual)
    );


    // ==============================
    // Immediate Generator
    // ==============================
    imm_gen immgen (
        .instr     (instr),
        .is_b_type (IsBType),
        .imm       (ImmOp)
    );


    // ==============================
    // Datapath: Reg File + ALU block
    // ==============================
    logic EQ;   // ALU equality flag

    top_ALU datapath (
        .clk     (clk),
        .AD1     (rs1),
        .AD2     (rs2),
        .AD3     (rd),
        .WE3     (RegWrite),
        .ALUSrc  (ALUSrc),
        .ALUCtrl (ALUAdd),   // 1 = add, 0 = sub/compare
        .ImmOp   (ImmOp),
        .EQ      (EQ),
        .a0      (a0)
    );


    // ==============================
    // Branch Decision and Next PC
    // ==============================
    logic PCSrc;

    // For BNE, CompareNotEqual = 1 → branch when ~EQ.
    // (If you later add BEQ, CompareNotEqual = 0 → branch when EQ.)
    assign PCSrc  = Branch & (CompareNotEqual ? ~EQ : EQ);

    // PC mux: 0 → pc+4, 1 → pc+ImmOp
    assign pc_next = PCSrc ? branch_pc : inc_pc;

endmodule

