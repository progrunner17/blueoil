//~ `New testbench
`timescale  1ns / 1ps

module tb_qconv_states;

// qconv_states Parameters
parameter PERIOD          = 10;
parameter OcHighBitWidth  = 4;
parameter OcHighNum       = 3;

// qconv_states Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   start                                = 0 ;

// qconv_states Outputs
wire  finish                               ;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

qconv_states #(
    .OcHighBitWidth ( OcHighBitWidth ),
    .OcHighNum      ( OcHighNum      ))
 u_qconv_states (
    .clk                     ( clk                   ),
    .rst_n                   ( rst_n                 ),
    .start                   ( start                 ),

    .finish                  ( finish                )
);

initial
begin
    repeat(8) @(posedge clk);
    start = 1;
    @(posedge clk);

    #1;
    start = 0;
    repeat(10000) @(posedge clk);    
    $finish;

    $finish;
end

initial
begin
    $dumpfile("qconv_states.vcd");
    $dumpvars(0, tb_qconv_states);
end

endmodule
