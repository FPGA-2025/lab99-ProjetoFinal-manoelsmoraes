module rst_gen(
    input clk,
    input rst_n,
    output reg rst
);
    always @(posedge clk) begin
        rst <= ~rst_n;
    end
endmodule
