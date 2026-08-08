module blink_test (
	input wire clk,
	output wire led_blue_n,
	output wire led_amber_n
);

reg [26:0] counter = 0;

always @(posedge clk)
    counter <= counter + 1;

assign led_blue_n = counter[23];
assign led_amber_n = ~counter[23];

endmodule
