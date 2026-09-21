module uart_echo (
    input wire clk,
    
    // Status LEDs
    output wire led_amber_n,   
    output wire led_blue_n,    
    output wire led_rgb_red_n,
    output wire led_rgb_green_n,
    output wire led_rgb_blue_n,
    
    // Serial Pins
    input wire rx,
    output wire tx
);

    // Active-LOW Reset Generator
    reg [3:0] por_count = 4'd0;
    reg internal_rstn = 1'b0; // Start in RESET (0)

    always @(posedge clk) begin
        if (por_count < 4'd15) begin
            por_count     <= por_count + 4'd1;
            internal_rstn <= 1'b0; // Held in Reset (Active-LOW)
        end else begin
            internal_rstn <= 1'b1; // Release Reset (HIGH)
        end
    end

    // Internal Connections
    wire       rx_ready;
    wire [7:0] rx_byte;
    wire       tx_busy;
    
    reg        tx_enable;
    reg        read_clear;
    reg  [7:0] tx_byte;

    // LED Status Outputs (Active-Low)
    assign led_amber_n     = ~rx_ready;
    assign led_blue_n      = ~tx_busy;
    assign led_rgb_red_n   = ~rx_byte[0];
    assign led_rgb_green_n = ~rx_byte[1];
    assign led_rgb_blue_n  = ~rx_byte[2];

    // UART Instance
    uart uart0 (
        .clk        (clk),
        .rstn       (internal_rstn), // Active-LOW reset passed correctly
        
        .tx_enable  (tx_enable),
        .data       (tx_byte),
        .tx         (tx),
        .busy       (tx_busy),
        
        .read_clear (read_clear),
        .rx         (rx),
        .ready      (rx_ready),
        .data_out   (rx_byte)
    );

    // Echo Logic
    always @(posedge clk) begin
        if (!internal_rstn) begin
            tx_enable  <= 1'b0;
            read_clear <= 1'b0;
            tx_byte    <= 8'd0;
        end else begin
            tx_enable  <= 1'b0;
            read_clear <= 1'b0;

            if (rx_ready && !tx_busy) begin
                tx_byte    <= rx_byte;
                tx_enable  <= 1'b1;
                read_clear <= 1'b1;
            end
        end
    end

endmodule