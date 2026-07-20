module uart_tx(
    input clk, // 50Mz
    input rst,
    input parity_type,
    input [7:0]data_in,
    input tx_start,//active low
    output reg tx , tx_done
    );
    
    initial begin
    tx = 1'b1;
    tx_done = 1'b0;
    end
    
    localparam idle = 3'b000;
    localparam start_bit = 3'b001;
    localparam data_bit = 3'b010;
    localparam parity_bit = 3'b011;
    localparam stop_bit = 3'b100;
    localparam done = 3'b101;
    
    // baudrate calculation for cycle per bit => clk/baudrate = 434.02
    localparam clk_per_bit = 434; //baudrate = 115200
    
    reg [2:0] state;
    reg [9:0] cycle_count;
    reg [7:0]data_reg;
    reg [2:0] bit_index;
    reg parity;
    
    initial begin
    state = idle;
    end
    
    always @(*) begin
        if(state == idle) begin
        tx = 1'b1;
        tx_done = 1'b0;
        end else if(state == start_bit) begin
        tx = 1'b0;
        tx_done = 1'b0;
        end else if(state == data_bit) begin
        tx = data_reg[bit_index];
        tx_done = 1'b0;
        end else if(state == parity_bit) begin
        tx = parity;
        tx_done = 1'b0;
        end else if(state == stop_bit) begin
        tx = 1'b1;
        tx_done = 1'b0;
        end else if(state == done) begin
        tx = 1'b1;
        tx_done = 1'b1;
        end else begin
        tx = 1'b0;
        tx_done = 1'b0;
        end
    end 
    
    always @(posedge clk) begin
    if(rst) begin
        state <= idle;
        cycle_count <= 10'd0;
        bit_index <= 3'd0;
        parity <= 0;
        data_reg <= 0;
    end
    else begin
    case(state)
    idle: begin
        
        cycle_count <= 10'b0;
        bit_index <= 3'b0;
        if(tx_start == 0) begin
            data_reg <= data_in;
            if(parity_type == 1)begin
                parity <= ^{data_in[0],data_in[1],data_in[2],data_in[3],data_in[4],data_in[5],data_in[6],data_in[7]};
            end 
            else begin 
                parity <= ~(^{data_in[0],data_in[1],data_in[2],data_in[3],data_in[4],data_in[5],data_in[6],data_in[7]});
           end
        cycle_count <= 10'd1;
        state <= start_bit;
        end
    end  
      
    start_bit: begin
        
         if(cycle_count == clk_per_bit -1)begin
            cycle_count <= 10'd0;
            state <= data_bit;
         end
         else begin
            cycle_count<=cycle_count+1;
         end
    end
    
    data_bit: begin 
         if(cycle_count == clk_per_bit-1) begin
            cycle_count <= 10'd0;
            if(bit_index == 3'd7)begin
                state <= parity_bit;
            end
            else begin
                bit_index <= bit_index + 1;
            end
         end
         else begin
            cycle_count<=cycle_count+1;
         end
    end
    
    parity_bit: begin
       
         if(cycle_count == clk_per_bit -1)begin
            cycle_count <= 10'd0;
            state <= stop_bit;
         end
         else begin
            cycle_count<=cycle_count+1;
         end
    end
    
    stop_bit: begin
        if(cycle_count == clk_per_bit -1)begin
            cycle_count <= 10'd0;
            state <= done;
         end
         else begin
            cycle_count<=cycle_count+1;
         end
    end
    
    done: begin
        state <= idle;
    end    
                
    endcase
    end
    end   
       
endmodule