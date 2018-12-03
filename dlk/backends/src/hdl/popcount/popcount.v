`default_nettype none
/*
LATENCY: 0-2;
NOTE:enableを定義してあるが、定義しない方がregisterの節約になると思われる。
enableは、演算器全体を制御するわけではなく、そのクロックで入力されたデータの計算を許可する設計なので、validという方が近い。
これにより、正しい入力が来るまでは、前のデータが消されない効果がある。
多少if文が深いので、正しくgenerateされるか確証がない。
*/

module popcount32 #(parameter LATENCY = 0) (
    input  wire        clk  ,
    input  wire        rst_n,
    input  wire        en   ,
    input  wire [31:0] d    ,
    output wire [ 5:0] q
);

    wire [1:0] tmp1[15:0];
    genvar i1;
    generate
        for(i1 = 0; i1 < 16; i1 = i1 + 1)begin
            assign tmp1[i1] = {1'b0,d[i1*2]} + {1'b0,d[i1*2+1]};
        end
    endgenerate



    genvar i2;
    wire [2:0] tmp2[7:0];
    wire tmp_en;
    generate
        if( LATENCY > 1 )begin
            reg [23:0] tmp2_reg;
            reg tmp_en_reg = 0;
            for(i2 = 0; i2 < 8; i2 = i2 + 1)begin
                always @(posedge clk ) begin
                    if(en)
                        tmp2_reg[i2*3+2:i2*3] = {1'b0,tmp1[i2*2]} + {1'b0,tmp1[i2*2+1]};
                    tmp_en_reg <= en;
                end
                assign tmp2[i2] = tmp2_reg[i2*3+2:i2*3];
                assign tmp_en = tmp_en_reg;
            end

        end else begin
            assign tmp_en = en;
            for(i2 = 0; i2 < 8; i2 = i2 + 1)begin
                assign tmp2[i2] = {1'b0,tmp1[i2*2]} + {1'b0,tmp1[i2*2+1]};
            end
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

    generate
        if(LATENCY > 0)begin
            reg [5:0] out_reg = 0;
            always @(posedge clk ) begin
                if(tmp_en)
                    out_reg <= {1'b0,tmp4[0]} + {1'b0,tmp4[1]};
            end
            assign q = out_reg;
        end else  begin
            assign q = {1'b0,tmp4[0]} + {1'b0,tmp4[1]};
        end
    endgenerate


endmodule





/*
LATENCY: 0-3;
NOTE:enableを定義してあるが、定義しない方がregisterの節約になると思われる。
enableは、演算器全体を制御するわけではなく、そのクロックで入力されたデータの計算を許可する設計なので、validという方が近い。
これにより、正しい入力が来るまでは、前のデータが消されない効果がある。
多少if文が深いので、正しくgenerateされるか確証がない。
*/
module popcount64 #(parameter LATENCY = 0) (
    input  wire        clk  ,
    input  wire        rst_n,
    input  wire        en   ,
    input  wire [63:0] d    ,
    output wire [ 6:0] q
);


        localparam SUBLATENCY = (LATENCY <= 1)? 0:
            (LATENCY == 2)? 1:
            2;


        wire [5:0] tmp[1:0];
    popcount32 #(.LATENCY(SUBLATENCY)) u1 (
        .clk(clk     ),
        .en (en      ),
        .d  (d[63:32]),
        .q  (tmp[1]  )
    );

    popcount32 #(.LATENCY(SUBLATENCY)) u2 (
        .clk(clk    ),
        .en (en     ),
        .d  (d[31:0]),
        .q  (tmp[0] )
    );


        generate
            if(LATENCY==0)begin
                assign q = {1'b0,tmp[0]} + {1'b0,tmp[1]} ;
            end else begin
                wire en_wire;
                if(LATENCY == 1)begin
                    assign en_wire = en;
                end else if(LATENCY == 2) begin
                    reg shift_reg = 0;
                    always @(posedge clk) begin
                        if(~rst_n) begin
                            shift_reg <= 0;
                        end else begin
                            shift_reg <= en;
                        end
                    end
                    assign en_wire = shift_reg;
                end else begin
                    reg [1:0]shift_reg = 0;
                    always @(posedge clk) begin
                        if(~rst_n) begin
                            shift_reg <= 0;
                        end else begin
                            shift_reg <= {shift_reg,en};
                        end
                    end
                    assign en_wire = shift_reg[1];
                end
                reg [6:0] q_reg = 0;
                always @(posedge clk) begin
                    if(en_wire) begin
                        q_reg <=  {1'b0,tmp[0]} + {1'b0,tmp[1]} ;
                    end
                end
                assign q = q_reg;
            end
        endgenerate
    endmodule

        `default_nettype wire
