`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

class uart_sequence extends uvm_sequence #(uart_transaction);

    //------------------------------------------------------------
    // Factory Registration
    //------------------------------------------------------------
    `uvm_object_utils(uart_sequence)

    //------------------------------------------------------------
    // Transaction Handle
    //------------------------------------------------------------
    uart_transaction tr;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "uart_sequence");
        super.new(name);
    endfunction

    //------------------------------------------------------------
    // Sequence Body
    //------------------------------------------------------------
    virtual task body();

        repeat(20)
        begin

            //----------------------------------------------------
            // Create Transaction
            //----------------------------------------------------
            tr = uart_transaction::type_id::create("tr");

            //----------------------------------------------------
            // Randomize Transaction
            //----------------------------------------------------
            assert(tr.randomize())
            else
                `uvm_error("SEQ","Randomization Failed")

            //----------------------------------------------------
            // Send Transaction
            //----------------------------------------------------
            start_item(tr);

            finish_item(tr);

            //----------------------------------------------------
            // Print
            //----------------------------------------------------
            `uvm_info("SEQ",
                      tr.convert2string(),
                      UVM_LOW)

        end

    endtask

endclass

`endif