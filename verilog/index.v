//taps = 16
//order =15

module filter (
    input wire clk,
    input wire rstn,
    input wire signed [7:0] sig,
    output wire signed [19:0] trunc_op
);
    
    //assume the sig is q1.7
// Declaration (16 elements, indexed 0 to 15)
wire signed [7:0] coeff [0:15];
reg signed [7:0] signal[0:15];
wire signed [15:0] res[0:15];

// Continuous assignments
assign coeff[0]  = 8'sd0;
assign coeff[1]  = 8'sd5;
assign coeff[2]  = 8'sd4;
assign coeff[3]  = -8'sd5;
assign coeff[4]  = -8'sd10;
assign coeff[5]  = 8'sd0;
assign coeff[6]  = 8'sd24;
assign coeff[7]  = 8'sd45;
assign coeff[8]  = 8'sd45;
assign coeff[9]  = 8'sd24;
assign coeff[10] = 8'sd0;
assign coeff[11] = -8'sd10;
assign coeff[12] = -8'sd5;
assign coeff[13] = 8'sd4;
assign coeff[14] = 8'sd5;
assign coeff[15] = 8'sd0;

integer i;
always @(posedge clk or negedge rstn) begin
    
    if(!rstn) begin
        for(i=0;i<16;i=i+1)begin
            signal[i]<=8'sd0;
        end
    end else begin
        for(i=15;i>0;i=i-1) begin
            signal[i]<=signal[i-1];
        end
        signal[0]<=sig;
    end

end


genvar k;
generate
    
for(k=0;k<16;k=k+1) begin: gen

    mul ml(

        .delsig(signal[k]),
        .coeff(coeff[k]),
        .res(res[k])

    );

end

endgenerate
wire signed [19:0] sum;

assign sum = res[0]  + res[1]  + res[2]  + res[3]  +
             res[4]  + res[5]  + res[6]  + res[7]  +
             res[8]  + res[9]  + res[10] + res[11] +
             res[12] + res[13] + res[14] + res[15];


assign trunc_op=sum;


endmodule

module mul(

    input signed [7:0] delsig,
    input signed [7:0] coeff,
    output signed [15:0] res

);

assign res=coeff*delsig;

endmodule