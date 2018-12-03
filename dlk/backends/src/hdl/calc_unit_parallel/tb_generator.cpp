#include <iostream>
#include <cstdint>
#include <cstdio>
#include <random>
using namespace std;


int main(int argc, char const *argv[])
{
    uint32_t bit0,bit1,kernel;
    int xnor0,xnor1,notw,answer;
    int n = 1;
    if(argc > 1){
        n = atoi(argv[1]);
    } 
    srand(time(NULL));




char const *str = R"(

`default_nettype none
`timescale  1ns / 1ps

module tb_calc_unit_parallel;

// calc_unit_parallel Parameters
parameter PERIOD      = 10;
parameter WORD_WIDTH  = 32;
parameter OUT_WIDTH   = 32;

// calc_unit_parallel Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 1'b0 ;
reg   en                                   = 0 ;
reg   we                                   = 0 ;
reg   reset                                = 0 ;
reg   [WORD_WIDTH-1:0]  in_buf_rdata0      = 0 ;
reg   [WORD_WIDTH-1:0]  in_buf_rdata1      = 0 ;
reg   [WORD_WIDTH-1:0]  kn_buf_rdata       = 0 ;

// calc_unit_parallel Outputs
wire  [OUT_WIDTH-1:0]  data                ;
reg  [OUT_WIDTH-1:0]  answer                ;
wire  data_valid                            ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2);
    rst_n  =  1'b1;
end

calc_unit_parallel #(
    .WORD_WIDTH ( WORD_WIDTH ),
    .OUT_WIDTH  ( OUT_WIDTH  ))
 u_calc_unit_parallel (
    .clk                     ( clk                             ),
    .rst_n                   ( rst_n                           ),
    .en                      ( en                              ),
    .we                      ( 1'b1                            ),
    .reset                   (1'b1                             ),
    .in_buf_rdata0           ( in_buf_rdata0  [WORD_WIDTH-1:0] ),
    .in_buf_rdata1           ( in_buf_rdata1  [WORD_WIDTH-1:0] ),
    .kn_buf_rdata            ( kn_buf_rdata   [WORD_WIDTH-1:0] ),
    .data                    ( data           [OUT_WIDTH-1:0]  ),
    .data_valid              ( data_valid                      )
);

initial
begin
#30;
)";

cout << str << endl;
 

    for(int i = 0; i<n;i++){
        *((int *)&bit0) = rand();
        *((int *)&bit1) = rand();
        *((int *)&kernel) = rand();

        
        xnor0 = __builtin_popcountll(~(kernel ^ bit0));
        xnor1 = __builtin_popcountll(~(kernel ^ bit1));
        notw = __builtin_popcountll(~kernel);
        
        answer =  xnor1*2 + xnor0 - notw*3;
    cout << "@(posedge clk);" << endl;  
        cout << "#1;" << endl;
        cout << "in_buf_rdata0 = 32'd" << bit0 << ";" << endl; 
        cout << "in_buf_rdata1 = 32'd" << bit1 << ";" << endl; 
        cout << "kn_buf_rdata = 32'd"  << kernel << ";" << endl; 
        cout << "answer = 32'h" ;
        printf("%X;\n", ((unsigned int )answer) ); 
        cout << "en = 1;" << endl; 
        cout << "@(posedge clk);" << endl;
        cout << "#1;" << endl;
        cout << "en = 0;" << endl;
        cout << "repeat(2)@(posedge clk);" << endl;
        cout << "#1;" << endl;
        cout << "$write(\"%s:  %d:%d\\n\",((data==answer)? \"OK\" : \"NG\") , $signed(data) , $signed(answer));" << endl;
    }


char const *post_str = R"(

#10;
$finish;
end
initial
begin
    $dumpfile("calc_unit_parallel.vcd");
    $dumpvars(0, tb_calc_unit_parallel);
end
endmodule

`default_nettype wire
)";

cout << post_str << endl;


    return 0;
}
