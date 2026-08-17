// module blink_test (
// 	input wire clk,
// 	output wire led_blue_n,
// 	output wire led_amber_n
// );

// reg [26:0] counter = 0;

// always @(posedge clk)
//     counter <= counter + 1;

// assign led_blue_n = counter[23];
// assign led_amber_n = ~led_blue_n;

// endmodule


module blink_test (
        input btn1_n,
        input btn2_n,
	output led_blue_n,
        output led_amber_n
);

assign led_blue_n  = btn1_n;
assign led_amber_n = btn2_n;  

endmodule
