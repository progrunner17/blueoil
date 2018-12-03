

`default_nettype none

module unroll_oc #(
  parameter IN_DATA_WIDTH = 32,
  parameter OUT_DATA_WIDTH = 16,
  parameter IC_WIDTH = 5,
  parameter OC_UNROLL_WIDTH = 4, //N=16
  parameter TILE_SIZE_WIDTH = 5
) (
  input wire clk,
  input wire rst_n,
  input wire start,
  output wire done,
  input wire [IC_WIDTH-1:0] ic_last,
  input wire [TILE_SIZE_WIDTH-1:0] ih_low_start,
  input wire [TILE_SIZE_WIDTH-1:0] ih_low_last,
  input wire [TILE_SIZE_WIDTH-1:0] iw_low_start,
  input wire [TILE_SIZE_WIDTH-1:0] iw_low_last,
  input wire [1:0] kh,
  input wire [1:0] kw,

  output wire concurrent_check_valid,
  output wire [OUT_ADDR_WIDTH- 1:0] concurrent_check_addr,
  input wire [OUT_ADDR_WIDTH- 1:0] after_check_addr,
  output wire [OUT_DATA_WIDTH * OC_UNROLL_NUM -1:0] check_data
);

  localparam OC_UNROLL_NUM = 1<<OC_UNROLL_WIDTH;
  localparam TILE_SIZE = 2** TILE_SIZE_WIDTH;
  localparam STATE_IDLE = 0;
  localparam STATE_RUN = 1;
  localparam STATE_WAIT = 2;
  localparam STATE_DONE = 2;

  localparam WAIT_NUM = 3;//TODO:

  localparam IN_ADDR_WIDTH = TILE_SIZE_WIDTH * 2 + IC_WIDTH; //IB is distinguished according to memory bank
  localparam KN_ADDR_WIDTH = IC_WIDTH; // OC_LOW is distunguished according to memory bank
  localparam OUT_ADDR_WIDTH = TILE_SIZE_WIDTH * 2 ;


// parameter  IC_UNROLL_WIDTH = 1;
// localparam IC_UNROLL_NUM = 1<<OC_UNROLL_WIDTH;

  reg [IC_WIDTH-1:0] ic = 0;
  reg [TILE_SIZE_WIDTH-1:0] ih_low = 0;
  reg [TILE_SIZE_WIDTH-1:0] iw_low = 0;
  reg [1:0] ihw_low_ic_state = 0;

  reg [2:0] wait_cnt = 0;


  wire fin;
  assign fin = (ic==ic_last) && (ih_low == ih_low_last) && (iw_low == iw_low_last);

  always @(posedge clk ) begin
    case (ihw_low_ic_state)
      STATE_IDLE:if(start)ihw_low_ic_state <= STATE_RUN;
      STATE_RUN:if(fin)ihw_low_ic_state <= STATE_WAIT;
      STATE_WAIT:if(wait_cnt == WAIT_NUM )ihw_low_ic_state <= STATE_DONE;//TODO:
      // STATE_DONE:ihw_low_ic_state <= STATE_IDLE;
      default:ihw_low_ic_state <= STATE_IDLE;
    endcase
  end
  assign done = ihw_low_ic_state == STATE_DONE;

  always @(posedge clk ) begin
    if(ihw_low_ic_state == STATE_IDLE || ~rst_n)begin
      wait_cnt <= 0;
    end else if( ihw_low_ic_state == STATE_RUN && fin || ihw_low_ic_state == STATE_WAIT )begin
      wait_cnt <= wait_cnt + 1;
    end
  end

  always @(posedge clk ) begin
    if(!rst_n || ihw_low_ic_state == STATE_IDLE)begin
      ic <= 0;
      ih_low <= ih_low_start;
      iw_low <= iw_low_start;
    end else begin 
      if(ihw_low_ic_state == STATE_RUN)
        ic <= (ic== ic_last)? 0: ic + 1;

      if(ihw_low_ic_state == STATE_RUN && ic==ic_last)
        iw_low <= (iw_low==iw_low_last)? iw_low_start: iw_low + 1;
        
      if(ihw_low_ic_state == STATE_RUN && ic==ic_last && iw_low==iw_low_last)
        ih_low <= ih_low + 1;
    end
  end





  wire [IN_ADDR_WIDTH-1:0] in_buf_raddr; //TODO:parameter daclaration
  // assign in_buf_raddr = {ih_low, {IC_WIDTH + TILE_SIZE_WIDTH{1'b0}} } | {{TILE_SIZE_WIDTH{1'b0}},ih_low, {IC_WIDTH{1'b0}}} | {{(IC_WIDTH + TILE_SIZE_WIDTH){1'b0}},ic};
  assign in_buf_raddr = (ih_low << ( IC_WIDTH + TILE_SIZE_WIDTH)) | (iw_low << IC_WIDTH ) | ic;
  wire [IN_DATA_WIDTH-1:0] in_buf_rdata0;
  wire [IN_DATA_WIDTH-1:0] in_buf_rdata1;



// input buffer (unroll N = 1(InChUnroll))
// begin:gen_in_buf
  sdp_ram
    #(
      .DATA_WIDTH(IN_DATA_WIDTH),
      .ADDR_WIDTH(IN_ADDR_WIDTH),
      .IMPORT(1),
      .RAM_PREFIX("inbuf"),
      .RAM_IDX(0),
      .BEGIN_ADDR(0),//TODO:
      .END_ADDR(2**IN_ADDR_WIDTH-1)
    ) in_buf0(
      .clk(clk),
      .we(1'b0),
      .d(0),
      .raddr(in_buf_raddr),
      .waddr({IN_ADDR_WIDTH{1'b0}}),
      .q(in_buf_rdata0)
    );


  sdp_ram
    #(
      .DATA_WIDTH(IN_DATA_WIDTH),
      .ADDR_WIDTH(IN_ADDR_WIDTH),
      .IMPORT(1),
      .RAM_PREFIX("inbuf"),
      .RAM_IDX(1),
      .BEGIN_ADDR(0), //TODO:
      .END_ADDR(2**IN_ADDR_WIDTH-1 )
    ) in_buf1(
      .clk(clk),
      .we(1'b0),
      .d(0),
      .raddr(in_buf_raddr),
      .waddr({IN_ADDR_WIDTH{1'b0}}),
      .q(in_buf_rdata1)
    );

  wire [KN_ADDR_WIDTH-1:0] kn_buf_raddr ;
  assign kn_buf_raddr = ic;
  wire [IN_DATA_WIDTH-1:0] kn_buf_rdata [OC_UNROLL_NUM-1:0] ;


// kernel buffer (unroll N = 1(InChUnroll) x OC_UNROLL_NUM)
  genvar i;
  generate
    for(i = 0; i < OC_UNROLL_NUM; i = i + 1) begin : gen_kn_buf
      sdp_ram
        #(
          .DATA_WIDTH(IN_DATA_WIDTH),
          .ADDR_WIDTH(KN_ADDR_WIDTH),
          .IMPORT(1),
          .RAM_PREFIX("knbuf"),
          .RAM_IDX(i),
          .BEGIN_ADDR(0),//TODO:
          .END_ADDR(2**(IC_WIDTH) -1)
        )kn_buf(
          .clk(clk),
          .we(1'b0),
          .d(0),
          .raddr(kn_buf_raddr),
          .waddr({KN_ADDR_WIDTH{1'b0}}),
          .q(kn_buf_rdata[i])
        );
    end
  endgenerate


  wire [TILE_SIZE_WIDTH-1:0] oh_low ;
  assign oh_low = ih_low - kh;
  wire [TILE_SIZE_WIDTH-1:0] ow_low;
  assign ow_low = iw_low - kw;
  wire [OUT_ADDR_WIDTH-1:0] out_buf_waddr_wire;
  assign out_buf_waddr_wire = (oh_low * TILE_SIZE) | ow_low ;//TODO: oh_low,ow_low;
  
  reg [OUT_ADDR_WIDTH-1:0] out_buf_addr_shift_reg0=0;
  reg [OUT_ADDR_WIDTH-1:0] out_buf_addr_shift_reg1=0;
  reg [OUT_ADDR_WIDTH-1:0] out_buf_addr_shift_reg2=0;
  always @(posedge clk ) begin
    out_buf_addr_shift_reg2 <= out_buf_addr_shift_reg1;
    out_buf_addr_shift_reg1 <= out_buf_addr_shift_reg0;
    out_buf_addr_shift_reg0 <= out_buf_waddr_wire;
  end


  wire [OUT_ADDR_WIDTH-1:0] out_buf_raddr;
  assign out_buf_raddr = done ? after_check_addr : out_buf_addr_shift_reg1;//TODO:
  // assign out_buf_raddr =  out_buf_addr_shift_reg1;//TODO:
  wire [OUT_ADDR_WIDTH-1:0] out_buf_waddr;
  assign out_buf_waddr = out_buf_addr_shift_reg2;//TODO:


  wire [OUT_DATA_WIDTH-1:0] out_buf_rdata [0:OC_UNROLL_NUM];
  wire [OUT_DATA_WIDTH-1:0] out_buf_wdata [0:OC_UNROLL_NUM];
  wire                  out_buf_we [0:OC_UNROLL_NUM];


// output buffer (unroll N = OC_UNROLL_NUM)
  generate
    for(i = 0; i < OC_UNROLL_NUM; i = i + 1) begin : gen_out_buf
      sdp_ram
        #(
          .DATA_WIDTH(OUT_DATA_WIDTH),
          .ADDR_WIDTH(OUT_ADDR_WIDTH),
          .RAM_PREFIX("outbuf"),
          .RAM_IDX(i)
          // .BEGIN_ADDR(2**ADDR_WIDTH), // initialize to 0
          // .END_ADDR(2**ADDR_WIDTH)

        )out_buf(
          .clk(clk),
          .we(out_buf_we[i]),
          .d(out_buf_wdata[i]),
          .raddr(out_buf_raddr),
          .waddr(out_buf_waddr),
          .q(out_buf_rdata[i])
        );

    end
  endgenerate



  wire [OUT_DATA_WIDTH-1:0] calculated_data [0:OC_UNROLL_NUM];
  wire  [0:OC_UNROLL_NUM] data_valid ;

// calculation unit
  generate
    for (i = 0; i < OC_UNROLL_NUM; i = i + 1 ) begin: gen_calc_unit
      reg en = 0;
      reg we = 0;
      reg reset = 0;
      always @(posedge clk) begin
          en <= ihw_low_ic_state == STATE_RUN;
          we <= ic==ic_last;
          reset <= ic==0;
      end

      calc_unit_parallel #(
        .WORD_WIDTH(IN_DATA_WIDTH),
        .OUT_WIDTH(OUT_DATA_WIDTH)
      ) u_calc_unit_parallel(
        .clk(clk),
        .rst_n(rst_n),
        .en(en),
        .we(we),
        .reset(reset),
        .in_buf_rdata0(in_buf_rdata0),
        .in_buf_rdata1(in_buf_rdata1),
        .kn_buf_rdata(kn_buf_rdata[i]),
        .data(calculated_data[i]),
        .data_valid(data_valid[i])
      );
    end
  endgenerate

  generate
    for(i = 0 ; i < OC_UNROLL_NUM; i = i + 1) begin : wirte_out
      wire [OUT_DATA_WIDTH-1:0] out_buf_basedata;
      assign out_buf_basedata = (kh==0 && kw==0 )? 0: out_buf_rdata[i];
      assign out_buf_we[i]    = data_valid[i];
      assign out_buf_wdata[i] = calculated_data[i] + out_buf_basedata;
    end
  endgenerate


  generate
    for(i = 0 ; i < OC_UNROLL_NUM; i = i + 1) begin
      assign check_data[(i+1)*OUT_DATA_WIDTH-1:i*OUT_DATA_WIDTH] = done ? out_buf_rdata[i] : calculated_data[i];
    end
  endgenerate
  assign concurrent_check_valid = data_valid[0];
  assign concurrent_check_addr = out_buf_waddr;



endmodule // unroll_oc

`default_nettype wire