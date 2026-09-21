module tx (
    input clk,
    input rstn,
    input tx_tick,
    input enable,
    input [7:0] data,
    output tx,
    output busy
);
    
    reg tx_reg = 1'b1;
    assign tx = tx_reg;
    assign busy = (tx_state != TX_IDLE);

    localparam [1:0]
        TX_IDLE  = 2'd0,
        TX_START = 2'd1,
        TX_DATA  = 2'd2,
        TX_STOP  = 2'd3;

    reg [1:0] tx_state = TX_IDLE;
    reg [7:0] tx_data_reg = 8'd0;
    reg [2:0] bit_cnt = 3'd0;
    reg [3:0] tick_cnt = 4'd0;

    reg tx_sync_1 = 1'b0;
    reg tx_sync_2 = 1'b0;

    always @(posedge clk) begin
        tx_sync_1 <= enable;
        tx_sync_2 <= tx_sync_1;
    end

    always @(posedge clk) begin
        if (!rstn) begin
            tx_state    <= TX_IDLE;
            tx_reg      <= 1'b1;
            tx_data_reg <= 8'd0;
            bit_cnt     <= 3'd0;
            tick_cnt    <= 4'd0;
        end else begin
            case (tx_state)

                TX_IDLE: begin
                    tx_reg   <= 1'b1;
                    tick_cnt <= 4'd0;
                    bit_cnt  <= 3'd0;
                    if (tx_sync_2) begin
                        tx_state    <= TX_START;
                        tx_data_reg <= data;
                    end
                end

                TX_START: begin
                    tx_reg <= 1'b0; // Start bit LOW
                    if (tx_tick) begin
                        if (tick_cnt == 4'd15) begin
                            tick_cnt <= 4'd0;
                            tx_state <= TX_DATA;
                        end else begin
                            tick_cnt <= tick_cnt + 4'd1;
                        end
                    end
                end

                TX_DATA: begin
                    tx_reg <= tx_data_reg[0]; // Drive LSB
                    if (tx_tick) begin
                        if (tick_cnt == 4'd15) begin
                            tick_cnt    <= 4'd0;
                            tx_data_reg <= tx_data_reg >> 1;
                            if (bit_cnt == 3'd7) begin
                                bit_cnt  <= 3'd0;
                                tx_state <= TX_STOP;
                            end else begin
                                bit_cnt <= bit_cnt + 3'd1;
                            end
                        end else begin
                            tick_cnt <= tick_cnt + 4'b1;
                        end
                    end
                end

                TX_STOP: begin
                    tx_reg <= 1'b1; // Stop bit HIGH
                    if (tx_tick) begin
                        if (tick_cnt == 4'd15) begin
                            tick_cnt <= 4'd0;
                            tx_state <= TX_IDLE;
                        end else begin
                            tick_cnt <= tick_cnt + 4'd1;
                        end
                    end
                end

                default: tx_state <= TX_IDLE;

            endcase
        end
    end

endmodule