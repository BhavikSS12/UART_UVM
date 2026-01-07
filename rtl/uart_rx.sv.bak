// UART Receiver Module
module uart_rx #(
    parameter CLKS_PER_BIT = 868
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       rx_serial,
    output logic [7:0] rx_data,
    output logic       rx_done,
    output logic       parity_error,
    output logic       frame_error
);

    typedef enum logic [2:0] {
        IDLE    = 3'b000,
        START   = 3'b001,
        DATA    = 3'b010,
        PARITY  = 3'b011,
        STOP    = 3'b100,
        CLEANUP = 3'b101
    } state_t;

    state_t state;
    logic [15:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  rx_data_reg;
    logic        rx_serial_reg;
    logic        parity_bit;
    logic        calc_parity;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state         <= IDLE;
            clk_count     <= 0;
            bit_index     <= 0;
            rx_data       <= 8'h00;
            rx_data_reg   <= 8'h00;
            rx_done       <= 1'b0;
            parity_error  <= 1'b0;
            frame_error   <= 1'b0;
            rx_serial_reg <= 1'b1;
            parity_bit    <= 1'b0;
        end else begin
            rx_serial_reg <= rx_serial;
            
            case (state)
                IDLE: begin
                    rx_done      <= 1'b0;
                    clk_count    <= 0;
                    bit_index    <= 0;
                    parity_error <= 1'b0;
                    frame_error  <= 1'b0;
                    
                    if (rx_serial_reg == 1'b0) begin  // Start bit detected
                        state <= START;
                    end
                end
                
                START: begin
                    if (clk_count == (CLKS_PER_BIT - 1) / 2) begin
                        if (rx_serial_reg == 1'b0) begin
                            clk_count <= 0;
                            state     <= DATA;
                        end else begin
                            state <= IDLE;  // False start
                        end
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end
                
                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count                <= 0;
                        rx_data_reg[bit_index]   <= rx_serial_reg;
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state     <= PARITY;
                        end
                    end
                end
                
                PARITY: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count    <= 0;
                        parity_bit   <= rx_serial_reg;
                        calc_parity  <= ^rx_data_reg;  // Even parity
                        state        <= STOP;
                    end
                end
                
                STOP: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        
                        // Check stop bit
                        if (rx_serial_reg == 1'b1) begin
                            frame_error <= 1'b0;
                        end else begin
                            frame_error <= 1'b1;
                        end
                        
                        // Check parity
                        if (parity_bit == calc_parity) begin
                            parity_error <= 1'b0;
                        end else begin
                            parity_error <= 1'b1;
                        end
                        
                        rx_data  <= rx_data_reg;
                        rx_done  <= 1'b1;
                        state    <= CLEANUP;
                    end
                end
                
                CLEANUP: begin
                    rx_done <= 1'b0;
                    state   <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule