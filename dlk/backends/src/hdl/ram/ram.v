
/*
sp_ram 
#(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(6),
	.RAM_FILE("ram.txt"),
	.BEGIN_ADDR(0),
	.END_ADDR(2**DATA_WIDTH-1)
)
u_sp_ram(
	.clk(clk),
    .we,(we),
	.d(d),
	.aaddr(addr),
	.q(q)
);
*
*
*/

// module  sp_ram //simple_port_ram_dual_clock
// #(
//     parameter DATA_WIDTH=32,
//     parameter ADDR_WIDTH=6,
// 	parameter RAM_FILE="ram.txt",
// 	parameter BEGIN_ADDR=0,
// 	parameter END_ADDR=2**ADDR_WIDTH-1
// )
// (
// 	input wire clk,
//     input wire we, 
// 	input wire [(DATA_WIDTH-1):0] d,
// 	input wire [(ADDR_WIDTH-1):0] addr,
// 	output reg [(DATA_WIDTH-1):0] q='h0
// );
// 	// Declare the RAM variable
// 	reg [DATA_WIDTH-1:0] ram_body[2**ADDR_WIDTH-1:0];
//     integer i;
//     initial begin 
// 		$readmemh(RAM_FILE, ram_body,BEGIN_ADDR,END_ADDR); 
// 		for (i = 0; (i < BEGIN_ADDR) && (i < 2**ADDR_WIDTH) ;i=i+1)ram_body[i] = 0;
// 		for (i = END_ADDR + 1;i < 2**ADDR_WIDTH;i=i+1)ram_body[i] = 0;
//     end 
    
// 	always @ (posedge clk) begin
//         if (we) ram_body[addr] <= d;
//         q <= ram_body[addr];
//     end
// endmodule



/*
*
sdp_ram 
#(
    .DATA_WIDTH(32),
    .ADDR_WIDTH(6),
	.RAM_FILE("ram.txt")
)
u_sdp_ram(
	.clk(clk),
    .we,(we),
	.d(d),
	.raddr(raddr),
	.waddr(waddr),
	.q(q)
);
*
*
*/
module  sdp_ram //simple dual-port ram
#(
    parameter DATA_WIDTH=32,
    parameter ADDR_WIDTH=6,
	

    OUT_NEW_DATA=0, 			// dfault: old data is outputed when(waddr == raddr)

	parameter IMPORT = 0,		// default: initialize to zero.
	parameter RAM_PREFIX="ram",
	parameter RAM_POSTFIX="txt",
	parameter RAM_IDX=99,		// default: index is ignored 
	parameter BEGIN_ADDR=0,		
	parameter END_ADDR=2**ADDR_WIDTH-1
	

)
(
	input wire clk,
    input wire we, 
	input wire [(DATA_WIDTH-1):0] d,
	input wire [(ADDR_WIDTH-1):0] raddr,
	input wire [(ADDR_WIDTH-1):0] waddr,
	output reg [(DATA_WIDTH-1):0] q='h0
);
	parameter RAM_FILE= (RAM_IDX == 0 ) ? {RAM_PREFIX, "00" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 1 ) ? {RAM_PREFIX, "01" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 2 ) ? {RAM_PREFIX, "02" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 3 ) ? {RAM_PREFIX, "03" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 4 ) ? {RAM_PREFIX, "04" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 5 ) ? {RAM_PREFIX, "05" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 6 ) ? {RAM_PREFIX, "06" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 7 ) ? {RAM_PREFIX, "07" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 8 ) ? {RAM_PREFIX, "08" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 9 ) ? {RAM_PREFIX, "09" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 10 ) ? {RAM_PREFIX, "10" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 11 ) ? {RAM_PREFIX, "11" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 12 ) ? {RAM_PREFIX, "12" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 13 ) ? {RAM_PREFIX, "13" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 14 ) ? {RAM_PREFIX, "14" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 15 ) ? {RAM_PREFIX, "15" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 16 ) ? {RAM_PREFIX, "16" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 17 ) ? {RAM_PREFIX, "17" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 18 ) ? {RAM_PREFIX, "18" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 19 ) ? {RAM_PREFIX, "19" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 20 ) ? {RAM_PREFIX, "20" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 21 ) ? {RAM_PREFIX, "21" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 22 ) ? {RAM_PREFIX, "22" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 23 ) ? {RAM_PREFIX, "23" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 24 ) ? {RAM_PREFIX, "24" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 25 ) ? {RAM_PREFIX, "25" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 26 ) ? {RAM_PREFIX, "26" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 27 ) ? {RAM_PREFIX, "27" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 28 ) ? {RAM_PREFIX, "28" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 29 ) ? {RAM_PREFIX, "29" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 30 ) ? {RAM_PREFIX, "30" , "." ,RAM_POSTFIX } : 
						(RAM_IDX == 31 ) ? {RAM_PREFIX, "31" , "." ,RAM_POSTFIX } :
						{RAM_PREFIX,".",RAM_POSTFIX} ;
                        
	reg [DATA_WIDTH-1:0] ram_body[2**ADDR_WIDTH-1:0];
    
	integer i;
    initial begin 
		if(IMPORT!=0)begin 
			$readmemh(RAM_FILE, ram_body,BEGIN_ADDR,$unsigned(END_ADDR)); 
			for (i = 0; (i < BEGIN_ADDR) && (i < 2**ADDR_WIDTH) ;i=i+1)ram_body[i] = 0;
			for (i = END_ADDR + 1;i < 2**ADDR_WIDTH;i=i+1)ram_body[i] = 0;
		end else begin 
			for (i = 0; i < 2**ADDR_WIDTH ;i=i+1)ram_body[i] = 0;
		end
    end

    generate
    if(OUT_NEW_DATA != 0)begin //output old data 
		always @ (posedge clk) begin
	        if (we)
	            ram_body[waddr] = d; 
	        q <= ram_body[raddr];
	    end
	end else //output old data
	begin
		always @ (posedge clk) begin
	        if (we)
	            ram_body[waddr] <= d; 
	        q <= ram_body[raddr];
	    end	
	end	
    endgenerate




endmodule
