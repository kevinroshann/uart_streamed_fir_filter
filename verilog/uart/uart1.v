module uart1(
input clk,
input rst,

input rx,
output tx,

input transmit,
input [7:0] tx_byte,

output received,
output [7:0] rx_byte, 

output reg [3:0] rx_samples,
output reg [3:0] rx_sample_countdown
           
);



    parameter baud_rate = 9600;
    parameter sys_clk_freq = 100000000;
   
    localparam one_baud_cnt = sys_clk_freq / (baud_rate);
    localparam [2:0]     
        RX_IDLE             = 3'd0, 
        RX_CHECK_START      = 3'd1, 
        RX_SAMPLE_BITS      = 3'd2,
        RX_READ_BITS        = 3'd3,      
        RX_CHECK_STOP       = 3'd4, 
        RX_DELAY_RESTART    = 3'd5,
        RX_ERROR            = 3'd6,      
        RX_RECEIVED         = 3'd7; 

    localparam [1:0]     
        TX_IDLE             = 2'd0,
        TX_SENDING          = 2'd1,
        TX_DELAY_RESTART    = 2'd2,
        TX_RECOVER          = 2'd3;


reg[3:0] rx_bits_remaining;
reg [7:0] rx_data;

reg[3:0] tx_bits_remaining;
reg [7:0] tx_data;

reg [2:0] recv_state;
reg [1:0] tx_state;

localparam max_clk_cnt = 16 * one_baud_cnt; 
localparam CLK_WIDTH = $clog2(max_clk_cnt+1);
reg [CLK_WIDTH-1:0] rx_clk;
reg [CLK_WIDTH-1:0] tx_clk;
reg tx_out = 1'b1;


assign tx=tx_out;
assign rx_byte = rx_data;
assign received = recv_state == RX_RECEIVED;


always @(posedge clk) begin
    if(rst) begin
        recv_state<=RX_IDLE;
        tx_state<=TX_IDLE;
        rx_clk<={CLK_WIDTH{1'b0}};
        tx_clk<={CLK_WIDTH{1'b0}};
        rx_samples          <= 4'd0;
            rx_sample_countdown <= 4'd0;
            rx_bits_remaining   <= 4'd0;
            tx_bits_remaining   <= 4'd0;
            rx_data             <= 8'd0;
            tx_data             <= 8'd0;
            tx_out              <= 1'b1;
    end

    if(rx_clk) begin
        rx_clk<=rx_clk-1'd1;
    end
    if(tx_clk) begin
        tx_clk<=tx_clk-1'd1;
    end


case(recv_state) 

RX_IDLE: begin
    if(!rx) begin
        recv_state<=RX_CHECK_START;
        rx_clk<=one_baud_cnt/2;
    end
end

RX_CHECK_START: begin
    if(!rx_clk) begin
        if(!rx) begin
            
            
            recv_state<=RX_SAMPLE_BITS;
            rx_samples<=0;
            rx_sample_countdown<=5;
            rx_bits_remaining<=8;
        end
        else begin
            recv_state<=RX_ERROR;
        end
    end
end


RX_SAMPLE_BITS: begin
    if(!rx_clk) begin
    
    if(rx) begin
        rx_samples<=rx_samples+1'd1;
    end
        rx_clk<=one_baud_cnt/8;
        rx_sample_countdown<=rx_sample_countdown-1'd1;
    
        recv_state<=rx_sample_countdown?RX_SAMPLE_BITS:RX_READ_BITS;

    end


end

RX_READ_BITS: begin
    
    if(!rx_clk) begin
if (rx_samples > 3) begin
                        rx_data <= {1'd1, rx_data[7:1]};
                    end else begin
                        rx_data <= {1'd0, rx_data[7:1]};
                    end

        rx_clk <= (one_baud_cnt * 3) / 8;
        rx_samples <= 0;
        rx_sample_countdown <= 5;
        rx_bits_remaining <= rx_bits_remaining - 1'd1;     

if(rx_bits_remaining)begin
                        recv_state <= RX_SAMPLE_BITS;
                    end else begin
                        recv_state <= RX_CHECK_STOP;
                        rx_clk <= one_baud_cnt / 2;
                    end

    end

end


RX_CHECK_STOP: begin

    if(!rx_clk) begin
        
recv_state <= rx ? RX_RECEIVED : RX_ERROR;

    end


end
            RX_ERROR: begin

                rx_clk <= 8 * sys_clk_freq / (baud_rate);
                recv_state <= RX_DELAY_RESTART;
            end

            RX_DELAY_RESTART: begin

                recv_state <= rx_clk ? RX_DELAY_RESTART : RX_IDLE;
            end
            
            
            RX_RECEIVED: begin

                recv_state <= RX_IDLE;
            end

endcase


case(tx_state) 

    TX_IDLE: begin
        
        if(transmit) begin
            
            tx_data<=tx_byte;
            tx_clk<=one_baud_cnt;
            tx_out<=0;
            tx_bits_remaining<=8;
            tx_state<=TX_SENDING;

        end

    end

    TX_SENDING:begin
        
if (!tx_clk) begin
                    if (tx_bits_remaining) begin
                        tx_bits_remaining <= tx_bits_remaining - 1'd1;
                        tx_out <= tx_data[0];
                        tx_data <= {1'b0, tx_data[7:1]};
                        tx_clk <= one_baud_cnt;
                        tx_state <= TX_SENDING;
                    end else begin
                        // Set delay to send out 2 stop bits.
                        tx_out <= 1;
                        tx_clk <= 16 * one_baud_cnt;// tx_countdown = 16;
                        tx_state <= TX_DELAY_RESTART;
                    end
                end

    end

            TX_DELAY_RESTART: begin

                tx_state <= tx_clk ? TX_DELAY_RESTART : TX_RECOVER;// TX_IDLE;
            end
            
            TX_RECOVER: begin
             
                tx_state <= transmit ? TX_RECOVER : TX_IDLE;
           
            end
endcase



end


endmodule


