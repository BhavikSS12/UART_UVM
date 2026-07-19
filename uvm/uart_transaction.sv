`ifndef UART_TRANSACTION_SV
`define UART_TRANSACTION_SV

class uart_transaction extends uvm_sequence_item;

    //------------------------------------------------------------
    // Factory Registration
    //------------------------------------------------------------
    `uvm_object_utils(uart_transaction)

    //------------------------------------------------------------
    // Stimulus Fields
    //------------------------------------------------------------
    rand bit [7:0] data;

    rand bit parity_type;

    //------------------------------------------------------------
    // Response Fields
    //------------------------------------------------------------
    bit [7:0] rx_data;

    bit rx_parity;

    bit error_flag;

    //------------------------------------------------------------
    // Error Injection Flags
    //------------------------------------------------------------
    rand bit inject_parity_error;

    rand bit inject_framing_error;

    rand bit inject_false_start;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name="uart_transaction");
        super.new(name);
    endfunction

    //------------------------------------------------------------
    // Constraints
    //------------------------------------------------------------
    constraint default_errors
    {
        inject_parity_error == 0;
        inject_framing_error == 0;
        inject_false_start  == 0;
    }

    //------------------------------------------------------------
    // Print Function
    //------------------------------------------------------------
    function string convert2string();
        return $sformatf(
            "data=8'h%02h, parity_type=%0b, rx_data=8'h%02h, rx_parity=%0b, error_flag=%0b, parity_err_inj=%0b, framing_err_inj=%0b, false_start_inj=%0b",
            data,
            parity_type,
            rx_data,
            rx_parity,
            error_flag,
            inject_parity_error,
            inject_framing_error,
            inject_false_start
        );
    endfunction

endclass

`endif