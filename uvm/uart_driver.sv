`ifndef UART_DRIVER_SV
`define UART_DRIVER_SV

class uart_driver extends uvm_driver #(uart_transaction);

    //------------------------------------------------------------
    // Factory Registration
    //------------------------------------------------------------
    `uvm_component_utils(uart_driver)

    //------------------------------------------------------------
    // Virtual Interface
    //------------------------------------------------------------
    virtual uart_if vif;

    //------------------------------------------------------------
    // Transaction Handle
    //------------------------------------------------------------
    uart_transaction tr;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "uart_driver",
                 uvm_component parent);

        super.new(name,parent);

    endfunction

    //------------------------------------------------------------
    // Build Phase
    //------------------------------------------------------------
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db#(virtual uart_if)::get(
                this,
                "",
                "vif",
                vif))
        begin
            `uvm_fatal("DRIVER",
                       "Virtual Interface Not Found")
        end

    endfunction

    //------------------------------------------------------------
    // Run Phase
    //------------------------------------------------------------
    task run_phase(uvm_phase phase);

        forever
        begin

            //----------------------------------------------------
            // Get Next Transaction
            //----------------------------------------------------
            seq_item_port.get_next_item(tr);

            drive_transfer(tr);

            //----------------------------------------------------
            // Transaction Complete
            //----------------------------------------------------
            seq_item_port.item_done();

        end

    endtask

    //------------------------------------------------------------
    // Drive UART Transaction
    //------------------------------------------------------------
    task drive_transfer(uart_transaction tr);

        @(posedge vif.clk);

        vif.data_in      <= tr.data;
        vif.parity_type  <= tr.parity_type;
        vif.tx_start     <= 1'b0;

        @(posedge vif.clk);

        vif.tx_start <= 1'b1;

        //--------------------------------------------------------
        // Wait until TX completes
        //--------------------------------------------------------
        @(posedge vif.tx_done);

        `uvm_info("DRIVER",
                  $sformatf("Sent : %s",
                            tr.convert2string()),
                  UVM_LOW)

    endtask

endclass

`endif