module ram #(
    parameter ADDR_WIDTH = 8,
              DATA_WIDTH = 32
)(
    input  logic [ADDR_WIDTH-1:0] addr,       // word address
    output logic [DATA_WIDTH-1:0] dout        // instruction
);
    logic [DATA_WIDTH-1:0] ram_array [0:(2**ADDR_WIDTH)-1];
    
    initial begin
        $readmemh("program.mem", ram_array);
    end



    // Asynchronous read: output changes as soon as addr changes
    always_comb begin
        dout = ram_array[addr];
    end
    
endmodule
