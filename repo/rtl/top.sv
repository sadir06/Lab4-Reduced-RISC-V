module top #(
    parameter DATA_WIDTH = 32
) (
    input  logic                    clk,
    input  logic                    rst,
    output logic [DATA_WIDTH-1:0]   a0    
);

    // Internal signals

    // PC signals
    logic [31:0] pc_current;
    logic [31:0] pc_next;
    
    // Instruction and fields
    logic [31:0] instr;
    logic [6:0]  opcode;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    
    // Control signals
    logic RegWrite;
    logic ALUSrc;
    logic Branch;
    logic IsBType;
    logic ALUAdd;
    logic CompareNotEqual;
    
    // Datapath signals
    logic [31:0] imm;
    logic [31:0] reg_data1, reg_data2;
    logic [31:0] alu_op2;
    logic [31:0] alu_result;
    logic        not_equal;
    
    // Instruction Decode (extract fields)
    assign opcode = instr[6:0];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    
    // PC Logic 
    pc_logic pc_logic_inst (
        .pc_current(pc_current),
        .imm(imm),
        .branch(Branch),
        .not_equal(not_equal),
        .compare_not_eq(CompareNotEqual),
        .pc_next(pc_next)
    );
    
    pc_reg pc_register (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc_current)
    );
    
    
    // Instruction Memory
    ram #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32)
    ) instruction_memory (
        .addr(pc_current[9:2]),  // word-aligned: PC[9:2] for byte addressing
        .dout(instr)
    );
    
    
    // Control Unit
    control_unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .IsBType(IsBType),
        .ALUAdd(ALUAdd),
        .CompareNotEqual(CompareNotEqual)
    );
    
    // Immediate Generator
    imm_gen immediate_generator (
        .instr(instr),
        .is_b_type(IsBType),
        .imm(imm)
    );
    

    // Register File
    Reg_File register_file (
        .clk(clk),
        .AD1(rs1),
        .AD2(rs2),
        .AD3(rd),
        .WE3(RegWrite),
        .WD3(alu_result),
        .RD1(reg_data1),
        .RD2(reg_data2),
        .a0(a0)              // Connect a0 output to top-level port
    );
    
    
    // ALU Input Multiplexer
    mux #(
        .DATA_WIDTH(32)
    ) alu_src_mux (
        .in0(reg_data2),     // use rs2 register value
        .in1(imm),           // use immediate value
        .sel(ALUSrc),
        .out(alu_op2)
    );
    

    // ALU
    alu alu_inst (
        .a(reg_data1),
        .b(alu_op2),
        .ALUAdd(ALUAdd),
        .result(alu_result),
        .not_equal(not_equal)
    );

endmodule
