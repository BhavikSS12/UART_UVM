`ifndef UART_IF_SV
`define UART_IF_SV

interface uart_if(input logic clk);

    //-------------------------------------------------
    // Inputs to DUT
    //-------------------------------------------------
    logic rst;
    logic tx_start;
    logic parity_type;
    logic [7:0] data_in;

    //-------------------------------------------------
    // TX Outputs
    //-------------------------------------------------
    logic tx;
    logic tx_done;

    //-------------------------------------------------
    // RX Outputs
    //-------------------------------------------------
    logic [7:0] rx_msg;
    logic rx_parity;
    logic rx_busy;
    logic error_flag;

endinterface

`endif