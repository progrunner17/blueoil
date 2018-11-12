`dfault_nettype none

module qconv_kn2row_tiling(
input wire clk,
input wire rstn,

/*
input wire start,
output wire wait,
*/

// TODO:consider the data bus
// in_data
// out_data
// k_data

// TODO: consider the wire width
input wire [31:0] in_w,
input wire [31:0] in_h,
input wire [31:0] in_c,
input wire [31:0] out_w,
input wire [31:0] out_h,
input wire [31:0] out_c,
input wire [31:0] k_w,
input wire [31:0] k_h,
input wire [31:0] pad,
input wire [31:0] stride
);


// Global TODOs

// TODO: check the declaration position
// wires and regs should be declared before reference;

// TODO:consider substitute registers for wires of loop conditions in order to migitgate the propagation delay.




// FIXME: parameter
parameter OutChLowWidth  = 4;
parameter OutChHighWidth = 32 - OutChLowWidth;
parameter OutChUnroll = 1 << (OutChLowWidth-1);
parameter InChHighWidth = ;






// TODO: output channel high controller.
reg out_c;
TODO:OutCh loop condition
wire out_c_incr_enable =    ih_high's condition    \
                        &&  iw_high's condition    \
                        &&  low_state's condition;

always @(posedge clk) begin
    if(!rstn)begin
        oc_high <= 0;
    end 
    else if(out_c_incr_enable)begin
        oc_high <= oc_high + 1;
    end
end
//output channel high controller.

// TODO: input channel high width and height controller. 

reg [InChHighWidth - 1:0] ih_high = 0;
// TODO:input channel high height's loop condition
wire ih_high_incr_enable            =   iw_high's condition   \
                                    &&  inside_state's condition  ;
always @(posedge clk) begin
    if(!rstn)begin
        ih_high <= 0; 
    end
    else if(ih_high_incr_enable) begin
        ih_high <= ih_high + 1;
    end 
  
end // ih_high 


reg [InChHighWidth - 1:0] iw_high = 0;
// TODO:input channel hight width's loop condition
wire iw_high_incr_enable            = inside_state's condition;
always @(posedge clk) begin
    if(!rstn)begin
        iw_high <= 0;
    end
    else if(iw_high_incr_enable) begin
        iw_high <= 0;
    end 
end // iw_high
// input channel width and height high controller. 


















// TODO: low state controller.
// for ease, 

// TODO:consider these state
localparam STATE_IDLE=3'd0;
localparam STATE_READ_INPUT =3'd1;
localparam STATE_READ_KERNEL =3'd2;
localparam STATE_CALC_MAC =3'd3;
localparam STATE_WRITE_OUTPUT =3'd4;
// localparam STATE_OutCh_NEXT =3'd5;
reg [2:0] inside_state = IDLE;

always @(posedge clk ) begin
    if (!rstn) begin
        inside_state <= STATE_IDLE;
    end
    else begin
    // TODO: is it better to assign each state directly instead of increment the state register; 
    case (inside_state)
    STATE_IDLE: if(FIXME:each state update condition) inside_state <= inside_state + 1;
    STATE_READ_INPUT : if(FIXME:each state update condition) inside_state <= inside_state + 1;
    STATE_READ_KERNEL : if(FIXME:each state update condition) inside_state <= inside_state + 1;
    STATE_CALC_MAC : if(FIXME:each state update condition) inside_state <= inside_state + 1;
    STATE_WRITE_OUTPUT : if(FIXME:each state update condition) inside_state <= inside_state + 1;
      default: 
    endcase

    end
end
// low state controller.



// TODO: 全体で1つのalwaysにすべき？


// TODO: IDLE

// TODO: set the condtion
wire end_of_idle = ;

// IDLE


// TODO: READ_INPUT 

// TODO: set the condtion
wire end_of_read_input = ;


// TODO: メモリバンクを分ける？
genvar mem_i;
localparam MemBankNum = 8;
generate 

for ( mem_i < MemBankNum ) begin


end
endgenerate


// TODO: set the data to RAMs
always @(posedge clk ) begin
    if (!rstn) begin

    end
    else if(FIXME:   ) begin
    
    end
end
//READ_INPUT




// TODO: READ_KERNEL

// TODO: set the condtion
wire end_of_read_kernel = ;



always @(posedge clk ) begin
    if (!rstn) begin

    end
    else if(  ) begin
    
    end
end

// READ_KERNEL


// TODO: CALC_MAC 

// TODO: set the condtion
wire end_of_calc_mac = ;





// TODO: 計算するwindowの位置の管理

// TODO: 計算するbitの管理

// TODO: 計算する入力チャンネルの管理 //unroll(generate for)




// CALC_MAC 



// TODO: WRITE_OUTPUT 
// TODO: consider whether handling the thresholds

// TODO: set the condtion
wire end_of_write_output = ;



always @(posedge clk ) begin
    if (!rstn) begin

    end
    else if(  ) begin
    
    end
end

// WRITE_OUTPUT 



endmodule //qconv_kn2row_tiling

`dfault_nettype wire



// FIXME: ERASE
