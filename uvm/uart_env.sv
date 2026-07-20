`ifndef UART_ENV_SV
`define UART_ENV_SV

class uart_env extends uvm_env;

    // Factory Registration
    `uvm_component_utils(uart_env)

    // Components
    uart_agent agent;

    uart_scoreboard scoreboard;

    // Constructor
    function new(string name = "uart_env",
                 uvm_component parent);

        super.new(name,parent);

    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent =
            uart_agent::type_id::create(
            "agent",
            this);

        scoreboard =
            uart_scoreboard::type_id::create(
            "scoreboard",
            this);

    endfunction

    // Connect Phase
    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        // Driver → Expected FIFO
        agent.driver.ap.connect(
            scoreboard.exp_fifo.analysis_export
        );

        // Monitor → Actual FIFO
        agent.monitor.ap.connect(
            scoreboard.act_fifo.analysis_export
        );

    endfunction

endclass

`endif