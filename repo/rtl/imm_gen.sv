module imm_gen (
    input  logic [31:0] instr,
    input  logic        is_b_type,   // 1 for branch, 0 for I-type
    output logic [31:0] imm
);
    logic [31:0] imm_i;
    logic [31:0] imm_b;
    logic [12:0] imm_b_raw;

    // I-type immediate (addi)
    assign imm_i = {{20{instr[31]}}, instr[31:20]};

    // B-type immediate (bne)
    // {imm[12], imm[10:5], imm[4:1], imm[11], 1'b0}
    assign imm_b_raw = {
        instr[31],      // imm[12]
        instr[7],       // imm[11]
        instr[30:25],   // imm[10:5]
        instr[11:8],    // imm[4:1]
        1'b0            // imm[0]
    };
    assign imm_b = {{19{imm_b_raw[12]}}, imm_b_raw};

    always_comb begin
        if (is_b_type)
            imm = imm_b;
        else
            imm = imm_i;
    end

endmodule
