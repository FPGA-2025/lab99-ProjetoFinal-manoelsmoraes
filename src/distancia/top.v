`timescale 1ns/1ps

// Top module principal
// Contém UART TX, LED de teste e placeholder para I2C
module top(
    input clk,          // Clock da FPGA (25MHz)
    input rst_n,        // Reset ativo baixo
    output tx,          // UART TX
    inout sda,          // I2C SDA (placeholder)
    inout scl,          // I2C SCL (placeholder)
    output led          // LED L2 para teste
);

wire rst;
wire [7:0] counter_data;
wire uart_busy;

// Instancia o reset síncrono
rst_gen reset_inst(
    .clk(clk),
    .rst_n(rst_n),
    .rst(rst)
);

// Timer simples para gerar dados de teste para UART
reg [23:0] timer;
reg [7:0] data;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        timer <= 24'd0;
        data <= 8'h55;
    end else begin
        timer <= timer + 1'b1;
        if (timer == 24'd12_500_000) begin // Aproximadamente 0,5s
            data <= data + 1'b1;
            timer <= 0;
        end
    end
end

assign counter_data = data;
assign led = timer[23]; // Pisca LED para sinalização visual

// Instancia UART TX
uart_tx uart_tx_inst(
    .clk(clk),
    .rst_n(rst_n),
    .uart_tx_data(counter_data),
    .uart_tx_en(1'b1),
    .uart_txd(tx),
    .uart_tx_busy(uart_busy)
);

// Placeholder para I2C (sem operação)
assign sda = 1'bz;
assign scl = 1'bz;

endmodule
