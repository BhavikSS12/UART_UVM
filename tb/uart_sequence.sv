`timescale 1ns/1ps
// Base UART Sequence
class uart_base_sequence extends uvm_sequence #(uart_transaction);
    `uvm_object_utils(uart_base_sequence)

    function new(string name = "uart_base_sequence");
        super.new(name);
    endfunction

    virtual task body();
        // Base body
    endtask
endclass

// Random Data Sequence
class uart_random_sequence extends uart_base_sequence;
    `uvm_object_utils(uart_random_sequence)

    rand int num_transactions;

    constraint num_trans_c {
        num_transactions inside {[10:50]};
    }

    function new(string name = "uart_random_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_transaction tx;
        repeat(num_transactions) begin
            tx = uart_transaction::type_id::create("tx");
            start_item(tx);
            if(!tx.randomize()) `uvm_error("RAND_FAIL", "Randomization failed")
            `uvm_info(get_type_name(), $sformatf("Generating transaction: %s", tx.convert2string()), UVM_MEDIUM)
            finish_item(tx);
        end
    endtask
endclass

// Sequential Data Sequence (0x00 to 0xFF)
class uart_sequential_sequence extends uart_base_sequence;
    `uvm_object_utils(uart_sequential_sequence)

    function new(string name = "uart_sequential_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_transaction tx;
        for(int i = 0; i < 256; i++) begin
            tx = uart_transaction::type_id::create("tx");
            start_item(tx);
            tx.data = i[7:0];
            `uvm_info(get_type_name(), $sformatf("Generating transaction: %s", tx.convert2string()), UVM_MEDIUM)
            finish_item(tx);
        end
    endtask
endclass

// Corner Case Sequence
class uart_corner_sequence extends uart_base_sequence;
    `uvm_object_utils(uart_corner_sequence)

    function new(string name = "uart_corner_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_transaction tx;
        bit [7:0] corner_values[] = '{8'h00, 8'hFF, 8'hAA, 8'h55, 8'h0F, 8'hF0};
        
        foreach(corner_values[i]) begin
            tx = uart_transaction::type_id::create("tx");
            start_item(tx);
            tx.data = corner_values[i];
            `uvm_info(get_type_name(), $sformatf("Generating corner case: %s", tx.convert2string()), UVM_MEDIUM)
            finish_item(tx);
        end
    endtask
endclass

// Burst Sequence
class uart_burst_sequence extends uart_base_sequence;
    `uvm_object_utils(uart_burst_sequence)

    rand int num_bursts;
    rand int burst_size;

    constraint burst_c {
        num_bursts inside {[3:10]};
        burst_size inside {[5:20]};
    }

    function new(string name = "uart_burst_sequence");
        super.new(name);
    endfunction

    virtual task body();
        uart_transaction tx;
        repeat(num_bursts) begin
            repeat(burst_size) begin
                tx = uart_transaction::type_id::create("tx");
                start_item(tx);
                if(!tx.randomize()) `uvm_error("RAND_FAIL", "Randomization failed")
                `uvm_info(get_type_name(), $sformatf("Burst transaction: %s", tx.convert2string()), UVM_MEDIUM)
                finish_item(tx);
            end
            #1000; 
        end
    endtask
endclass