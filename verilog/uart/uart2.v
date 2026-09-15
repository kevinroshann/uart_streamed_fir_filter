module uart(
    input clk,
    input rst,
    input rx

);

localparam uart_baud_rate = 115200;
localparam system_clk_rate = 12_000_000;

localparam module_baud = system_clk_rate / uart_baud_rate; 
localparam rx_range = $clog2(module_baud);
localparam tx_range = $clog2(module_baud);


reg [7:0] rx_data; 

localparam [2:0] 
    RX_IDLE     = 3'd0,
    RX_START    = 3'd1,
    RX_DATA     = 3'd2,
    RX_STOP     = 3'd3,
    RX_ERROR    = 3'd4,
    RX_SAMPLING = 3'd5,
    RX_VALIDATE = 3'd6; 

reg [2:0] rx_state = RX_IDLE;
reg [2:0] next_state;

reg [rx_range-1:0] rx_clk;
reg [tx_range-1:0] tx_clk;

reg [2:0] sampling_bits_remaining;
reg [2:0] sampling_val;


reg [3:0] rx_data_count; 

wire recieved_correctly = (rx_state == RX_VALIDATE);

always @(posedge clk) begin
    if (rst) begin
        rx_state<= RX_IDLE;
        rx_clk  <= 0;
        tx_clk  <= 0; 
        rx_data <= 8'd0;
        rx_data_count<= 4'd0;
        sampling_bits_remaining <= 3'd0;
        sampling_val<= 3'd0;
    end else begin

        if (rx_clk > 0) begin
            rx_clk <= rx_clk - 1'b1;
        end
        if (tx_clk > 0) begin
            tx_clk <= tx_clk - 1'b1;
        end


        case (rx_state)

            RX_IDLE: begin
                if (!rx) begin
                    rx_state <= RX_START;
                    rx_clk   <= module_baud / 2;
                    rx_data  <= 8'd0;
                    rx_data_count <= 4'd0;
                end
            end

            RX_START: begin
                if (rx_clk == 0) begin
                    if (!rx) begin
                        rx_state                <= RX_SAMPLING;
                        rx_clk                  <= (module_baud / 2) + (2 * module_baud / 8);
                        sampling_bits_remaining <= 3'd5;
                        sampling_val            <= 3'd0;
                    end else begin
                        rx_state <= RX_ERROR;
                    end
                end
            end

            RX_SAMPLING: begin
                if (rx_clk == 0) begin
                    if (rx) begin
                        sampling_val <= sampling_val + 3'd1;
                    end
                    
                    sampling_bits_remaining <= sampling_bits_remaining - 3'd1;
                    rx_clk <= module_baud / 8;
                    
                    if (sampling_bits_remaining == 3'd1) begin
                        rx_state <= RX_DATA;
                        rx_clk   <= module_baud / 8;
                    end
                end
            end

            RX_DATA: begin
                if (rx_clk == 0) begin
                    rx_data <= {(sampling_val > 3'd2), rx_data[7:1]};

                    rx_data_count <= rx_data_count + 4'd1;
                    
                    if (rx_data_count < 4'd7) begin
                        rx_clk                  <= 2 * module_baud / 8;
                        rx_state                <= RX_SAMPLING;
                        sampling_val            <= 3'd0;
                        sampling_bits_remaining <= 3'd5;
                    end else if (rx_data_count == 4'd7) begin
                        rx_clk   <= 4 * module_baud / 8;
                        rx_state <= RX_STOP;
                    end
                end
            end

            RX_STOP: begin
                if (rx_clk == 0) begin
                    if (!rx) begin
                        rx_state <= RX_ERROR;
                        rx_clk   <= module_baud;
                    end else begin
                        rx_state <= RX_VALIDATE;
                        rx_clk   <= module_baud;
                    end
                end
            end

            RX_ERROR: begin
                if (rx_clk == 0) begin
                    rx_state <= RX_IDLE;
                end
            end

            RX_VALIDATE: begin
                if (rx_clk == 0) begin
                    rx_state <= RX_IDLE;
                end
            end

            default: rx_state <= RX_IDLE;

        endcase
    end
end

endmodule