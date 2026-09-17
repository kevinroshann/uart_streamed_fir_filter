`timescale 1ns / 1ps

module tb_uart;

    reg clk = 0;
    always #(41.7) clk = ~clk;

    reg rst_n = 1'b0;
    initial begin
        #(100) rst_n = 1'b1;
    end

    // ---- Shared DUT input signals (reg) ----
    reg [7:0] data;
    reg read_clear;
    reg rst;
    reg rx;
    reg tx_enable;

    // ---- Shared DUT output signals (wire) ----
    wire busy;
    wire [7:0] data_out;
    wire ready;
    wire tx;

    // ---- DUT: uart (u_uart) ----
    uart u_uart (
        .clk        ( clk        ),
        .rst        ( rst        ),
        .tx_enable  ( tx_enable  ),
        .data       ( data       ),
        .tx         ( tx         ),
        .busy       ( busy       ),
        .read_clear ( read_clear ),
        .rx         ( rx         ),
        .ready      ( ready      ),
        .data_out   ( data_out   ));

    initial begin
        $dumpfile("tb_uart.vcd");
        $dumpvars(0, tb_uart);
    end

    initial begin
        #(1000000) $finish;
    end

endmodule
