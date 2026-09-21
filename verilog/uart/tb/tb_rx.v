`timescale 1ns / 1ps

module tb_rx;

    // Inputs
    reg clk;
    reg rst;
    reg rx_tick;
    reg read_clear;
    reg rx;

    // Outputs
    wire ready;
    wire [7:0] data_out;

    // Clock definitions (100 MHz main clock)
    parameter CLK_PERIOD = 10; 
    
    // Instantiate Unit Under Test (UUT)
    rx uut (
        .clk(clk),
        .rst(rst),
        .rx_tick(rx_tick),
        .read_clear(read_clear),
        .rx(rx),
        .ready(ready),
        .data_out(data_out)
    );

    // Clock generation
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Continuous rx_tick generator (oversampling clock)
    // Runs 16 times faster than the baud rate pulse needed for bit processing
    always begin
        #(CLK_PERIOD * 4);
        rx_tick = 1'b1;
        #(CLK_PERIOD);
        rx_tick = 1'b0;
    end

    // Task to send 1 byte over RX with 16 ticks per bit
    task send_uart_byte(input [7:0] byte_to_send);
        integer i, t;
        begin
            // Start Bit (LOW)
            rx = 1'b0;
            for (t = 0; t < 16; t = t + 1) @(posedge rx_tick);

            // Data Bits (LSB First)
            for (i = 0; i < 8; i = i + 1) begin
                rx = byte_to_send[i];
                for (t = 0; t < 16; t = t + 1) @(posedge rx_tick);
            end

            // Stop Bit (HIGH)
            rx = 1'b1;
            for (t = 0; t < 16; t = t + 1) @(posedge rx_tick);
        end
    endtask

    // Main Test Stimulus
    initial begin
        // Waveform dumping for GTKWave / ModelSim / Icarus
        $dumpfile("rx_waveform.vcd");
        $dumpvars(0, tb_rx);

        // Initial state
        clk = 1'b0;
        rst = 1'b1;
        rx_tick = 1'b0;
        read_clear = 1'b0;
        rx = 1'b1; // Idle state is HIGH

        // Apply Reset
        #(CLK_PERIOD * 10);
        rst = 1'b0;
        #(CLK_PERIOD * 10);

        // --- TEST 1: Transmit Valid Byte 0xA5 (10100101) ---
        $display("[%0t ns] Test 1: Sending 0xA5...", $time);
        send_uart_byte(8'hA5);

        // Wait for ready flag
        wait(ready == 1'b1);
        $display("[%0t ns] Received: 0x%h (Expected: 0xA5)", $time, data_out);
        
        if (data_out === 8'hA5) $display("--> TEST 1 PASSED");
        else $display("--> TEST 1 FAILED");

        // Clear Ready flag
        #(CLK_PERIOD * 5);
        read_clear = 1'b1;
        #(CLK_PERIOD);
        read_clear = 1'b0;
        #(CLK_PERIOD * 10);

        // --- TEST 2: Transmit Valid Byte 0x3C (00111100) ---
        $display("[%0t ns] Test 2: Sending 0x3C...", $time);
        send_uart_byte(8'h3C);

        wait(ready == 1'b1);
        $display("[%0t ns] Received: 0x%h (Expected: 0x3C)", $time, data_out);

        if (data_out === 8'h3C) $display("--> TEST 2 PASSED");
        else $display("--> TEST 2 FAILED");

        // Clear Ready flag
        #(CLK_PERIOD * 5);
        read_clear = 1'b1;
        #(CLK_PERIOD);
        read_clear = 1'b0;
        #(CLK_PERIOD * 20);

        $display("[%0t ns] Simulation Complete.", $time);
        $finish;
    end

endmodule