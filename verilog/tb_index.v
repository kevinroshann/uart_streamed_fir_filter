`timescale 1ns / 1ps

module tb_index;

    reg clk;
    always #(5.0) clk = ~clk;

    reg rst_n = 1'b0;


    // ---- Shared DUT input signals (reg) ----
    reg rstn;
    reg [7:0] sig;

    // ---- Shared DUT output signals (wire) ----
    wire [19:0] samp_op;
    wire [7:0] trunc_op;
reg signed [7:0] x_input [0:4];
    // ---- DUT: filter (u_filter) ----
    filter u_filter (
        .clk      ( clk      ),
        .rstn     ( rstn     ),
        .sig      ( sig      ),
        .samp_op  ( samp_op  ),
        .trunc_op ( trunc_op ));

    initial begin
        $dumpfile("tb_index.vcd");
        $dumpvars(0, tb_index);
    end
integer i;
    initial begin

        clk=0;
        rstn=0;
        sig=8'sd0;


        x_input[0] = 8'sd1;
        x_input[1] = 8'sd2;
        x_input[2] = 8'sd3;
        x_input[3] = 8'sd4;
        x_input[4] = 8'sd5;


        #15 rstn=1;
// Stream 5 inputs + 1 extra zero sample to flush the last calculation
for (i = 0; i < 20; i = i + 1) begin
    @(posedge clk);
    if (i < 5) 
        sig <= x_input[i];
    else 
        sig <= 8'sd0; // Flush sample

    #1;
    $display("Cycle = %0d | sig = %3d | samp_op = %5d | trunc_op = %5d", i + 1, sig, $signed(samp_op), $signed(trunc_op));
end
        #20;
$finish;
    end

endmodule
