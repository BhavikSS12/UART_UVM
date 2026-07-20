`ifndef UART_AGENT_SV
`define UART_AGENT_SV

class uart_agent extends uvm_agent;

    // Factory Registration
    `uvm_component_utils(uart_agent)

    // Components
    uart_driver    driver;
    uart_monitor   monitor;
    uart_sequencer sequencer;

    // Constructor
    function new(string name = "uart_agent",
                 uvm_component parent);

        super.new(name,parent);

    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        driver =
            uart_driver::type_id::create(
            "driver",
            this);

        monitor =
            uart_monitor::type_id::create(
            "monitor",
            this);

        sequencer =
            uart_sequencer::type_id::create(
            "sequencer",
            this);

    endfunction

    // Connect Phase
    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        driver.seq_item_port.connect(
            sequencer.seq_item_export
        );

    endfunction

endclass

`endif