module uart(

input clk,
input rst,


input tx_enable,
input [7:0] data,
output tx,
output busy,

input read_clear,
input rx,
output ready,
output [7:0] data_out

);

wire tx_tick;
wire rx_tick;

baud_generator bg(

.clk(clk),
.rst(rst),
.tx_tick(tx_tick),
.rx(tick_rx_tick)

);

tx tx1(

.clk(clk),
.rst(rst),
.tx_tick(tx_tick),
.enable(tx_enable),
.data(data),
.tx(tx),
.busy(busy)

);

rx rx1(

.clk(clk),
.rst(rst),
.rx_tick(rx_tick),
.read_clear(read_clear),
.rx(rx),
.ready(ready),
.data_out(data_out)



);


endmodule