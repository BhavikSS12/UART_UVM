// UART Random Data Test
// File: tb/tests/uart_random_test.sv

class uart_random_test extends uart_base_test;
    
    `uvm_component_utils(uart_random_test)
    
    function new(string name = "uart_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_random_sequence seq;
        
        phase.raise_objection(this);
        
        // Apply reset from base class
        super.run_phase(phase);
        
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting Random Test", UVM_LOW)
        `uvm_info(get_type_name(), "  Transactions: 30", UVM_LOW)
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        
        // Create and configure sequence
        seq = uart_random_sequence::type_id::create("seq");
        seq.num_transactions = 30;
        
        // Start sequence
        seq.start(env.agent.sequencer);
        
        // Wait for completion
        #10000;
        
        `uvm_info(get_type_name(), "Random test completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass