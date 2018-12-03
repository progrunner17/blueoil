
`timescale 1ns/1ps

module tb_unroll_oc (); /* this is automatically generated */

	logic rstb;
	logic srst;
	logic clk;

	// clock
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	// reset
	initial begin
		rstb = 0;
		srst = 0;
		#20
		rstb = 1;
		repeat (5) @(posedge clk);
		srst = 1;
		repeat (1) @(posedge clk);
		srst = 0;
	end

	// (*NOTE*) replace reset, clock, others

	parameter IN_DATA_WIDTH   = 32;
	parameter OUT_DATA_WIDTH  = 16;
	parameter IC_WIDTH        = 5;
	parameter OC_UNROLL_WIDTH = 4;
	parameter TILE_SIZE_WIDTH = 5;
	localparam OC_UNROLL_NUM  = 1<<OC_UNROLL_WIDTH;
	localparam TILE_SIZE      = 2** TILE_SIZE_WIDTH;
	localparam STATE_IDLE     = 0;
	localparam STATE_RUN      = 1;
	localparam STATE_WAIT     = 2;
	localparam STATE_DONE     = 2;
	localparam WAIT_NUM       = 3;
	localparam IN_ADDR_WIDTH  = TILE_SIZE_WIDTH * 2 + IC_WIDTH;
	localparam KN_ADDR_WIDTH  = 2 * 2 * IC_WIDTH;
	localparam OUT_ADDR_WIDTH = TILE_SIZE_WIDTH * 2;
	localparam IC_NUM = 4;

	logic                                       rst_n = 0;
	logic                                       start = 0;
	logic                                       done;
	logic                        [IC_WIDTH-1:0] ic_last = IC_NUM-1;
	logic                 [TILE_SIZE_WIDTH-1:0] ih_low_start = 0;
	logic                 [TILE_SIZE_WIDTH-1:0] ih_low_last = 29;
	logic                 [TILE_SIZE_WIDTH-1:0] iw_low_start = 0;
	logic                 [TILE_SIZE_WIDTH-1:0] iw_low_last = 29;
	logic                                 [1:0] kh = 0;
	logic                                 [1:0] kw = 0;
	
	
	logic                 [OUT_ADDR_WIDTH- 1:0] tb_check_buf_raddr;
	logic                 [OUT_ADDR_WIDTH- 1:0] after_check_addr = 0,concurrent_check_addr;
	logic [OUT_DATA_WIDTH * OC_UNROLL_NUM -1:0] check_data,check_data_buf = 0 ,answer;
	logic error ;
	logic check =0;
	logic after_checking = 0;
	logic error_occured = 0;
	
	assign error = (check  &&  answer != check_data_buf )|| (after_checking && answer != check_data);
	always @(posedge clk ) begin
	  	check <= concurrent_check_valid;
		check_data_buf <= check_data;
	end
	always @(posedge clk ) begin : proc_
		if(error) begin
			 error_occured <= 1'b1;
		end 
	end
	

	unroll_oc #(
			.IN_DATA_WIDTH(IN_DATA_WIDTH),
			.OUT_DATA_WIDTH(OUT_DATA_WIDTH),
			.IC_WIDTH(IC_WIDTH),
			.OC_UNROLL_WIDTH(OC_UNROLL_WIDTH),
			.TILE_SIZE_WIDTH(TILE_SIZE_WIDTH)
		) inst_unroll_oc (
			.clk                (clk),
			.rst_n              (rst_n),
			.start              (start),
			.done               (done),
			.ic_last            (ic_last),
			.ih_low_start       (ih_low_start),
			.ih_low_last        (ih_low_last),
			.iw_low_start       (iw_low_start),
			.iw_low_last        (iw_low_last),
			.kh                 (kh),
			.kw                 (kw),
			.concurrent_check_valid (concurrent_check_valid),
			.concurrent_check_addr   (concurrent_check_addr),
			.check_data       (check_data),
			.after_check_addr (after_check_addr)
		);


      sdp_ram
        #(
          .DATA_WIDTH(OUT_DATA_WIDTH * OC_UNROLL_NUM),
          .ADDR_WIDTH(TILE_SIZE_WIDTH * 2),
		  .IMPORT(1),
          .RAM_PREFIX("out_check"),
          .BEGIN_ADDR(0), // initialize to 0
          .END_ADDR(TILE_SIZE * TILE_SIZE - 1)

        )out_check_ram(
          .clk(clk),
          .we(1'b0),
          .d(256'h0),
          .raddr(done ? after_check_addr : concurrent_check_addr),
          .waddr(10'h0),
          .q(answer)
        );


	initial begin
		// do something

		repeat(4)@(posedge clk);
		rst_n = 1;
		@(posedge clk);
		start = 1;
		@(posedge clk);
		start = 0;
		repeat((TILE_SIZE-2)**2*IC_NUM + 10  )@(posedge clk);
		after_checking = 1;
		repeat(TILE_SIZE*TILE_SIZE)@(posedge clk)after_check_addr <= after_check_addr + done;
		repeat(10)@(posedge clk);

		$write("%s\n",error_occured ? "ERROR" : "SUCCESSFULLY FINISHED!!");
		$finish;
	end

	// dump wave
	initial begin
    $dumpfile("unroll_oc.vcd");
    $dumpvars(0, tb_unroll_oc);
	end

endmodule
