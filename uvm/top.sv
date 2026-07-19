`timescale 1ns/1ps

module top;

    //------------------------------------------------------------
    // Import Packages
    //------------------------------------------------------------
    import uvm_pkg::*;
    import uart_pkg::*;

    //------------------------------------------------------------
    // Clock
    //------------------------------------------------------------
    logic clk;

    initial
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    //------------------------------------------------------------
    // Interface
    //------------------------------------------------------------
    uart_if vif(clk);

    //------------------------------------------------------------
    // DUT : UART Transmitter
    //------------------------------------------------------------
    uart_tx tx_dut
    (
        .clk(vif.clk),
        .rst(vif.rst),
        .parity_type(vif.parity_type),
        .data_in(vif.data_in),
        .tx_start(vif.tx_start),
        .tx(vif.tx),
        .tx_done(vif.tx_done)
    );

    //------------------------------------------------------------
    // DUT : UART Receiver
    //------------------------------------------------------------
    uart_rx rx_dut
    (
        .clk(vif.clk),
        .rst(vif.rst),
        .rx(vif.tx),            // TX connected to RX
        .rx_msg(vif.rx_msg),
        .rx_parity(vif.rx_parity),
        .rx_busy(vif.rx_busy),
        .error_flag(vif.error_flag)
    );

    //------------------------------------------------------------
    // UVM Configuration
    //------------------------------------------------------------
    initial
    begin

        uvm_config_db #(virtual uart_if)::set(
            null,
            "*",
            "vif",
            vif
        );

        run_test("uart_test");

    end

endmodule