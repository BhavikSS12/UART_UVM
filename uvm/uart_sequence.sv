`ifndef UART_SEQUENCE_SV
`define UART_SEQUENCE_SV

class uart_sequence extends uvm_sequence #(uart_transaction);

    // Factory Registration
    `uvm_object_utils(uart_sequence)

    // Transaction Handle
    uart_transaction tr;

    // Constructor
    function new(string name = "uart_sequence");
        super.new(name);
    endfunction

    // Sequence Body
    virtual task body();

        repeat(20)
        begin

            // Create Transaction
            tr = uart_transaction::type_id::create("tr");

            // Randomize Transaction
            assert(tr.randomize())
            else
                `uvm_error("SEQ","Randomization Failed")

            // Send Transaction
            start_item(tr);

            finish_item(tr);

            // Print
            `uvm_info("SEQ",
                      tr.convert2string(),
                      UVM_LOW)

        end

    endtask

endclass

// Error Injection Sequence
class uart_error_sequence extends uvm_sequence #(uart_transaction);

    // Factory Registration
    `uvm_object_utils(uart_error_sequence)

    uart_transaction tr;

    // Constructor
    function new(string name = "uart_error_sequence");
        super.new(name);
    endfunction

    // Body
    virtual task body();

        // 1. Send a Normal Transaction
        `uvm_info("SEQ", "Sending normal transaction...", UVM_LOW)
        tr = uart_transaction::type_id::create("tr");
        assert(tr.randomize() with { inject_parity_error == 0; inject_framing_error == 0; inject_false_start == 0; })
        else `uvm_error("SEQ", "Randomization Failed")
        start_item(tr);
        finish_item(tr);

        // 2. Send a Parity Error Transaction
        `uvm_info("SEQ", "Sending parity error transaction...", UVM_LOW)
        tr = uart_transaction::type_id::create("tr");
        assert(tr.randomize() with { inject_parity_error == 1; inject_framing_error == 0; inject_false_start == 0; })
        else `uvm_error("SEQ", "Randomization Failed")
        start_item(tr);
        finish_item(tr);

        // 3. Send a Framing Error Transaction
        `uvm_info("SEQ", "Sending framing error transaction...", UVM_LOW)
        tr = uart_transaction::type_id::create("tr");
        assert(tr.randomize() with { inject_parity_error == 0; inject_framing_error == 1; inject_false_start == 0; })
        else `uvm_error("SEQ", "Randomization Failed")
        start_item(tr);
        finish_item(tr);

        // 4. Send a False Start Bit Transaction
        `uvm_info("SEQ", "Sending false start transaction...", UVM_LOW)
        tr = uart_transaction::type_id::create("tr");
        assert(tr.randomize() with { inject_parity_error == 0; inject_framing_error == 0; inject_false_start == 1; })
        else `uvm_error("SEQ", "Randomization Failed")
        start_item(tr);
        finish_item(tr);

    endtask

endclass

`endif