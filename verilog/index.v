//taps = 16
//order =15

module filter (
    input clk,
    input rst_n,
    input signed [7:0] sig,
    output reg signed [19:0] res
);

wire signed [7:0] coe [0:15];
reg signed [7:0] signal [0:15];
wire signed [15:0] answer [0:15];
integer k;

always @(posedge clk or negedge rst_n) begin

    if(!rst_n) begin
      for (k = 0; k < 16; k = k + 1) begin
                signal[k] <= 8'sd0;
            end
    end else begin

        signal[0] <= sig;
            for (k = 1; k < 16; k = k + 1) begin
                signal[k] <= signal[k-1];
            end

    end

end




genvar i;

generate

    for (i =0;i<16;i=i+1) begin: filtertap

        tapandadd ta(
            .coeff(coe[i]),
            .delsig(signal[i]),
            .answer(answer[i])
        );

    end

endgenerate



reg signed [19:0] sum;
integer j;
always @(*) begin
  
    sum=20'sd0;
    for(j=0;j<16;j=j+1) begin
      
        sum=sum+answer[j];

    end
end 

always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            res <= 20'sd0;
        else
            res <= sum;
    end

endmodule


module tapandadd (
    input [7:0] coeff,
    input [7:0] delsig,
    output [15:0] answer
);

assign answer=coeff*delsig;
    
endmodule


