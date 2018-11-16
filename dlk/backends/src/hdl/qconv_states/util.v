module stub_state_machine #(
    parameter WIDTH = 4,
    parameter N = 10
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    output wire finish
);

    reg [WIDTH-1:0] counter = 0;

    assign finish = counter == N;

    always @(posedge clk ) begin
        if (!rst_n || finish) begin
            counter <= 0;
        end else if(start || (counter != 0 )) begin
            counter <= counter + 1;
        end
    end

endmodule

