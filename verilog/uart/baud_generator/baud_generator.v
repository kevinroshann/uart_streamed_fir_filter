module baud_generator(

input clk,
input rstn,
output reg tick


);

localparam system_clk=12_000_000;
localparam baud_rate=115200;

localparam rx_needed=(baud_rate*16);


reg [23:0] acc_rx=23'd0;



always @(posedge clk) begin
if (!rstn) begin
        tick <= 1'b0;
        acc_rx  <= 23'd0;

    end
    else begin
        tick <= 1'b0;

        if(acc_rx>=system_clk-rx_needed) begin
            tick<=1'b1;
            acc_rx<=acc_rx+rx_needed-system_clk;

        end
        else begin

            acc_rx<=acc_rx+rx_needed;
        end



    end
end


endmodule

