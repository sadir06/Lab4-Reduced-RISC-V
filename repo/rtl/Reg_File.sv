module Reg_File (
    input logic [4:0] AD1,
    input logic [4:0] AD2,
    input logic [4:0] AD3,
    input logic       WE3,
    input logic [31:0] WD3,
    input logic        clk,

    output logic [31:0] RD1,
    output logic [31:0] RD2,
    output logic [31:0] a0
);

logic [31:0] rf[32]; // 32 registers of 32 bits each

//Ensures that all the registers are 0 at the start of simulation
initial begin
    for (int i = 0; i < 32; i++) begin
        rf[i] = 32'b0;
    end
end


always_ff @(posedge clk) begin
    if (WE3) begin
        //If write is high, write the data
        if (AD3 != 5'b0) begin
            rf[AD3] <= WD3; // Register 0 is hardwired to 0, block all writes
        end
    end
end

assign RD1 = rf[AD1]; // Read data from register AD1

assign RD2 = rf[AD2]; // Read data from register AD2

assign a0 = rf[10]; // Output the value of register x10 (a0), hardwired to adress 10 (register a0)

endmodule
