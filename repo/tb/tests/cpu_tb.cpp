#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vriscv.h"
#include "vbuddy.cpp"

#define MAX_SIM_CYC 1000000

int main(int argc, char **argv, char **env) {
    int simcyc;
    int tick;
    int instr_count = 0;        // count number of instructions executed
    int last_a0 = 0;            // store the previous value for a0 to monitor changes
    bool passed_test = false;   // flag to indicate if test passed

    Verilated::commandArgs(argc, argv);

    // Instantiate the CPU
    Vriscv* top = new Vriscv;

    // Initialize VCD tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("riscv.vcd");

    // Initialize Vbuddy
    if (vbdOpen() != 1) return(-1);
    vbdHeader("Lab4: RISC-V CPU");
    vbdSetMode(1);

    // Initialize simulation inputs
    top->clk = 1;
    top->rst = 1;  // start with reset high

    // Run simulation for MAX_SIM_CYC clock cycles
    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++) {
        
        // Dump variables into VCD file and toggle clock
        for (tick = 0; tick < 2; tick++) {
            tfp->dump(2 * simcyc + tick);
            top->clk = !top->clk;
            top->eval();
        }

        // Release reset after 1 cycle
        if (simcyc == 1) {
            top->rst = 0;
            printf("Cycle %5d: Reset released\n", simcyc);
        }

        // Monitor and display after reset is released
        if (simcyc > 1) {
            
            // Display a0 register value on Vbuddy (counter output)
            vbdHex(4, (int(top->a0) >> 12) & 0xF);
            vbdHex(3, (int(top->a0) >> 8) & 0xF);
            vbdHex(2, (int(top->a0) >> 4) & 0xF);
            vbdHex(1, int(top->a0) & 0xF);

            // Plot counter value on Vbuddy (0-255)
            vbdPlot(int(top->a0) & 0xFF, 0, 255);
            vbdBar(int(top->a0) & 0xFF);
            
            // Detect instruction execution (a0 changed)
            if (int(top->a0) != last_a0) {
                instr_count++;
                
                // Check that a0 incremented by exactly 1
                // or wrapped from 255 to 0
                int expected_value = (last_a0 + 1) & 0xFF;
                int actual_value = int(top->a0) & 0xFF;
                
                if (actual_value != expected_value) {
                    printf("ERROR: ADDI failed! Expected %d, got %d\n", 
                           expected_value, actual_value);
                }

                last_a0 = int(top->a0);
            }

            // Update Vbuddy display
            vbdCycle(simcyc);

            // Success if counter reaches 255: a0 == a1 so does not branch
            if ((int(top->a0) & 0xFF) == 255) {
                passed_test = true;
                printf("Test passed\n");
                break;
            }
        }

        // Check if Verilator wants to finish
        if (Verilated::gotFinish()) {
            printf("\nSimulation finished early at cycle %d\n", simcyc);
            break;
        }
    }

    // If test didn't pass, print failure message
    if (!passed_test) {
        printf("Test failed\n");
        printf("Counter did not reach 255 within %d cycles\n", MAX_SIM_CYC);
        printf("Last value of a0: %d\n", int(top->a0) & 0xFF);
        printf("Instructions executed: %d\n", instr_count);
   
    }

    // Clean up
    vbdClose();
    tfp->close();
    delete top;
    delete tfp;

    return passed_test ? 0 : 1;
}