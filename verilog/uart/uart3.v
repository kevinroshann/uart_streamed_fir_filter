module uart (
    input  wire clk,
    input  wire rst,
    input  wire rx,
    output reg  [7:0] rx_data,
    output wire rx_valid,
    output wire rx_error
);

    // 12MHz / 115200 = ~104 clocks per bit
    localparam CLKS_PER_BIT = 12_000_000 / 115200;
    localparam CNT_WIDTH    = $clog2(CLKS_PER_BIT);

    localparam [2:0] 
        IDLE  = 3'd0,
        START = 3'd1,
        DATA  = 3'd2,
        STOP  = 3'd3,
        CLEAN = 3'd4;

    reg [2:0] state = IDLE;
    reg [CNT_WIDTH-1:0] clk_cnt = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_shift_reg = 0;
    
    // 2-stage synchronizer to prevent metastability
    reg rx_sync_1 = 1'b1;
    reg rx_sync_2 = 1'b1;

    always @(posedge clk) begin
        rx_sync_1 <= rx;
        rx_sync_2 <= rx_sync_1;
    end

    assign rx_valid = (state == CLEAN);
    assign rx_error = (state == STOP && clk_cnt == (CLKS_PER_BIT - 1) && !rx_sync_2);

    always @(posedge clk) begin
        if (rst) begin
            state       <= IDLE;
            clk_cnt     <= 0;
            bit_index   <= 0;
            rx_data     <= 8'd0;
            rx_shift_reg<= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    clk_cnt   <= 0;
                    bit_index <= 0;
                    if (!rx_sync_2) // Detect start bit falling edge
                        state <= START;
                end

                // Sample in the middle of the start bit (CLKS_PER_BIT / 2)
                START: begin
                    if (clk_cnt == (CLKS_PER_BIT - 1) / 2) begin
                        if (!rx_sync_2) begin
                            clk_cnt <= 0;
                            state   <= DATA;
                        end else begin
                            state   <= IDLE; // False start bit detection
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                // Sample each bit in the middle of its cycle duration
                DATA: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        rx_shift_reg[bit_index] <= rx_sync_2;

                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 3'd1;
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                // Verify stop bit (high signal)
                STOP: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        if (rx_sync_2) begin
                            rx_data <= rx_shift_reg;
                            state   <= CLEAN;
                        end else begin
                            state   <= IDLE; // Framing error
                        end
                    end else begin
                        clk_cnt <= clk_cnt + 1'b1;
                    end
                end

                CLEAN: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule