module baud_generator(

input clk,
input rst,

output reg tx_tick,
output reg rx_tick

);

localparam system_clk=12_000_000;
localparam baud_rate=115200;

localparam rx_needed=(baud_rate*16);


reg [23:0] acc_rx;
reg [3:0] tx_cnt;
always @(posedge clk) begin
    if(rst) begin
tx_tick<=0;
        rx_tick<=0;
        acc_rx<=0;
        tx_cnt<=0;
    end
    else begin
        rx_tick <= 1'b0;
        tx_tick <= 1'b0;
        if(acc_rx>=system_clk-rx_needed) begin
            rx_tick<=1'b1;
            tx_cnt<=tx_cnt+4'd1;
            acc_rx<=acc_rx+rx_needed-system_clk;
            if (tx_cnt == 4'd15) begin
                    tx_tick <= 1'b1; 
                end 
        end
        else begin

            acc_rx<=acc_rx+rx_needed;
        end



    end
end


endmodule

