// This module "wraps" the Register File, the MUX, and the ALU
// as shown in the brown box in the diagram from the lab document.
module top_ALU (
    input logic        clk,       // Clock for Reg File
    input logic [4:0]  AD1,       // Read Address 1 (rs1)
    input logic [4:0]  AD2,       // Read Address 2 (rs2)
    input logic [4:0]  AD3,       // Write Address (rd)
    input logic        WE3,       // Reg Write Enable
    input logic        ALUSrc,    // MUX select signal
    input logic        ALUAdd,   // ALU control (Add/Sub)
    input logic [31:0] ImmOp,     // Immediate data from Sign Extend
    
    // --- Outputs from the Block ---
    output logic        EQ,       // EQ flag to Control Unit
    output logic [31:0] a0        // Special output for testing
);

    // --- 1. INTERNAL WIRES ---
    logic [31:0] w_RD1;
    logic [31:0] w_RD2;
    logic [31:0] w_ALUOut;
    logic [31:0] w_ALUop2;

    
    // --- 2. COMPONENT INSTANCES ---

    Reg_File rf_inst (
        .clk(clk),
        .AD1(AD1),
        .AD2(AD2),
        .AD3(AD3),
        .WE3(WE3),
        .WD3(w_ALUOut),
        .RD1(w_RD1),
        .RD2(w_RD2),
        .a0(a0)
    );

    
    alu alu_inst (
        .a(w_RD1),
        .b(w_ALUop2),
        .ALUAdd(ALUAdd),
        .result(w_ALUOut),
        .EQ(EQ)
    );

    
    // --- 3. MUX LOGIC ---
    assign w_ALUop2 = (ALUSrc) ? ImmOp : w_RD2;


endmodule