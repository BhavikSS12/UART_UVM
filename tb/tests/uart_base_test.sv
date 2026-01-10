// UART Base Test Class
// File: tb/tests/uart_base_test.sv

class uart_base_test extends uvm_test;
    
    `uvm_component_utils(uart_base_test)
    
    uart_env env;
    
    function new(string name = "uart_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = uart_env::type_id::create("env", this);
        `uvm_info(get_type_name(), "Build phase complete", UVM_HIGH)
    endfunction
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_type_name(), "Printing UVM topology:", UVM_LOW)
        uvm_top.print_topology();
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Applying Reset", UVM_LOW)
        `uvm_info(get_type_name(), "============================================", UVM_LOW)
        
        env.agent.driver.reset_signals();
        #100;
        
        phase.drop_objection(this);
    endtask
    
endclass