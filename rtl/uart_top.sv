// UART Top Module - Loopback Configuration for Testing
module uart_top #(
    parameter CLKS_PER_BIT = 868
)(
    input  logic       clk,
    input  logic       rst_n,
    
    // TX Interface
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_serial,
    output logic       tx_done,
    output logic       tx_active,
    
    // RX Interface
    input  logic       rx_serial,
    output logic [7:0] rx_data,
    output logic       rx_done,
    output logic       parity_error,
    output logic       frame_error
);

    // Instantiate UART Transmitter
    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_tx (
        .clk        (clk),
        .rst_n      (rst_n),
        .tx_start   (tx_start),
        .tx_data    (tx_data),
        .tx_serial  (tx_serial),
        .tx_done    (tx_done),
        .tx_active  (tx_active)
    );

    // Instantiate UART Receiver
    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) u_uart_rx (
        .clk          (clk),
        .rst_n        (rst_n),
        .rx_serial    (rx_serial),
        .rx_data      (rx_data),
        .rx_done      (rx_done),
        .parity_error (parity_error),
        .frame_error  (frame_error)
    );

endmodule