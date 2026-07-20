`ifndef UART_SCOREBOARD_SV
`define UART_SCOREBOARD_SV

class uart_scoreboard extends uvm_scoreboard;

    // Factory Registration
    `uvm_component_utils(uart_scoreboard)

    // Analysis FIFOs
    uvm_tlm_analysis_fifo #(uart_transaction) exp_fifo;
    uvm_tlm_analysis_fifo #(uart_transaction) act_fifo;

    // Transactions
    uart_transaction exp_tr;
    uart_transaction act_tr;

    // Statistics
    int pass_count;
    int fail_count;

    // Constructor
    function new(string name="uart_scoreboard",
                 uvm_component parent);

        super.new(name,parent);

    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        exp_fifo = new("exp_fifo",this);
        act_fifo = new("act_fifo",this);

        pass_count = 0;
        fail_count = 0;

    endfunction

    // Run Phase
    task run_phase(uvm_phase phase);

        forever
        begin

            // Get Expected Transaction
            exp_fifo.get(exp_tr);

            // Get Actual Transaction
            act_fifo.get(act_tr);

            // Compare
            if (exp_tr.inject_parity_error || exp_tr.inject_framing_error || exp_tr.inject_false_start) begin
                if (act_tr.error_flag == 1'b1) begin
                    pass_count++;
                    `uvm_info("SCOREBOARD",
                              $sformatf("PASS : Expected Error Detected (Parity_Inj=%0b, Framing_Inj=%0b, FalseStart_Inj=%0b)",
                                        exp_tr.inject_parity_error,
                                        exp_tr.inject_framing_error,
                                        exp_tr.inject_false_start),
                              UVM_LOW)
                end
                else begin
                    fail_count++;
                    `uvm_error("SCOREBOARD",
                               $sformatf("FAIL : Expected Error NOT Detected (Parity_Inj=%0b, Framing_Inj=%0b, FalseStart_Inj=%0b)",
                                         exp_tr.inject_parity_error,
                                         exp_tr.inject_framing_error,
                                         exp_tr.inject_false_start))
                end
            end
            else begin
                if((exp_tr.data == act_tr.rx_data) && (act_tr.error_flag == 1'b0)) begin
                    pass_count++;
                    `uvm_info("SCOREBOARD",
                              $sformatf("PASS : Expected=%02h Received=%02h",
                                        exp_tr.data,
                                        act_tr.rx_data),
                              UVM_LOW)
                end
                else begin
                    fail_count++;
                    `uvm_error("SCOREBOARD",
                               $sformatf("FAIL\nExpected=%02h\nReceived=%02h\nError=%0b",
                                         exp_tr.data,
                                         act_tr.rx_data,
                                         act_tr.error_flag))
                end
            end

        end

    endtask

    // Report Phase
    function void report_phase(uvm_phase phase);

        `uvm_info("SCOREBOARD",
                  $sformatf(
                  "\n***************************\nPASS = %0d\nFAIL = %0d\n***************************",
                  pass_count,
                  fail_count),
                  UVM_NONE)

    endfunction

endclass

`endif