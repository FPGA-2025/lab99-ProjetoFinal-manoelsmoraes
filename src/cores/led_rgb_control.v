module led_rgb_control (
    input clk,
    input rst_n,
    input [7:0] r,
    input [7:0] g,
    input [7:0] b,
    output reg [2:0] led
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            led <= 3'b000;
        else
            led <= {r[7], g[7], b[7]}; // Usa o MSB de cada canal
    end
endmodule
