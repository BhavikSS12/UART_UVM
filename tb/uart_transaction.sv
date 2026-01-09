`timescale 1ns/1ps
class uart_transaction extends uvm_sequence_item;
  
    // Transaction fields
    rand bit [7:0] data;
    bit            parity_error;
    bit            frame_error;
    bit            tx_done;
    bit            rx_done;
    
    // UVM Factory Registration
    `uvm_object_utils_begin(uart_transaction)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(parity_error, UVM_ALL_ON)
        `uvm_field_int(frame_error, UVM_ALL_ON)
        `uvm_field_int(tx_done, UVM_ALL_ON)
        `uvm_field_int(rx_done, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // Constructor
    function new(string name = "uart_transaction");
        super.new(name);
    endfunction
    
    // Constraints
    constraint data_c {
        data dist {
            [8'h00:8'h0F] := 20,
            [8'h10:8'hEF] := 60,
            [8'hF0:8'hFF] := 20
        };
    }
    
    // Convert to string for printing
    function string convert2string();
        return $sformatf("Data=0x%0h, PE=%0b, FE=%0b, TxDone=%0b, RxDone=%0b", 
                         data, parity_error, frame_error, tx_done, rx_done);
    endfunction
    
endclass