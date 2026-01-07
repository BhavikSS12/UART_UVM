`timescale 1ns/1ps
// UART Monitor
class uart_monitor extends uvm_monitor;
    
    `uvm_component_utils(uart_monitor)
    
    virtual uart_interface vif;
    uvm_analysis_port #(uart_transaction) item_collected_port;
    uart_transaction tx_collected;
    
    function new(string name = "uart_monitor", uvm_component parent = null);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual uart_interface)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found!")
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        fork
            collect_tx_data();
            collect_rx_data();
        join_none
    endtask
    
    virtual task collect_tx_data();
        uart_transaction tx;
        
        forever begin
            @(vif.monitor_cb);
            if(vif.monitor_cb.tx_start) begin
                tx = uart_transaction::type_id::create("tx");
                tx.data = vif.monitor_cb.tx_data;
                
                // Wait for transmission done
                @(posedge vif.monitor_cb.tx_done);
                tx.tx_done = 1'b1;
                
                `uvm_info(get_type_name(), $sformatf("TX Collected: %s", tx.convert2string()), UVM_MEDIUM)
                item_collected_port.write(tx);
            end
        end
    endtask
    
    virtual task collect_rx_data();
        uart_transaction tx;
        
        forever begin
            @(posedge vif.monitor_cb.rx_done);
            tx = uart_transaction::type_id::create("tx");
            tx.data          = vif.monitor_cb.rx_data;
            tx.parity_error  = vif.monitor_cb.parity_error;
            tx.frame_error   = vif.monitor_cb.frame_error;
            tx.rx_done       = 1'b1;
            
            `uvm_info(get_type_name(), $sformatf("RX Collected: %s", tx.convert2string()), UVM_MEDIUM)
            item_collected_port.write(tx);
        end
    endtask
    
endclass