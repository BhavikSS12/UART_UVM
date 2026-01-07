// UART Driver
class uart_driver extends uvm_driver #(uart_transaction);
    
    `uvm_component_utils(uart_driver)
    
    virtual uart_interface vif;
    
    function new(string name = "uart_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart_interface)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found!")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        uart_transaction tx;
        
        forever begin
            seq_item_port.get_next_item(tx);
            drive_transaction(tx);
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_transaction(uart_transaction tx);
        `uvm_info(get_type_name(), $sformatf("Driving transaction: %s", tx.convert2string()), UVM_HIGH)
        
        // Wait for ready state
        @(vif.driver_cb);
        vif.driver_cb.tx_start <= 1'b1;
        vif.driver_cb.tx_data  <= tx.data;
        
        @(vif.driver_cb);
        vif.driver_cb.tx_start <= 1'b0;
        
        // Wait for transmission to complete
        wait(vif.driver_cb.tx_done == 1'b1);
        @(vif.driver_cb);
        
        // Add small delay between transactions
        repeat(5) @(vif.driver_cb);
        
        `uvm_info(get_type_name(), "Transaction driven successfully", UVM_HIGH)
    endtask
    
    virtual task reset_signals();
        vif.driver_cb.rst_n    <= 1'b0;
        vif.driver_cb.tx_start <= 1'b0;
        vif.driver_cb.tx_data  <= 8'h00;
        vif.rx_serial          <= 1'b1;
        
        repeat(10) @(vif.driver_cb);
        vif.driver_cb.rst_n <= 1'b1;
        repeat(5) @(vif.driver_cb);
    endtask
    
endclass