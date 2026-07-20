`ifndef UART_TEST_SV
`define UART_TEST_SV

class uart_test extends uvm_test;

    // Factory Registration
    `uvm_component_utils(uart_test)

    // Components
    uart_env env;

    // Sequence Handle
    uart_sequence seq;

    // Constructor
    function new(string name = "uart_test",
                 uvm_component parent);

        super.new(name,parent);

    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        env = uart_env::type_id::create(
                    "env",
                    this);

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        // Raise Objection
        phase.raise_objection(this);

        // Create Sequence
        seq = uart_sequence::type_id::create("seq");

        // Start Sequence
        seq.start(env.agent.sequencer);

        // Wait a little
        #1000ns;

        // Drop Objection
        phase.drop_objection(this);

    endtask

endclass

// Error Injection Test
class uart_error_test extends uart_test;

    // Factory Registration
    `uvm_component_utils(uart_error_test)

    // Constructor
    function new(string name = "uart_error_test",
                 uvm_component parent);
        super.new(name,parent);
    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        uart_error_sequence err_seq;

        // Raise Objection
        phase.raise_objection(this);

        // Create sequence
        err_seq = uart_error_sequence::type_id::create("err_seq");

        // Start sequence
        err_seq.start(env.agent.sequencer);

        // Wait a little
        #1000ns;

        // Drop Objection
        phase.drop_objection(this);

    endtask

endclass

`endif