`timescale 1ns/1ps
// UART Interface
interface uart_interface(input logic clk);
    
    logic       rst_n;
    logic       tx_start;
    logic [7:0] tx_data;
    logic       tx_serial;
    logic       tx_done;
    logic       tx_active;
    logic       rx_serial;
    logic [7:0] rx_data;
    logic       rx_done;
    logic       parity_error;
    logic       frame_error;

    // Clocking blocks for synchronous operation
    clocking driver_cb @(posedge clk);
        default input #1 output #1;
        output rst_n;
        output tx_start;
        output tx_data;
        input  tx_done;
        input  tx_active;
        input  tx_serial;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1 output #1;
        input rst_n;
        input tx_start;
        input tx_data;
        input tx_serial;
        input tx_done;
        input tx_active;
        input rx_serial;
        input rx_data;
        input rx_done;
        input parity_error;
        input frame_error;
    endclocking

    // Modports
    modport DRIVER  (clocking driver_cb, input clk, output rx_serial);
    modport MONITOR (clocking monitor_cb, input clk);

endinterface