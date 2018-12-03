`default_nettype none

/*
calc_unit_parallel #(
    .WORD_WIDTH(32),
    .OUT_WIDTH(32)
) u_calc_unit_parallel(
    .clk(clk),
    .en(en),
    .in_buf_rdata0(in_buf_rdata0),
    .in_buf_rdata1(in_buf_rdata1),
    .kn_buf_rdata(kn_buf_rdata),
    .data(data),
    .data_valid(data_valid)
);
*/

module calc_unit_parallel #(
    parameter WORD_WIDTH = 32,
    parameter OUT_WIDTH = 32,
    parameter oc_low = 0
)(
    input wire clk,
    input wire rst_n,   // disable data write to out_buf
    input wire en,      // enable alter the data register (ic is valid). this is necessary for unrolling input channel. 
    input wire we,      // enable data write to out_buf (ic==last)
    input wire reset,   // reset the data register  (ic == 0)
    input wire [WORD_WIDTH-1:0] in_buf_rdata0,
    input wire [WORD_WIDTH-1:0] in_buf_rdata1,
    input wire [WORD_WIDTH-1:0] kn_buf_rdata,
    output reg [OUT_WIDTH-1:0] data = 0,
    output reg data_valid = 0
);

// stage1 
wire    [5:0] in_xnor_kn_popcnt_wire0;
wire    [5:0] in_xnor_kn_popcnt_wire1;
wire    [5:0] neg_kn_popcnt_wire;
reg    [5:0] in_xnor_kn_popcnt0 = 0;
reg    [5:0] in_xnor_kn_popcnt1 = 0;
reg    [5:0] neg_kn_popcnt = 0;

// TODO: 現状組合わせ回路(0レイテンシ)だが、１つレジスタを挟む事も考える。
popcount32  u0(~(in_buf_rdata0 ^ kn_buf_rdata) , in_xnor_kn_popcnt_wire0);
popcount32  u1(~(in_buf_rdata1 ^ kn_buf_rdata) , in_xnor_kn_popcnt_wire1);
popcount32  u2(~                 kn_buf_rdata  , neg_kn_popcnt_wire);

reg tmp_we = 0;
reg tmp_en = 0;
reg tmp_reset = 1;
always @(posedge clk ) begin
    if(en)begin
    in_xnor_kn_popcnt0 <= in_xnor_kn_popcnt_wire0;
    in_xnor_kn_popcnt1 <= in_xnor_kn_popcnt_wire1;
    neg_kn_popcnt <= neg_kn_popcnt_wire;
    end
end

reg pre_we = 0;
reg pre_en = 0;
reg pre_reset = 1;



// setting addr
always @(posedge clk ) begin
  pre_we <= we;
  pre_en <= en;
  pre_reset <= reset;
end


// calculating popcount
always @(posedge clk ) begin
  tmp_we <= pre_we;
  tmp_en <= pre_en;
  tmp_reset <= pre_reset;
end

wire [OUT_WIDTH-1:0] diff = $signed(in_xnor_kn_popcnt0) + $signed(in_xnor_kn_popcnt1)*2 - neg_kn_popcnt * 3;
wire [OUT_WIDTH-1:0] data_wire;
assign data_wire = $signed(in_xnor_kn_popcnt0) + $signed(in_xnor_kn_popcnt1)*2 - neg_kn_popcnt * 3 + (tmp_reset ? 0: data);

always @(posedge clk ) begin
    if(tmp_en)begin
    data <= data_wire;
    end
end

always @(posedge clk ) begin
    if(tmp_reset || ~rst_n)
        data_valid <= 1'b0;
    else if(tmp_we) 
        data_valid <= 1'b1;
end



endmodule // calc_unit

`default_nettype wire
