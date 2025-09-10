module tcs34725_reader(
    input clk,
    input rst_n,
    inout i2c_sda,
    inout i2c_scl,
    output reg [7:0] r_data,
    output reg [7:0] g_data,
    output reg [7:0] b_data
);
    // Simulação de leitura fixa
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_data <= 8'd0;
            g_data <= 8'd0;
            b_data <= 8'd0;
        end else begin
            r_data <= 8'd255; // vermelho
            g_data <= 8'd128; // verde
            b_data <= 8'd64;  // azul
        end
    end
endmodule
