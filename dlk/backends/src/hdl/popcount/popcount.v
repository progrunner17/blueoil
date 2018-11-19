`default_nettype none

// TODO:consider inseerting FFs.



// TODO:    check if it is possible to synthesize multi-level for in generate block.
//          if possible convert to utilize it.

module popcount32(
    input wire [31:0] in,
    output wire [5:0] out
);

wire [1:0] tmp1[15:0];

genvar i1;
generate 
for(i1 = 0; i1 < 16; i1 = i1 + 1)begin
assign tmp1[i1] = {1'b0,in[i1*2]} + {1'b0,in[i1*2+1]};
end
endgenerate


wire [2:0] tmp2[7:0];
genvar i2;
generate 
for(i2 = 0; i2 < 8; i2 = i2 + 1)begin
assign tmp2[i2] = {1'b0,tmp1[i2*2]} + {1'b0,tmp1[i2*2+1]};
end
endgenerate

wire [3:0] tmp3[3:0];
genvar i3;
generate 
for(i3 = 0; i3 < 4; i3 = i3 + 1)begin
assign tmp3[i3] = {1'b0,tmp2[i3*2]} + {1'b0,tmp2[i3*2+1]};
end
endgenerate

wire [4:0] tmp4[1:0];
genvar i4;
generate 
for(i4 = 0; i4 < 2; i4 = i4 + 1)begin
assign tmp4[i4] = {1'b0,tmp3[i4*2]} + {1'b0,tmp3[i4*2+1]};
end
endgenerate


assign out = {1'b0,tmp4[0]} + {1'b0,tmp4[1]};


endmodule



module popcount64(
    input wire [63:0] in,
    output wire [6:0] out
);

wire [5:0]  tmp [1:0];
popcount32 u1(.in(in[63:32]),.out(tmp[1]));
popcount32 u2(.in(in[31:0]),.out(tmp[0]));
assign out = {1'b0,tmp[0]} + {1'b0,tmp[1]};
endmodule

`default_nettype wire