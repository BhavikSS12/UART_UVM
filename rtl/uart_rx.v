module uart_rx(
    input clk,
    input rst,
    input rx,
    output reg [7:0]rx_msg,
    output reg rx_parity,
    output reg rx_busy,
    output reg error_flag
);
    localparam idle = 3'd0;
    localparam start_bit = 3'd1;
    localparam data_bit = 3'd2;
    localparam parity_bit = 3'd3;
    localparam stop_bit = 3'd4;
    localparam done = 3'd5;
    
    localparam clk_per_bit = 434;//baudrate = 115200
    
    reg rx_sync_1, rx_sync_2;
    reg [2:0] state;
    reg [9:0] cycle_count;
    reg [7:0] data_reg;
    reg [2:0]bit_index;
    
    initial begin
        rx_busy = 1'd0;
        rx_msg = 8'd0;
        rx_parity = 1'd0;
        state = idle;
        error_flag = 1'd0;
    end
    
    always @(posedge clk) begin
        if(rst) begin
            rx_sync_1 <= 1'b1;
            rx_sync_2 <= 1'b1;
            state <= idle;
            data_reg <= 8'd0;
            rx_msg <= 8'd0;
            rx_parity <= 1'd0;
            cycle_count <= 10'd0; 
            error_flag <= 1'd0;
            bit_index <= 3'd0; 
        end
        else begin
        rx_sync_1 <= rx;
        rx_sync_2 <= rx_sync_1;
        case(state) 
            idle: begin
                rx_busy <= 1'd0;
                data_reg <= 8'd0;
                rx_parity <= 1'd0;
                cycle_count <= 10'd0; 
                bit_index <= 3'd0;
                if (rx_sync_2 == 1'd0) begin
                    error_flag <= 1'd0;
                    state <= start_bit;
                end
            end
            
            start_bit: begin
                rx_busy <= 1'b1;
            
                if(cycle_count == (clk_per_bit-1)/2) begin
                    if(rx_sync_2 != 1'b0) begin
                        error_flag <= 1'b1;
                        cycle_count <= 0;
                        state <= idle;
                    end
                    else begin
                        cycle_count <= cycle_count + 1;
                    end
                end
                else if(cycle_count == clk_per_bit-1) begin
                    cycle_count <= 0;
                    state <= data_bit;
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            
            data_bit:begin
                rx_busy <= 1'd1;
                if(cycle_count == (clk_per_bit -1)/2) begin
                        data_reg[bit_index] <= rx_sync_2;
                end 
                if(cycle_count == clk_per_bit -1) begin
                    cycle_count <= 10'd0;
                    if (bit_index == 3'd7) begin
                        state <= parity_bit;
                    end
                    else begin
                        bit_index <= bit_index + 1; 
                    end 
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            
            parity_bit:begin
                rx_busy <= 1'd1;
                if(cycle_count == (clk_per_bit -1)/2) begin
                        rx_parity <= rx_sync_2;
                end 
                if(cycle_count == clk_per_bit -1) begin
                    cycle_count <= 10'd0;
                    state <= stop_bit;
                end 
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            
            stop_bit:begin
                rx_busy <= 1'd1;
                if(cycle_count == (clk_per_bit-1)/2) begin
                    if(rx_sync_2 != 1'b1) begin
                        error_flag <= 1'b1;
                        cycle_count <= 0;
                        state <= idle;
                    end
                    else begin
                        cycle_count <= cycle_count + 1;
                    end
                end
                else if(cycle_count == clk_per_bit-1) begin
                    cycle_count <= 0;
                    state <= done;
                end
                else begin
                    cycle_count <= cycle_count + 1;
                end
            end
            
            done: begin
                rx_busy <= 1'd0;
                rx_msg <= data_reg;
                if(^{data_reg} == rx_parity)begin
                    error_flag <= 1'd0;
                end
                else begin
                    error_flag <= 1'd1;
                end
                state <= idle;
            end
        endcase
        
        end
    end
endmodule