`ifndef UART_MONITOR_SV
`define UART_MONITOR_SV

class uart_monitor extends uvm_monitor;

    // Factory Registration
    `uvm_component_utils(uart_monitor)

    // Virtual Interface
    virtual uart_if vif;

    // Analysis Port
    uvm_analysis_port #(uart_transaction) ap;

    // Transaction Handle
    uart_transaction tr;

    // Constructor
    function new(string name = "uart_monitor",
                 uvm_component parent);

        super.new(name,parent);

        ap = new("ap", this);

    endfunction

    // Build Phase
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

    // Run Phase
    task run_phase(uvm_phase phase);

        forever
        begin
            // Wait for rx_busy to become active (start of reception)
            @(vif.monitor_cb);
            while (vif.monitor_cb.rx_busy !== 1'b1) begin
                @(vif.monitor_cb);
            end

            // Wait for rx_busy to become inactive (end of reception)
            while (vif.monitor_cb.rx_busy === 1'b1) begin
                @(vif.monitor_cb);
            end

            // Create Transaction
            tr = uart_transaction::type_id::create("tr");

            // Collect DUT Outputs synchronously via clocking block
            tr.rx_data     = vif.monitor_cb.rx_msg;
            tr.rx_parity   = vif.monitor_cb.rx_parity;
            tr.error_flag  = vif.monitor_cb.error_flag;

            // Send to Scoreboard
            ap.write(tr);

            `uvm_info("MONITOR",
                      $sformatf("Received : %s",
                                tr.convert2string()),
                      UVM_LOW)
        end

    endtask

endclass

`endif