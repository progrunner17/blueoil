//~ `New testbench
`timescale  1ns / 1ps

module tb_popcount64;

// popcount64 Parameters
parameter PERIOD  = 10;


// popcount64 Inputs
reg   [63:0]  in                           = 0 ;

// popcount64 Outputs
wire  [6:0]  out                           ;

logic [6:0] tmp;

logic clk = 0;
logic rst_n = 0;
logic [63:0] seed;
initial
begin 
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

popcount64  u_popcount64 (
    .in                      ( in   [63:0] ),

    .out                     ( out  [6:0]  )
);

logic [31:0] i = 0;
initial
begin
    in = 0;
    #PERIOD
    $display (out );
    #PERIOD
    in = 1;
    #PERIOD
    $display (out == 1);
    #PERIOD
    in = 2;
    #PERIOD
    $display (out == 1);
    #PERIOD
    in = 3;
    #PERIOD
    $display (out);
    #PERIOD;
    seed = $time();
    $display(seed);
    repeat(10) begin
    in = {$urandom(seed),$urandom(seed)};
    tmp = 0;
    #PERIOD;
    
    for(i = 0; i < 64 ; i = i+1)begin 
        if (in[i]) tmp = tmp+1;
    end
    $write("in = %X\n",in );
    $write("out = %d\n",out );
    $write("tmp = %d\n",tmp );
    $write("%s\n",out==tmp ? "OK" : "NG");
    // $display ();
    #PERIOD;
    end
    


    $finish;
end
initial
begin
$dumpfile("tb_popcount.vcd");
$dumpvars(0, tb_popcount64);
end

endmodule
