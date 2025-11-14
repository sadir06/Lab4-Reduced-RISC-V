// Asynchronous 32-bit instruction RAM for RISC-V program memory

module ram #(
    parameter ADDR_WIDTH = 8,                 // number of instruction addresses
              DATA_WIDTH = 32                 // 32-bit RISC-V instructions
)(
    input  logic [ADDR_WIDTH-1:0] addr,       // word address
    output logic [DATA_WIDTH-1:0] dout        // instruction
);

    // RAM array: 2^ADDR_WIDTH entries of 32 bits
    logic [DATA_WIDTH-1:0] ram_array [0:(2**ADDR_WIDTH)-1];
    
    initial begin
        $readmemh("program.mem", ram_array);
    end



    // Asynchronous read: output changes as soon as addr changes
    always_comb begin
        dout = ram_array[addr];
    end
endmodule
