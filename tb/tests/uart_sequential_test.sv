// UART Sequential Data Test (0x00 to 0xFF)
// File: tb/tests/uart_sequential_test.sv

class uart_sequential_test extends uart_base_test;
    
    `uvm_component_utils(uart_sequential_test)
    
    function new(string name = "uart_sequential_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_sequential_sequence seq;
        
        phase.raise_objection(this);
        
        super.run_phase(phase);
        
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting Sequential Test", UVM_LOW)
        `uvm_info(get_type_name(), "  Data: 0x00 to 0xFF (256 transactions)", UVM_LOW)
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        
        seq = uart_sequential_sequence::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        #100000;
        
        `uvm_info(get_type_name(), "Sequential test completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass