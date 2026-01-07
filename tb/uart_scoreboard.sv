`timescale 1ns/1ps
// UART Scoreboard
class uart_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(uart_scoreboard)
    
    uvm_analysis_imp #(uart_transaction, uart_scoreboard) item_collected_export;
    
    uart_transaction tx_queue[$];
    uart_transaction rx_queue[$];
    
    int tx_count;
    int rx_count;
    int match_count;
    int mismatch_count;
    int parity_error_count;
    int frame_error_count;
    
    function new(string name = "uart_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
    endfunction
    
    virtual function void write(uart_transaction tx);
        uart_transaction expected_tx;
        
        if(tx.tx_done) begin
            // Store transmitted data
            tx_count++;
            tx_queue.push_back(tx);
            `uvm_info(get_type_name(), $sformatf("TX stored: %s [Total TX: %0d]", tx.convert2string(), tx_count), UVM_LOW)
        end
        
        if(tx.rx_done) begin
            // Compare received data with transmitted data
            rx_count++;
            rx_queue.push_back(tx);
            
            if(tx_queue.size() > 0) begin
                expected_tx = tx_queue.pop_front();
                
                if(tx.parity_error) begin
                    parity_error_count++;
                    `uvm_error(get_type_name(), $sformatf("Parity error detected! Data=0x%0h", tx.data))
                end
                
                if(tx.frame_error) begin
                    frame_error_count++;
                    `uvm_error(get_type_name(), $sformatf("Frame error detected! Data=0x%0h", tx.data))
                end
                
                if(tx.data == expected_tx.data && !tx.parity_error && !tx.frame_error) begin
                    match_count++;
                    `uvm_info(get_type_name(), $sformatf("MATCH! Sent=0x%0h, Received=0x%0h [Matches: %0d]", 
                              expected_tx.data, tx.data, match_count), UVM_LOW)
                end else if(!tx.parity_error && !tx.frame_error) begin
                    mismatch_count++;
                    `uvm_error(get_type_name(), $sformatf("MISMATCH! Expected=0x%0h, Got=0x%0h [Mismatches: %0d]", 
                               expected_tx.data, tx.data, mismatch_count))
                end
            end else begin
                `uvm_warning(get_type_name(), "Received data but no transmitted data in queue!")
            end
        end
    endfunction
    
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), "         UART VERIFICATION RESULTS      ", UVM_LOW)
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Transactions Sent    : %0d", tx_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Transactions Received: %0d", rx_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Matches                    : %0d", match_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Mismatches                 : %0d", mismatch_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Parity Errors              : %0d", parity_error_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Frame Errors               : %0d", frame_error_count), UVM_LOW)
        `uvm_info(get_type_name(), "========================================", UVM_LOW)
        
        if(mismatch_count == 0 && parity_error_count == 0 && frame_error_count == 0 && match_count > 0) begin
            `uvm_info(get_type_name(), "TEST PASSED!", UVM_LOW)
        end else begin
            `uvm_error(get_type_name(), "TEST FAILED!")
        end
    endfunction
    
endclass