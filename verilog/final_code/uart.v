module uart(

input clk,
input rstn,


input tx_enable,
input [7:0] data,
output tx,
output busy,

input read_clear,
input rx,
output ready,
output [7:0] data_out

);

wire tick;


baud_generator bg(

.clk(clk),
.rstn(rstn),
.tick(tick)


);

tx tx1(

.clk(clk),
.rstn(rstn),
.tx_tick(tick),
.enable(tx_enable),
.data(data),
.tx(tx),
.busy(busy)

);

rx rx1(

.clk(clk),
.rstn(rstn),
.rx_tick(tick),
.read_clear(read_clear),
.rx(rx),
.ready(ready),
.data_out(data_out)



);


endmodule