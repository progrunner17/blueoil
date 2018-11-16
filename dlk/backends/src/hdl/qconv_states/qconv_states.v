`default_nettype none


module qconv_states (
    input wire clk,
    input wire rst_n,
    input wire start,
    output reg finish = 1
);


// OcHigh
    parameter OcHighBitWidth = 4;
    parameter OcHighNum = 4;
    localparam OcHigh_STATE_IDLE = 0;
    localparam OcHigh_STATE_TRIGGER_IHW_HIGH_AND_THRESHOLDS = 1;
    localparam OcHigh_STATE_WAIT_IHW_HIGH_AND_THRESHOLDS = 2;
    localparam OcHigh_STATE_TRIGGER_OUTPUT = 3;
    localparam OcHigh_STATE_WAIT_OUTPUT = 4;
    localparam OcHigh_STATE_JUDGE_CONDITION = 5;

    reg [OcHighBitWidth-1:0] oc_high = 0;
    reg [2:0] oc_high_state = OcHigh_STATE_IDLE;


    wire start_ihw_high_and_thresholds;
    assign start_ihw_high_and_thresholds = oc_high_state == OcHigh_STATE_TRIGGER_IHW_HIGH_AND_THRESHOLDS;
    wire start_output;
    assign start_output = oc_high_state == OcHigh_STATE_TRIGGER_OUTPUT;
    wire finish_ihw_high_wire;
    wire finish_thresholds_wire;
    wire finish_output_wire;
    reg  finish_ihw_high_reg = 0;
    reg  finish_thresholds_reg = 0;
    reg  finish_output_reg = 0;



    always @(posedge clk ) begin
        if (!rst_n || oc_high_state == OcHigh_STATE_JUDGE_CONDITION) begin
            finish_ihw_high_reg <= 0;
        end else if(oc_high_state) begin
            if(finish_ihw_high_wire)begin
                finish_ihw_high_reg <= 1;
            end
        end
    end


    always @(posedge clk ) begin
        if (!rst_n || oc_high_state == OcHigh_STATE_JUDGE_CONDITION) begin
            finish_thresholds_reg <= 0;
        end else if(oc_high_state) begin
            if(finish_thresholds_wire)begin
                finish_thresholds_reg <= 1;
            end
        end
    end

    always @(posedge clk ) begin
        if (!rst_n || oc_high_state == OcHigh_STATE_JUDGE_CONDITION) begin
            finish_output_reg <= 0;
        end else if(oc_high_state) begin
            if(finish_output_wire)begin
                finish_output_reg <= 1;
            end
        end
    end



    wire finish_ihw_high_and_thresholds = finish_ihw_high_reg && finish_thresholds_reg;
    always @(posedge clk ) begin
        case (oc_high_state)
            OcHigh_STATE_IDLE:                                  oc_high_state <= oc_high_state + start ? 1 : 0;
            OcHigh_STATE_TRIGGER_IHW_HIGH_AND_THRESHOLDS:       oc_high_state <= oc_high_state + 1;
            OcHigh_STATE_WAIT_IHW_HIGH_AND_THRESHOLDS:          oc_high_state <= oc_high_state + (finish_ihw_high_and_thresholds ? 1 :0);
            OcHigh_STATE_TRIGGER_OUTPUT:                        oc_high_state <= oc_high_state + 1;
            OcHigh_STATE_WAIT_OUTPUT:                           oc_high_state <= oc_high_state + (finish_output_reg ? 1 :0);
            OcHigh_STATE_JUDGE_CONDITION: oc_high_state <= (oc_high == (OcHighNum - 1) ) ? OcHigh_STATE_IDLE : OcHigh_STATE_TRIGGER_IHW_HIGH_AND_THRESHOLDS;
        endcase
    end


    always @(posedge clk) begin
        if(!rst_n || oc_high_state == OcHigh_STATE_IDLE )begin
            oc_high <= 0;
        end else if (oc_high_state == OcHigh_STATE_JUDGE_CONDITION) begin
            oc_high <= oc_high + 1;
        end
    end




    // stub_state_machine #(.N(10)) ihw_high(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .start(start_ihw_high_and_thresholds),
    //     .finish(finish_ihw_high_wire)
    //     );







//  ihw_high
    parameter  IhwHighBitWidth = 4;
    parameter  IhwHighNum = 2;
    localparam IhwHigh_STATE_IDLE = 0;
    localparam IhwHigh_STATE_TRIGGER_READ_INDATA_AND_INIT_OUTBUF = 1;
    localparam IhwHigh_STATE_WAIT_READ_INDATA_AND_INIT_OUTBUF = 2;
    localparam IhwHigh_STATE_TRIGGER_KHW = 3;
    localparam IhwHigh_STATE_WAIT_KHW = 4;
    localparam IhwHigh_STATE_JUDGE_CONDITION = 5;


    reg [IhwHighBitWidth-1:0] ih_high = 0;
    reg [IhwHighBitWidth-1:0] iw_high = 0;    
    reg [2:0] ihw_high_state = IhwHigh_STATE_IDLE;



    wire start_read_indata_and_init_outbuf;
    assign start_read_indata_and_init_outbuf = ihw_high_state == IhwHigh_STATE_TRIGGER_READ_INDATA_AND_INIT_OUTBUF;
    wire start_khw;
    assign start_khw = ihw_high_state == IhwHigh_STATE_TRIGGER_KHW;
    wire finish_read_indata_wire;
    wire finish_init_outbuf_wire;
    wire finish_khw_wire;
    reg  finish_read_indata_reg = 0;
    reg  finish_init_outbuf_reg = 0;
    reg  finish_khw_reg = 0;




    always @(posedge clk ) begin
        if (!rst_n || ihw_high_state == IhwHigh_STATE_JUDGE_CONDITION) begin
            finish_read_indata_reg <= 0;
        end else if(ihw_high_state) begin
            if(finish_read_indata_wire)begin
                finish_read_indata_reg <= 1;
            end
        end
    end


    always @(posedge clk ) begin
        if (!rst_n || ihw_high_state == IhwHigh_STATE_JUDGE_CONDITION) begin
            finish_init_outbuf_reg <= 0;
        end else if(ihw_high_state) begin
            if(finish_init_outbuf_wire)begin
                finish_init_outbuf_reg <= 1;
            end
        end
    end

    always @(posedge clk ) begin
        if (!rst_n || ihw_high_state == IhwHigh_STATE_JUDGE_CONDITION) begin
            finish_khw_reg <= 0;
        end else if(ihw_high_state) begin
            if(finish_khw_wire)begin
                finish_khw_reg <= 1;
            end
        end
    end



    wire finish_read_indata_and_init_outbuf = finish_read_indata_reg && finish_init_outbuf_reg;
    always @(posedge clk ) begin
        case (ihw_high_state)
            IhwHigh_STATE_IDLE:                                  ihw_high_state <= ihw_high_state + start_ihw_high_and_thresholds ? 1 : 0;
            IhwHigh_STATE_TRIGGER_READ_INDATA_AND_INIT_OUTBUF:   ihw_high_state <= ihw_high_state + 1;
            IhwHigh_STATE_WAIT_READ_INDATA_AND_INIT_OUTBUF:      ihw_high_state <= ihw_high_state + (finish_read_indata_and_init_outbuf ? 1 :0);
            IhwHigh_STATE_TRIGGER_KHW:                        ihw_high_state <= ihw_high_state + 1;
            IhwHigh_STATE_WAIT_KHW:                           ihw_high_state <= ihw_high_state + (finish_khw_reg ? 1 :0);
            IhwHigh_STATE_JUDGE_CONDITION: ihw_high_state <= (ih_high == (IhwHighNum - 1)  && iw_high == (IhwHighNum - 1) ) ? IhwHigh_STATE_IDLE : IhwHigh_STATE_TRIGGER_READ_INDATA_AND_INIT_OUTBUF;
        endcase
    end



    always @(posedge clk) begin
        if(!rst_n || ihw_high_state == IhwHigh_STATE_IDLE )begin
            ih_high <= 0;
            iw_high <= 0;
        end else if (ihw_high_state == IhwHigh_STATE_JUDGE_CONDITION) begin
            ih_high <= ih_high + (iw_high == (IhwHighNum - 1) ? 1 : 0);
            iw_high <= iw_high == (IhwHighNum - 1) ? 0 : iw_high + 1;
        end
    end


    assign finish_ihw_high_wire = ihw_high_state == IhwHigh_STATE_JUDGE_CONDITION  && (ih_high == (IhwHighNum - 1)  && iw_high == (IhwHighNum - 1) );







    stub_state_machine #(.N(15)) read_indata(
        .clk(clk),
        .rst_n(rst_n),
        .start(start_read_indata_and_init_outbuf),
        .finish(finish_read_indata_wire)
        );

    stub_state_machine #(.N(6)) init_outbuf(
        .clk(clk),
        .rst_n(rst_n),
        .start(start_read_indata_and_init_outbuf),
        .finish(finish_init_outbuf_wire)
        );

    // stub_state_machine #(.N(7)) khw(
    //     .clk(clk),
    //     .rst_n(rst_n),
    //     .start(start_khw),
    //     .finish(finish_khw_wire)
    //     );


//  khw

    parameter  KhwBitWidth = 2;
    parameter  KhwNum = 3; 
    localparam Khw_STATE_IDLE = 0;
    localparam Khw_STATE_TRIGGER_READ_KERNEL = 1;
    localparam Khw_STATE_WAIT_READ_KERNEL = 2;
    localparam Khw_STATE_TRIGGER_IHW_LOW = 3;
    localparam Khw_STATE_WAIT_IHW_LOW = 4;
    localparam Khw_STATE_JUDGE_CONDITION = 5;


    reg [KhwBitWidth-1:0] kh = 0;
    reg [KhwBitWidth-1:0] kw = 0;    
    reg [2:0] khw_state = Khw_STATE_IDLE;



    wire start_read_kernel;
    assign start_read_kernel = khw_state == Khw_STATE_TRIGGER_READ_KERNEL;
    wire start_ihw_low;
    assign start_ihw_low = khw_state == Khw_STATE_TRIGGER_IHW_LOW;
    wire finish_read_kernel_wire;
    wire finish_ihw_low_wire;
    reg  finish_read_kernel_reg = 0;
    reg  finish_ihw_low_reg = 0;


    always @(posedge clk ) begin
        if (!rst_n || khw_state == Khw_STATE_JUDGE_CONDITION) begin
            finish_read_kernel_reg <= 0;
        end else if(khw_state) begin
            if(finish_read_kernel_wire)begin
                finish_read_kernel_reg <= 1;
            end
        end
    end


    always @(posedge clk ) begin
        if (!rst_n || khw_state == Khw_STATE_JUDGE_CONDITION) begin
            finish_ihw_low_reg <= 0;
        end else if(khw_state) begin
            if(finish_ihw_low_wire)begin
                finish_ihw_low_reg <= 1;
            end
        end
    end


    wire finish_read_kernel = finish_read_kernel_reg; // redundant but keep this code for unity.
    always @(posedge clk ) begin
        case (khw_state)
            Khw_STATE_IDLE:                  khw_state <= khw_state + start_khw ? 1 : 0;
            Khw_STATE_TRIGGER_READ_KERNEL:   khw_state <= khw_state + 1;
            Khw_STATE_WAIT_READ_KERNEL:      khw_state <= khw_state + (finish_read_kernel ? 1 :0);
            Khw_STATE_TRIGGER_IHW_LOW:       khw_state <= khw_state + 1;
            Khw_STATE_WAIT_IHW_LOW:          khw_state <= khw_state + (finish_ihw_low_reg ? 1 :0);
            Khw_STATE_JUDGE_CONDITION:       khw_state <= (kh == (KhwNum - 1)  && kw == (KhwNum - 1) ) ? Khw_STATE_IDLE : Khw_STATE_TRIGGER_READ_KERNEL;
        endcase
    end



    always @(posedge clk) begin
        if(!rst_n || khw_state == Khw_STATE_IDLE )begin
            kh <= 0;
            kw <= 0;
        end else if (khw_state == Khw_STATE_JUDGE_CONDITION) begin
            kh <= kh + (kw == (KhwNum - 1) ? 1 : 0);
            kw <= kw == (KhwNum - 1) ? 0 : kw + 1;
        end
    end


    assign finish_khw_wire = khw_state == Khw_STATE_JUDGE_CONDITION  && (kh == (KhwNum - 1)  && kw == (KhwNum - 1) );




    stub_state_machine #(.N(5)) read_kernel(
        .clk(clk),
        .rst_n(rst_n),
        .start(start_read_kernel),
        .finish(finish_read_kernel_wire)
        );

    stub_state_machine #(.N(6)) ihw_low(
        .clk(clk),
        .rst_n(rst_n),
        .start(start_ihw_low),
        .finish(finish_ihw_low_wire)
        );






    stub_state_machine #(.N(4)) thresholds(
        .clk(clk),
        .rst_n(rst_n),
        .start(start_ihw_high_and_thresholds),
        .finish(finish_thresholds_wire)
        );

    stub_state_machine #(.N(8)) outputs(
        .clk(clk),
        .rst_n(rst_n),
        .start(start_output),
        .finish(finish_output_wire)
        );
        

endmodule

`default_nettype wire