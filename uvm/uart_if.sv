`ifndef UART_IF_SV
`define UART_IF_SV

interface uart_if(input logic clk);

    // Inputs to DUT
    logic rst;
    logic tx_start;
    logic parity_type;
    logic [7:0] data_in;

    // TX Outputs
    logic tx;
    logic tx_done;

    // RX Outputs
    logic [7:0] rx_msg;
    logic rx_parity;
    logic rx_busy;
    logic error_flag;

    // Error Injection signals (driven by driver, overrides tx to rx)
    logic rx_in;
    logic inject_enable;
    logic inject_value;

    assign rx_in = inject_enable ? inject_value : tx;

    //clocking block driver
    clocking driver_cb @(posedge clk);
        default input #1step output #1ns;
        output rst , tx_start , parity_type, data_in;
        output inject_enable, inject_value;
        input tx , tx_done;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1step output #1ns;
        input rst , tx_start , tx , tx_done;
        input rx_msg , rx_parity , rx_busy , error_flag;
        input inject_enable, inject_value, rx_in;
    endclocking

    modport DRIVER (clocking driver_cb , input clk);
    modport MONITOR (clocking monitor_cb , input clk);

endinterface

`endif