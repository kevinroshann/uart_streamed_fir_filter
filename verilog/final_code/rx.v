module rx (
    input clk,
    input rstn,
    input rx_tick,
    input read_clear,
    input rx,
    output ready,
    output [7:0] data_out
);

localparam [2:0] 
    RX_IDLE  = 3'd0,
    RX_START = 3'd1,
    RX_DATA  = 3'd2,
    RX_STOP  = 3'd3,
    RX_ERROR = 3'd4;

reg start_valid = 1'b0;
reg stop_valid = 1'b0;
reg [2:0] rx_state = RX_IDLE;
reg [3:0] rx_tick_cnt = 4'd0;
reg rx_sync_1 = 1'b1;
reg rx_sync_2 = 1'b1;

reg [2:0] sampling = 3'd0;
reg [3:0] data_cnt = 4'd0;
reg [7:0] data = 8'd0;
reg ready_reg = 1'b0;

assign ready = ready_reg;
assign data_out = data;

//to prevent metastability
always @(posedge clk) begin
    rx_sync_1 <= rx;
    rx_sync_2 <= rx_sync_1;
end

// Main FSM
always @(posedge clk) begin
    if (!rstn) begin
        rx_state    <= RX_IDLE;
        rx_tick_cnt <= 4'd0;
        data_cnt    <= 4'd0;
        sampling    <= 3'd0;
        start_valid <= 1'b0;
        stop_valid  <= 1'b0;
        ready_reg   <= 1'b0;
    end else begin
        // Ready clear flag logic
        if (read_clear) begin
            ready_reg <= 1'b0;
        end

        case (rx_state)

RX_IDLE: begin
    start_valid <= 1'b0;
    stop_valid  <= 1'b0;
    rx_tick_cnt <= 4'd0;
    data_cnt    <= 4'd0;
    if (!rx_sync_2) begin
        rx_state   <= RX_START;
        baud_clear <= 1'b1; // Reset baud tick phase to align with start bit edge
    end
end

            RX_START: begin
                if (rx_tick) begin
                    rx_tick_cnt <= rx_tick_cnt + 4'd1;
                    
                    // Sample start bit at midpoint tick 7
                    if (rx_tick_cnt == 4'd7) begin
                        if (!rx_sync_2) begin
                            start_valid <= 1'b1;
                        end
                    end

if (rx_tick_cnt == 4'd15) begin
    if (start_valid) begin
        rx_state    <= RX_DATA;
        sampling    <= 3'd0;
        data_cnt    <= 4'd0;
        rx_tick_cnt <= 4'd0; 
    end else begin
        rx_state    <= RX_IDLE;
    end
end
                end
            end

            RX_DATA: begin
                if (rx_tick) begin
                    rx_tick_cnt <= rx_tick_cnt + 4'd1;
                    if (rx_tick_cnt <= 4'd5)  sampling <= 3'd0;
                    // 5-sample majority voting window
                    if (rx_tick_cnt == 4'd6)  sampling <= sampling + rx_sync_2;
                    if (rx_tick_cnt == 4'd7)  sampling <= sampling + rx_sync_2;
                    if (rx_tick_cnt == 4'd8)  sampling <= sampling + rx_sync_2;
                    if (rx_tick_cnt == 4'd9)  sampling <= sampling + rx_sync_2;
                    if (rx_tick_cnt == 4'd10) sampling <= sampling + rx_sync_2;

                    if (rx_tick_cnt == 4'd15) begin
                        // LSB-first shift register logic
                        if (sampling >= 3'd3) begin
                            data <= {1'b1, data[7:1]};
                        end else begin
                            data <= {1'b0, data[7:1]};
                        end

                        data_cnt <= data_cnt + 4'd1;
                        sampling <= 3'd0;

                        if (data_cnt == 4'd7) begin
                            rx_state <= RX_STOP;
                        end
                    end
                end
            end

            RX_STOP: begin
                if (rx_tick) begin
                    rx_tick_cnt <= rx_tick_cnt + 4'd1;

                    // Check stop bit line status at midpoint tick 7
                    if (rx_tick_cnt == 4'd7) begin
                        if (rx_sync_2) begin
                            stop_valid <= 1'b1;
                        end
                    end

                    if (rx_tick_cnt == 4'd15) begin
                        if (stop_valid) begin
                            rx_state  <= RX_IDLE;
                            ready_reg <= 1'b1;
                        end else begin
                            rx_state <= RX_ERROR;
                        end
                    end
                end
            end

RX_ERROR: begin
    if (rx_tick) begin
        rx_tick_cnt <= rx_tick_cnt + 4'd1;

        if (rx_tick_cnt == 4'd15 && rx_sync_2) begin
            rx_state <= RX_IDLE;
        end
    end
end

            default: rx_state <= RX_IDLE;

        endcase
    end
end

endmodule