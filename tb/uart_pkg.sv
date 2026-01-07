`timescale 1ns/1ps
// UART UVM Package
package uart_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Include all UVM components
    `include "uart_transaction.sv"
    `include "uart_sequencer.sv"
    `include "uart_sequence.sv"
    `include "uart_driver.sv"
    `include "uart_monitor.sv"
    `include "uart_agent.sv"
    `include "uart_scoreboard.sv"
    `include "uart_env.sv"
    `include "uart_test.sv"
    
endpackage