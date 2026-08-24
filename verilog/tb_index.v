`timescale 1ns / 1ps
`include "index.v"
module tb_index;

    reg clk = 0;
    always #(5.0) clk = ~clk;

    reg rst_n = 1'b0;
    initial begin
        // #(100) rst_n = 1'b1;

    end

    // ---- Shared DUT input signals (reg) ----
    reg rstn;
    reg [7:0] sig;

    // ---- Shared DUT output signals (wire) ----
    wire [19:0] trunc_op;

    // ---- DUT: filter (u_filter) ----
    filter u_filter (
        .clk      ( clk      ),
        .rstn     ( rstn     ),
        .sig      ( sig      ),
        .trunc_op ( trunc_op ));

    initial begin
        $dumpfile("tb_index.vcd");
        $dumpvars(0, tb_index);
    end

    initial begin
        
        #(100) rst_n = 1'b1;
        @(posedge clk);
        #(1)
        sig<=8'b0000_0001;

        @(posedge clk);
        #(1)
        sig<=8'b0000_0011;

        @(posedge clk);
        #(1)
        sig<=8'b0000_0111;



        #(1000000) $finish;
    end

initial begin
    $monitor("Time: %0t | a changed to: %d", $time, a);
end

endmodule
