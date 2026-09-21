module uart_echo (
    input wire clk,
    input wire rx,
    output wire tx
);

    // Internal Signals
    wire       rx_ready;
    wire [7:0] rx_byte;
    wire [7:0] filtered_byte;
    wire       tx_busy;
    
    reg        tx_enable  = 1'b0;
    reg        read_clear = 1'b0;
    reg  [7:0] tx_byte    = 8'd0;

    reg        filter_en  = 1'b0;
    reg        pending_tx = 1'b0;

    // 1. UART Module Instance
    uart uart0 (
        .clk        (clk),
        .rstn       (1'b1),
        .tx_enable  (tx_enable),
        .data       (tx_byte),
        .tx         (tx),
        .busy       (tx_busy),
        .read_clear (read_clear),
        .rx         (rx),
        .ready      (rx_ready),
        .data_out   (rx_byte)
    );

    // 2. Filter Instance
    filter filter0 (
        .clk      (clk),
        .rstn     (1'b1),
        .en       (filter_en),
        .sig      (rx_byte),
        .samp_op  (),
        .trunc_op (filtered_byte)
    );

    // 3. Control & Echo Logic
    always @(posedge clk) begin
        tx_enable  <= 1'b0;
        read_clear <= 1'b0;
        filter_en  <= 1'b0;

        // Step 1: Clock new sample into FIR filter
        if (rx_ready && !tx_busy && !pending_tx) begin
            filter_en  <= 1'b1;
            read_clear <= 1'b1;
            pending_tx <= 1'b1;
        end 
        // Step 2: Read updated filtered byte on next clock cycle
        else if (pending_tx) begin
            tx_byte    <= filtered_byte;
            tx_enable  <= 1'b1;
            pending_tx <= 1'b0;
        end
    end

endmodule