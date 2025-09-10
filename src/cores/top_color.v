`timescale 1ns / 1ps

module top (
    input        clk,       // Clock 25 MHz
    input        rst_n,     // Reset ativo em baixo

    inout        sda,       // I2C SDA
    inout        scl,       // I2C SCL

    output [2:0] led_rgb,   // LED RGB
    output       tx         // UART TX
);

    // ===============================
    // Sinais internos
    // ===============================
    wire rst = ~rst_n;

    wire [7:0] r_data;
    wire [7:0] g_data;
    wire [7:0] b_data;

    wire [7:0] uart_data;
    wire       uart_tx_en;
    wire       uart_busy;

    // ===============================
    // Instância: Leitor TCS34725 (I2C)
    // ===============================
    tcs34725_reader color_sensor_inst (
        .clk      (clk),
        .rst_n    (rst_n),
        .i2c_sda  (sda),
        .i2c_scl  (scl),
        .r_data   (r_data),
        .g_data   (g_data),
        .b_data   (b_data)
    );

    // ===============================
    // Instância: Controle LED RGB
    // ===============================
    led_rgb_control led_ctrl_inst (
        .clk   (clk),
        .rst_n (rst_n),
        .r     (r_data),
        .g     (g_data),
        .b     (b_data),
        .led   (led_rgb)
    );

    // ===============================
    // Instância: UART Transmissor
    // ===============================
    UART_TX #(
        .BAUD_RATE(115200),
        .CLK_FREQ (25000000) // Clock 25 MHz
    ) uart_tx_inst (
        .clk            (clk),
        .rst_n          (rst_n),
        .wr_bit_period_i(1'b0),
        .bit_period_i   (16'd0),
        .parity_type_i  (1'b0),         // Paridade par
        .uart_tx_en     (uart_tx_en),
        .uart_tx_data   (uart_data),
        .uart_txd       (tx),
        .uart_tx_busy   (uart_busy)
    );

    // ===============================
    // Gerador de dados para UART (apenas exemplo)
    // Envia os dados de cor em sequência
    // ===============================
    reg [1:0] state_uart;
    reg [23:0] counter;
    assign uart_tx_en = (counter == 0) && !uart_busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_uart <= 0;
            counter    <= 24'd0;
        end else begin
            if (counter > 0)
                counter <= counter - 1;
            else if (!uart_busy)
                counter <= 24'd1_000_000; // intervalo entre transmissões (~40ms)
        end
    end

    assign uart_data = (state_uart == 2'd0) ? r_data :
                       (state_uart == 2'd1) ? g_data :
                       (state_uart == 2'd2) ? b_data :
                       8'h0A; // newline '\n'

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_uart <= 0;
        else if (uart_tx_en)
            state_uart <= state_uart + 1;
    end

endmodule
