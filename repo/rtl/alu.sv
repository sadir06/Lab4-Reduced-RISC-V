module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        ALUAdd,          // 1 -> a+b, 0 -> a-b (or compare)
    output logic [31:0] result,
    output logic        not_equal        // (a != b)
);
    logic [31:0] sum, diff;

    assign sum  = a + b;
    assign diff = a - b;

    assign not_equal = (a != b);

    always_comb begin
        if (ALUAdd)
            result = sum;
        else
            result = diff;  // used only for subtraction/comparison
    end

endmodule
