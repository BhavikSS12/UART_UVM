`timescale 1ns/1ps
// Base UART Test
class uart_base_test extends uvm_test;
    
    `uvm_component_utils(uart_base_test)
    
    uart_env env;
    
    function new(string name = "uart_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        // Reset sequence
        `uvm_info(get_type_name(), "Applying reset...", UVM_LOW)
        env.agent.driver.reset_signals();
        #100;
        
        phase.drop_objection(this);
    endtask
    
endclass

// Random Test
class uart_random_test extends uart_base_test;
    
    `uvm_component_utils(uart_random_test)
    
    function new(string name = "uart_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_random_sequence seq;
        
        phase.raise_objection(this);
        
        super.run_phase(phase);
        
        seq = uart_random_sequence::type_id::create("seq");
        seq.num_transactions = 30;
        
        `uvm_info(get_type_name(), "Starting random sequence...", UVM_LOW)
        seq.start(env.agent.sequencer);
        
        #10000;
        phase.drop_objection(this);
    endtask
    
endclass

// Sequential Test
class uart_sequential_test extends uart_base_test;
    
    `uvm_component_utils(uart_sequential_test)
    
    function new(string name = "uart_sequential_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_sequential_sequence seq;
        
        phase.raise_objection(this);
        
        super.run_phase(phase);
        
        seq = uart_sequential_sequence::type_id::create("seq");
        
        `uvm_info(get_type_name(), "Starting sequential sequence...", UVM_LOW)
        seq.start(env.agent.sequencer);
        
        #10000;
        phase.drop_objection(this);
    endtask
    
endclass

// Corner Case Test
class uart_corner_test extends uart_base_test;
    
    `uvm_component_utils(uart_corner_test)
    
    function new(string name = "uart_corner_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_corner_sequence seq;
        
        phase.raise_objection(this);
        
        super.run_phase(phase);
        
        seq = uart_corner_sequence::type_id::create("seq");
        
        `uvm_info(get_type_name(), "Starting corner case sequence...", UVM_LOW)
        seq.start(env.agent.sequencer);
        
        #10000;
        phase.drop_objection(this);
    endtask
    
endclass

// Burst Test
class uart_burst_test extends uart_base_test;
    
    `uvm_component_utils(uart_burst_test)
    
    function new(string name = "uart_burst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_burst_sequence seq;
        
        phase.raise_objection(this);
        
        super.run_phase(phase);
        
        seq = uart_burst_sequence::type_id::create("seq");
        seq.num_bursts = 5;
        seq.burst_size = 10;
        
        `uvm_info(get_type_name(), "Starting burst sequence...", UVM_LOW)
        seq.start(env.agent.sequencer);
        
        #20000;
        phase.drop_objection(this);
    endtask
    
endclass

// Comprehensive Test - Runs all sequence types
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
        
        // Run corner cases
        corner_seq = uart_corner_sequence::type_id::create("corner_seq");
        `uvm_info(get_type_name(), "Running corner case tests...", UVM_LOW)
        corner_seq.start(env.agent.sequencer);
        #5000;
        
        // Run random test
        rand_seq = uart_random_sequence::type_id::create("rand_seq");
        rand_seq.num_transactions = 20;
        `uvm_info(get_type_name(), "Running random tests...", UVM_LOW)
        rand_seq.start(env.agent.sequencer);
        #10000;
        
        // Run burst test
        burst_seq = uart_burst_sequence::type_id::create("burst_seq");
        burst_seq.num_bursts = 3;
        burst_seq.burst_size = 8;
        `uvm_info(get_type_name(), "Running burst tests...", UVM_LOW)
        burst_seq.start(env.agent.sequencer);
        #15000;
        
        phase.drop_objection(this);
    endtask
    
endclass