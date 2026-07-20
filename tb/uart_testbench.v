`timescale 1ns/1ps

module uart_testbench;

localparam CLK_PERIOD  = 20;
localparam CLK_PER_BIT = 434;

// Testbench Signals

reg clk;
reg rst;

reg tx_start;
reg parity_type;
reg [7:0] data_in;

wire tx;
wire tx_done;

reg uart_line;

wire [7:0] rx_msg;
wire rx_parity;
wire rx_busy;
wire error_flag;

integer pass_count;
integer fail_count;
integer i;

// Connect TX to RX
reg inject_enable;
reg inject_value;

always @(*) begin
    if(inject_enable)
        uart_line = inject_value;
    else
        uart_line = tx;
end

// Clock Generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// UART Transmitter
uart_tx uut_tx(
    .clk(clk),
    .rst(rst),
    .parity_type(parity_type),
    .data_in(data_in),
    .tx_start(tx_start),
    .tx(tx),
    .tx_done(tx_done)
);

// UART Receiver
uart_rx uut_rx(
    .clk(clk),
    .rst(rst),
    .rx(uart_line),
    .rx_msg(rx_msg),
    .rx_parity(rx_parity),
    .rx_busy(rx_busy),
    .error_flag(error_flag)
);

// Reset Task
task reset_dut;
begin

    rst = 1'b1;
    tx_start = 1'b1;
    parity_type = 1'b1;
    data_in = 8'h00;

    #100;
    rst = 1'b0;
    #50;

end
endtask

// Send One Byte
task send_byte(input [7:0] tx_data);
begin

    @(posedge clk);

    data_in = tx_data;
    tx_start = 1'b0;
    #20;
    tx_start = 1'b1;

    @(posedge tx_done);
    @(negedge rx_busy);
    #50;

end
endtask

// Check Received Byte
task check_byte(input [7:0] expected);
begin

    if((rx_msg !== expected) || (error_flag)) begin

        fail_count = fail_count + 1;

        $display("[%0t] FAIL", $time);
        $display("Expected : %h", expected);
        $display("Received : %h", rx_msg);
        $display("Error    : %b", error_flag);

    end
    else begin

        pass_count = pass_count + 1;

        $display("[%0t] PASS : %h", $time, expected);

    end

end
endtask

// Main Test
initial begin

    pass_count = 0;
    fail_count = 0;

    reset_dut();

    // Directed Tests
    $display("");
    $display("DIRECTED TESTS");

    send_byte(8'h00);
    check_byte(8'h00);

    send_byte(8'h55);
    check_byte(8'h55);

    send_byte(8'hAA);
    check_byte(8'hAA);

    send_byte(8'hA5);
    check_byte(8'hA5);

    send_byte(8'hFF);
    check_byte(8'hFF);

    // Back-to-Back Frames
    $display("");
    $display("BACK TO BACK FRAMES");

    data_in = 8'h11;
    tx_start = 0;
    #20;
    tx_start = 1;
    @(posedge tx_done);
    repeat(2) @(posedge clk);

    data_in = 8'h22;
    tx_start = 0;
    #20;
    tx_start = 1;
    @(posedge tx_done);
    repeat(2) @(posedge clk);

    data_in = 8'h33;
    tx_start = 0;
    #20;
    tx_start = 1;
    @(posedge tx_done);
    repeat(2) @(posedge clk);

    @(negedge rx_busy);
    repeat(2) @(posedge clk);

    // Reset During Transmission
    $display("");
    $display("RESET DURING TX");

    @(posedge clk);

    data_in = 8'h5A;
    tx_start = 0;

    @(posedge clk);

    tx_start = 1;

    repeat(3) @(posedge clk);

    rst = 1;

    repeat(2) @(posedge clk);

    rst = 0;

    repeat(10) @(posedge clk);

    // Reset During Reception
    $display("");
    $display("RESET DURING RX");

    @(posedge clk);

    data_in = 8'h3C;
    tx_start = 0;

    @(posedge clk);

    tx_start = 1;

    wait(rx_busy);

    repeat(4) @(posedge clk);

    rst = 1;

    repeat(2) @(posedge clk);

    rst = 0;

    repeat(10) @(posedge clk);

    // False Start Bit Test
    $display("");
    $display("FALSE START TEST");

    inject_enable = 1;
    inject_value  = 1'b0;
    #(CLK_PERIOD*50);
    inject_enable = 0;

    #(CLK_PERIOD*CLK_PER_BIT);

    if(rx_busy == 0)
    begin
        pass_count = pass_count + 1;
        $display("FALSE START : PASS");
    end
    else
    begin
        fail_count = fail_count + 1;
        $display("FALSE START : FAIL");
    end

    // Parity Error Injection
    $display("");
    $display("");
    $display("PARITY ERROR TEST");

    @(posedge clk);

    data_in = 8'h96;
    tx_start = 0;

    @(posedge clk);
    tx_start = 1;

    // Wait until parity bit
    #(CLK_PERIOD*CLK_PER_BIT*9);

    inject_enable = 1;
    inject_value  = ~tx;
    #(CLK_PERIOD*CLK_PER_BIT);
    inject_enable = 0;

    @(negedge rx_busy);

    repeat(2) @(posedge clk);

    if(error_flag)
    begin
        pass_count = pass_count + 1;
        $display("PARITY ERROR DETECTED : PASS");
    end
    else
    begin
        fail_count = fail_count + 1;
        $display("PARITY ERROR DETECTED : FAIL");
    end

    // Framing Error Injection
    $display("");
    $display("FRAMING ERROR TEST");

    @(posedge clk);

    data_in = 8'h69;
    tx_start = 0;

    @(posedge clk);
    tx_start = 1;

    // Wait until stop bit
    #(CLK_PERIOD*CLK_PER_BIT*10);

    inject_enable = 1;
    inject_value  = 1'b0;
    #(CLK_PERIOD*CLK_PER_BIT);
    inject_enable = 0;

    @(negedge rx_busy);

    repeat(2) @(posedge clk);

    if(error_flag)
    begin
        pass_count = pass_count + 1;
        $display("FRAMING ERROR DETECTED : PASS");
    end
    else
    begin
        fail_count = fail_count + 1;
        $display("FRAMING ERROR DETECTED : FAIL");
    end

    // Random Data Test
    $display("");
    $display("RANDOM DATA TEST");
    for(i=0;i<20;i=i+1)
    begin
        data_in = $random;

        send_byte(data_in);

        check_byte(data_in);
    end

    // Final Summary
    $display("");
    $display("SIMULATION SUMMARY");
    $display("PASS COUNT = %0d", pass_count);
    $display("FAIL COUNT = %0d", fail_count);

    if(fail_count==0)
        $display("All Test Passed");
    else
        $display("Test Failed");

    $finish;

end

// Timeout Protection
initial begin

    #5000000;

    $display("");
    $display("SIMULATION TIMEOUT");

    $finish;

end

endmodule
