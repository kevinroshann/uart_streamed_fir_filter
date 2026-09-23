module uart_with_filter (
    input wire clk,
    input wire rx,
    output wire tx,
    input wire btn1_n 
);

    wire rx_ready;
    wire [7:0] rx_byte;
    wire [7:0] filtered_byte;
    wire tx_busy;
    
    reg  tx_enable  = 1'b0;
    reg read_clear = 1'b0;
    reg  [7:0] tx_byte    = 8'd0;

    reg filter_en  = 1'b0;
    reg pending_tx = 1'b0;

reg rst_n_sync1, rst_n;
    always @(posedge clk) begin
        rst_n_sync1 <= btn1_n;
        rst_n       <= rst_n_sync1;
    end

    uart uart0 (
        .clk (clk),
        .rstn(rst_n),
        .tx_enable  (tx_enable),
        .data(tx_byte),
        .tx  (tx),
        .busy(tx_busy),
        .read_clear (read_clear),
        .rx  (rx),
        .ready(rx_ready),
        .data_out   (rx_byte)
    );


    filter filter0 (
        .clk(clk),
        .rstn(rst_n),
        .en(filter_en),
        .sig(rx_byte),
        .samp_op(),
        .trunc_op (filtered_byte)
    );


    always @(posedge clk) 
    if (!rst_n) begin
            tx_enable  <= 1'b0;
            read_clear <= 1'b0;
            filter_en  <= 1'b0;
            pending_tx <= 1'b0;
            tx_byte    <= 8'd0;
        end else
        begin
        tx_enable  <= 1'b0;
        read_clear <= 1'b0;
        filter_en  <= 1'b0;


        if (rx_ready && !tx_busy && !pending_tx) begin
            filter_en  <= 1'b1;
            read_clear <= 1'b1;
            pending_tx <= 1'b1;
        end 

        else if (pending_tx) begin
            tx_byte    <= filtered_byte;
            tx_enable  <= 1'b1;
            pending_tx <= 1'b0;
        end
    end

endmodule