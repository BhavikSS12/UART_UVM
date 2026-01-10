// UART Burst Transmission Test
// File: tb/tests/uart_burst_test.sv

class uart_burst_test extends uart_base_test;
    
    `uvm_component_utils(uart_burst_test)
    
    function new(string name = "uart_burst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_burst_sequence seq;
        
        phase.raise_objection(this);
        
        super.run_phase(phase);
        
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting Burst Test", UVM_LOW)
        `uvm_info(get_type_name(), "  Bursts: 5, Size: 10 each", UVM_LOW)
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        
        seq = uart_burst_sequence::type_id::create("seq");
        seq.num_bursts = 5;
        seq.burst_size = 10;
        seq.start(env.agent.sequencer);
        
        #20000;
        
        `uvm_info(get_type_name(), "Burst test completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass