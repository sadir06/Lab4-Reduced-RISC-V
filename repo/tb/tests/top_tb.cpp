// top_tb.cpp
// C++ testbench for RISC-V CPU
// Tests counter: counts 0 to 254 (255 values), then wraps to 0

#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtop.h"

// Comment this line to test with Vbuddy
#define NO_VBUDDY

#ifndef NO_VBUDDY
    #include "vbuddy.cpp"
#endif

int main(int argc, char **argv, char **env) {
    int i;
    int clk;
    int last_a0 = -1; // Start at -1 to detect first change to 0
    int instr_count = 0; 
    bool seen_254 = false; // Track if we have seen 254 before wrapping back to 0
    bool passed_test = false;
    
    Verilated::commandArgs(argc, argv);
    
    // Init the top module (CPU)
    Vtop* top = new Vtop;
    
    // Init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("top.vcd");

    // Init Vbuddy (if enabled)
    #ifndef NO_VBUDDY
    if (vbdOpen() != 1) return(-1);
    vbdHeader("Lab4: RISC-V CPU");
    #endif

    printf("RISC-V CPU Testbench\n");
    printf("Expected: a0 counts 0 to 254, wraps to 0\n");

    // Init simulation inputs
    top->clk = 1;
    top->rst = 1;

    // Run simulation for many clock cycles
    for (i=0; i<1000000; i++) {

        // Dump variables into VCD file and toggle clock
        for (clk=0; clk<2; clk++) {
            tfp->dump(2*i+clk);
            top->clk = !top->clk;
            top->eval();
        }
        
        // Release reset after 2 cycles
        if (i == 2) {
            top->rst = 0;
            printf("Cycle %5d: Reset released\n", i);
        }

        // Monitor after reset
        if (i > 2) {
            
            // Send count value to Vbuddy (if enabled)
            #ifndef NO_VBUDDY
            vbdHex(4, (int(top->a0) >> 16) & 0xF);
            vbdHex(3, (int(top->a0) >> 8) & 0xF);
            vbdHex(2, (int(top->a0) >> 4) & 0xF);
            vbdHex(1, int(top->a0) & 0xF);
            vbdPlot(int(top->a0) & 0xFF, 0, 254);
            vbdCycle(i+1);
            #endif
            
            // Detect when a0 changes (instruction executed)
            if (int(top->a0) != last_a0 && last_a0 >= 0) {
                instr_count++;
                
                int actual = int(top->a0) & 0xFF;
                int expected;
            
                // Calculate expected value
                // After 254 it should wrap to 0
                if (last_a0 == 254) {
                    expected = 0;
                    seen_254 = true;
                }
                // Increment normally 
                else {
                    expected = (last_a0 + 1) & 0xFF;
                }
                // Verify the value
                if (actual != expected) {
                    printf("[FAIL] Cycle %5d: Expected a0 = %d, got %d\n", i, expected, actual);
                    break;
                } else {
                    printf("[PASS] Cycle %5d: a0 = %3d (0x%08x)\n", i, actual, int(top->a0));
                }
                
                last_a0 = int(top->a0);
            } else if (last_a0 < 0 && int(top->a0) == 0) {
                printf("[PASS] Cycle %5d: a0 = %3d (0x%08x) [INITIAL]\n", i, 0, int(top->a0));
                last_a0 = 0;
            }

            // Success: seen 254 and wrapped to 0
            // Means that ADDI and BNE were correctly implemented
            if (seen_254 && (int(top->a0) & 0xFF) == 0 && instr_count > 250) {
                passed_test = true;
                printf("[SUCCESS] Counter completed full cycle!\n");
                printf("Counted from 0 to 254, then wrapped to 0\n");
                printf("Total cycles: %d\n", i);
                printf("Instructions executed: %d\n", instr_count);
                break;
            }
        }

        if (Verilated::gotFinish()) exit(0);
    }
    
    // Test failed
    // Either could not count to 254 or did not wrap back to 0
    if (!passed_test) {
        printf("[FAIL] Test failed!\n");
        if (!seen_254) {
            printf("Counter did not reach 254 within 1000000 cycles\n");
        } else {
            printf("Counter reached 254 but did not wrap correctly\n");
        }
        printf("Last a0: %d, Instructions: %d\n", int(top->a0) & 0xFF, instr_count);
    }

    // Clean up
    #ifndef NO_VBUDDY
    vbdClose();
    #endif
    
    tfp->close();
    delete top;
    delete tfp;
    
    exit(passed_test ? 0 : 1);
}