// UART Comprehensive Test (All Tests Combined)
// File: tb/tests/uart_comprehensive_test.sv

class uart_comprehensive_test extends uart_base_test;
    
    `uvm_component_utils(uart_comprehensive_test)
    
    function new(string name = "uart_comprehensive_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_random_sequence     rand_seq;
        uart_corner_sequence     corner_seq;
        uart_burst_sequence      burst_seq;
        
        phase.raise_objection(this);
        
        super.run_phase(phase);
        
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting Comprehensive Test", UVM_LOW)
        `uvm_info(get_type_name(), "  Includes: Corner + Random + Burst", UVM_LOW)
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        
        // Test 1: Corner cases
        `uvm_info(get_type_name(), "Phase 1/3: Running corner case tests...", UVM_LOW)
        corner_seq = uart_corner_sequence::type_id::create("corner_seq");
        corner_seq.start(env.agent.sequencer);
        #5000;
        
        // Test 2: Random data
        `uvm_info(get_type_name(), "Phase 2/3: Running random tests...", UVM_LOW)
        rand_seq = uart_random_sequence::type_id::create("rand_seq");
        rand_seq.num_transactions = 20;
        rand_seq.start(env.agent.sequencer);
        #10000;
        
        // Test 3: Burst mode
        `uvm_info(get_type_name(), "Phase 3/3: Running burst tests...", UVM_LOW)
        burst_seq = uart_burst_sequence::type_id::create("burst_seq");
        burst_seq.num_bursts = 3;
        burst_seq.burst_size = 8;
        burst_seq.start(env.agent.sequencer);
        #15000;
        
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Comprehensive test completed", UVM_LOW)
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass