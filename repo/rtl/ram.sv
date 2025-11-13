module ram #(
    parameter ADDR_WIDTH = 8,
              DATA_WIDTH = 32
)(
    input  logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] dout
);
    logic [DATA_WIDTH-1:0] ram_array [0:(2**ADDR_WIDTH)-1];
    
    // ✅ ADD THIS: Initialize with your program
    initial begin
        // Fill with NOPs
        for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
            ram_array[i] = 32'h00000013;  // NOP
        end
        
        // Load your Lab 4 program
        ram_array[8'h00] = 32'h0ff00313;  // li t1, 255
        ram_array[8'h01] = 32'h00000513;  // li a0, 0
        ram_array[8'h02] = 32'h00000593;  // li a1, 0 (mloop)
        ram_array[8'h03] = 32'h00058513;  // mv a0, a1 (iloop)
        ram_array[8'h04] = 32'h00158593;  // addi a1, a1, 1
        ram_array[8'h05] = 32'hfe659ce3;  // bne a1, t1, iloop
        ram_array[8'h06] = 32'hfe0318e3;  // bnez t1, mloop
    end
    
    // Asynchronous read
    always_comb begin
        dout = ram_array[addr];
    end
    
endmodule
