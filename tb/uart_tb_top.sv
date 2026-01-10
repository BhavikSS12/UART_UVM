`timescale 1ns/1ps
// UART Testbench Top Module
`timescale 1ns/1ps

module uart_tb_top;
    
    import uvm_pkg::*;
    import uart_pkg::*;
    `include "uvm_macros.svh"
    
    // Clock generation
    logic clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Interface instantiation
    uart_interface vif(clk);
    
    // DUT instantiation with loopback
    uart_top #(
        .CLKS_PER_BIT(87)  // Faster for simulation: 100MHz / 1.15MHz ≈ 87
    ) dut (
        .clk          (vif.clk),
        .rst_n        (vif.rst_n),
        .tx_start     (vif.tx_start),
        .tx_data      (vif.tx_data),
        .tx_serial    (vif.tx_serial),
        .tx_done      (vif.tx_done),
        .tx_active    (vif.tx_active),
        .rx_serial    (vif.rx_serial),
        .rx_data      (vif.rx_data),
        .rx_done      (vif.rx_done),
        .parity_error (vif.parity_error),
        .frame_error  (vif.frame_error)
    );
    
    // Loopback connection for testing
    assign vif.rx_serial = vif.tx_serial;
    
    // UVM configuration and test start
    initial begin
        // Set interface in config_db
        uvm_config_db#(virtual uart_interface)::set(null, "*", "vif", vif);
        
        // Enable UVM verbosity
        uvm_top.set_report_verbosity_level(UVM_MEDIUM);
        
        // Run the test
        run_test();
    end
    
    // Waveform dump for debugging
    initial begin
        $dumpfile("uart_sim.vcd");
        $dumpvars(0, uart_tb_top);
    end
    
    // Timeout watchdog
    initial begin
        #10_000_000; // 10ms timeout
        `uvm_fatal("TIMEOUT", "Simulation timeout!")
        $finish;
    end
    
endmodule