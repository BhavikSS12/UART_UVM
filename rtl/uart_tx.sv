// UART Transmitter Module
module uart_tx #(
    parameter CLKS_PER_BIT = 868  // 115200 baud @ 100MHz
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_serial,
    output logic       tx_done,
    output logic       tx_active
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
    logic [7:0]  tx_data_reg;
    logic        parity_bit;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            clk_count   <= 0;
            bit_index   <= 0;
            tx_serial   <= 1'b1;
            tx_done     <= 1'b0;
            tx_active   <= 1'b0;
            tx_data_reg <= 8'h00;
            parity_bit  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    tx_serial   <= 1'b1;
                    tx_done     <= 1'b0;
                    clk_count   <= 0;
                    bit_index   <= 0;
                    tx_active   <= 1'b0;
                    
                    if (tx_start) begin
                        tx_data_reg <= tx_data;
                        tx_active   <= 1'b1;
                        parity_bit  <= ^tx_data;  // Even parity
                        state       <= START;
                    end
                end
                
                START: begin
                    tx_serial <= 1'b0;  // Start bit
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= DATA;
                    end
                end
                
                DATA: begin
                    tx_serial <= tx_data_reg[bit_index];
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state     <= PARITY;
                        end
                    end
                end
                
                PARITY: begin
                    tx_serial <= parity_bit;
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= STOP;
                    end
                end
                
                STOP: begin
                    tx_serial <= 1'b1;  // Stop bit
                    
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        tx_done   <= 1'b1;
                        state     <= CLEANUP;
                    end
                end
                
                CLEANUP: begin
                    tx_done   <= 1'b0;
                    tx_active <= 1'b0;
                    state     <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule