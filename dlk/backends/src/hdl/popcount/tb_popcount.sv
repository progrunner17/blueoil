//~ `New testbench
`timescale  1ns / 1ps

module tb_popcount64;

// popcount64 Parameters
parameter PERIOD  = 10;


// popcount64 Inputs
reg   [63:0]  d                           = 0 ;

// popcount64 Outputs
wire  [6:0]  q                           ;
wire  [6:0]  q1                           ;
wire  [6:0]  q2                           ;
wire  [6:0]  q3                           ;

logic [6:0] answer;

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

popcount64 #(
    .LATENCY(0)
    ) u_popcount64 (
    .clk                    ( clk       ),
    .en                     ( 1'b1      ),
    .d                      ( d  [63:0] ),
    .q                      ( q  [6:0]  )
);




popcount64 #(
    .LATENCY(1)
    ) u_popcount64_1 (
    .clk                    ( clk       ),
    .en                     ( 1'b1      ),
    .d                      ( d  [63:0] ),
    .q                      ( q1  [6:0]  )
);


popcount64 #(
    .LATENCY(2)
    ) u_popcount64_2 (
    .clk                    ( clk       ),
    .en                     ( 1'b1      ),
    .d                      ( d  [63:0] ),
    .q                      ( q2  [6:0]  )
);



popcount64 #(
    .LATENCY(3)
    ) u_popcount64_3 (
    .clk                    ( clk       ),
    .en                     ( 1'b1      ),
    .d                      ( d  [63:0] ),
    .q                      ( q3  [6:0]  )
);


logic [31:0] i = 0;
integer fd = 0;
initial
begin
fd = $fopen("/dev/random","r");

    seed = $fgetc(fd);
    repeat(10) begin
    d = {$urandom(seed),$urandom(seed)};
    answer = 0;
    #(PERIOD*2);
    
    for(i = 0; i < 64 ; i = i+1)begin 
        if (d[i]) answer = answer+1;
    end
    $write("%s: ",q==answer ? "OK" : "NG");
    $write("d=%X ",d );
    $write("q=%d ",q );
    $write("answer=%d\n",answer );
    
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
