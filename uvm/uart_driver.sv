`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

class uart_driver extends uvm_driver #(uart_transaction);

    // Factory Registration
    `uvm_component_utils(uart_driver)

    // Virtual Interface
    virtual uart_if vif;

    // Analysis Port to send expected transactions to scoreboard
    uvm_analysis_port #(uart_transaction) ap;

    // Transaction Handle
    uart_transaction tr;

    // Constructor
    function new(string name = "uart_driver", uvm_component parent);
        super.new(name,parent);
        ap = new("ap", this);
    endfunction

    // Build Phase    
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(virtual uart_if)::get(this,"","vif",vif))
            `uvm_fatal("DRIVER","Virtual Interface Not Found")

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);
        //initialize: reset is active-high, tx_start is active-low
        vif.driver_cb.rst <= 1'b1;
        vif.driver_cb.tx_start <= 1'b1; // Deasserted initially
        vif.driver_cb.data_in <= 8'b0;
        vif.driver_cb.parity_type <= 1'b0;

        repeat(5) @(vif.driver_cb);
        vif.driver_cb.rst <= 1'b0; // Deassert reset
        repeat(2) @(vif.driver_cb);

        forever
        begin
            // Get Next Transaction
            seq_item_port.get_next_item(tr);

            drive_transfer(tr);

            // Transaction Complete
            seq_item_port.item_done();
        end

    endtask

    // Drive UART Transaction
    task drive_transfer(uart_transaction tr);

        @(vif.driver_cb);
        vif.driver_cb.data_in      <= tr.data;
        vif.driver_cb.parity_type  <= tr.parity_type;
        vif.driver_cb.tx_start     <= 1'b0; // Assert tx_start (active-low)

        @(vif.driver_cb);
        vif.driver_cb.tx_start     <= 1'b1; // Deassert tx_start

        // Wait until TX completes
        @(posedge vif.tx_done);

        // Send transaction to the scoreboard
        ap.write(tr);

        `uvm_info("DRIVER", $sformatf("Sent : %s",tr.convert2string()), UVM_LOW)

    endtask

endclass

`endif