`timescale 1ns / 1ps

module tb_tx;

    // Inputs
    reg clk;
    reg rst;
    reg tx_tick;
    reg enable;
    reg [7:0] data;

    // Outputs
    wire tx;
    wire busy;

    parameter CLK_PERIOD = 10;

    // Instantiate Unit Under Test
    tx uut (
        .clk(clk),
        .rst(rst),
        .tx_tick(tx_tick),
        .enable(enable),
        .data(data),
        .tx(tx),
        .busy(busy)
    );

    // 100 MHz Clock Generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Oversampling Clock Tick Generation (16 ticks per bit)
    always begin
        #(CLK_PERIOD * 4);
        tx_tick = 1'b1;
        #(CLK_PERIOD);
        tx_tick = 1'b0;
    end

    // Task to transmit a byte and verify the captured output frame
    task send_and_verify(input [7:0] test_byte);
        integer i, t;
        reg [7:0] captured_byte;
        begin
            captured_byte = 8'd0;

            $display("[%0t ns] Initiating TX for Data: 0x%h", $time, test_byte);
            
            // Pulse enable line
            data = test_byte;
            enable = 1'b1;
            #(CLK_PERIOD * 4);
            enable = 1'b0;

            // Wait until state machine enters TX_START
            wait(busy == 1'b1);

            // 1. Verify Start Bit (16 ticks)
            for (t = 0; t < 16; t = t + 1) @(posedge tx_tick);
            if (tx !== 1'b0) $display("ERROR: Start Bit low assertion failed!");

            // 2. Sample 8 Data Bits at midpoint of each bit frame (tick 8)
            for (i = 0; i < 8; i = i + 1) begin
                for (t = 0; t < 8; t = t + 1) @(posedge tx_tick);
                captured_byte[i] = tx; // Sample bit
                for (t = 0; t < 8; t = t + 1) @(posedge tx_tick);
            end

            // 3. Verify Stop Bit
            for (t = 0; t < 8; t = t + 1) @(posedge tx_tick);
            if (tx !== 1'b1) $display("ERROR: Stop Bit high assertion failed!");

            // Wait for completion
            wait(busy == 1'b0);

            // Display Results
            $display("[%0t ns] Captured Byte: 0x%h (Expected: 0x%h)", $time, captured_byte, test_byte);
            if (captured_byte === test_byte) begin
                $display("--> TEST PASSED\n");
            end else begin
                $display("--> TEST FAILED\n");
            end
        end
    endtask

    // Main Test Stimulus
    initial begin
        $dumpfile("tx_waveform.vcd");
        $dumpvars(0, tb_tx);

        // Initial setup
        clk = 1'b0;
        rst = 1'b1;
        tx_tick = 1'b0;
        enable = 1'b0;
        data = 8'd0;

        #(CLK_PERIOD * 10);
        rst = 1'b0;
        #(CLK_PERIOD * 10);

        // Test 1: Send 0xA5 (10100101)
        send_and_verify(8'hA5);
        #(CLK_PERIOD * 20);

        // Test 2: Send 0x3C (00111100)
        send_and_verify(8'h3C);
        #(CLK_PERIOD * 20);

        $display("[%0t ns] Simulation Complete.", $time);
        $finish;
    end

endmodule