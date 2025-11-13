// pc_logic.sv
// Handles PC increment, branch target calculation, and PC source selection
module pc_logic (
    input  logic [31:0] pc_current,      // current PC value
    input  logic [31:0] imm,             // immediate offset (for branch)
    input  logic        branch,          // branch control signal from CU
    input  logic        not_equal,       // comparison result from ALU
    input  logic        compare_not_eq,  // 1=BNE (branch if !=), 0=BEQ (branch if ==)
    output logic [31:0] pc_next          // next PC value
);
    logic [31:0] pc_plus_4;
    logic [31:0] pc_target;
    logic        pc_src;  // 1: take branch, 0: sequential
    
    // Calculate PC + 4 (next sequential instruction)
    assign pc_plus_4 = pc_current + 32'd4;
    
    // Calculate branch target address (PC + offset)
    assign pc_target = pc_current + imm;
    
    // Decide whether to take the branch
    // BNE: branch if not_equal is true
    // BEQ: branch if not_equal is false (i.e., equal)
    assign pc_src = branch & (compare_not_eq ? not_equal : ~not_equal);
    
    // Select next PC: branch target or PC+4
    assign pc_next = pc_src ? pc_target : pc_plus_4;

endmodule
