`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

class uart_monitor extends uvm_monitor;

    //------------------------------------------------------------
    // Factory Registration
    //------------------------------------------------------------
    `uvm_component_utils(uart_monitor)

    //------------------------------------------------------------
    // Virtual Interface
    //------------------------------------------------------------
    virtual uart_if vif;

    //------------------------------------------------------------
    // Analysis Port
    //------------------------------------------------------------
    uvm_analysis_port #(uart_transaction) ap;

    //------------------------------------------------------------
    // Transaction Handle
    //------------------------------------------------------------
    uart_transaction tr;

    //------------------------------------------------------------
    // Constructor
    //------------------------------------------------------------
    function new(string name = "uart_monitor",
                 uvm_component parent);

        super.new(name,parent);

        ap = new("ap", this);

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
            `uvm_fatal("MONITOR",
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
            // Wait until receiver finishes
            //----------------------------------------------------
            @(negedge vif.rx_busy);

            //----------------------------------------------------
            // Create Transaction
            //----------------------------------------------------
            tr = uart_transaction::type_id::create("tr");

            //----------------------------------------------------
            // Collect DUT Outputs
            //----------------------------------------------------
            tr.data        = vif.rx_msg;
            tr.parity_type = vif.rx_parity;

            //----------------------------------------------------
            // Send to Scoreboard
            //----------------------------------------------------
            ap.write(tr);

            //----------------------------------------------------
            // Print
            //----------------------------------------------------
            `uvm_info("MONITOR",
                      $sformatf("Received : %s",
                                tr.convert2string()),
                      UVM_LOW)

        end

    endtask

endclass

`endif