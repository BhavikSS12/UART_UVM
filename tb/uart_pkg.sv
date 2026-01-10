// UART UVM Package - With Separate Test Files
package uart_pkg;
    
    // Import UVM package
    import uvm_pkg::*;
    
    // Include UVM macros
    `include "uvm_macros.svh"
    
    // ========================================
    // Include Verification Components
    // ========================================
    
    // Transaction (used by everyone)
    `include "uart_transaction.sv"
    
    // Sequencer (uses transaction)
    `include "uart_sequencer.sv"
    
    // Sequences (use transaction)
    `include "uart_sequence.sv"
    
    // Driver (uses transaction)
    `include "uart_driver.sv"
    
    // Monitor (uses transaction)
    `include "uart_monitor.sv"
    
    // Agent (uses driver, sequencer, monitor)
    `include "uart_agent.sv"
    
    // Scoreboard (uses transaction)
    `include "uart_scoreboard.sv"
    
    // Environment (uses agent, scoreboard)
    `include "uart_env.sv"
    
    // ========================================
    // Include Test Files (Separate Files)
    // ========================================
    
    `include "tests/uart_base_test.sv"
    `include "tests/uart_random_test.sv"
    `include "tests/uart_sequential_test.sv"
    `include "tests/uart_corner_test.sv"
    `include "tests/uart_burst_test.sv"
    `include "tests/uart_comprehensive_test.sv"
    
endpackage : uart_pkg