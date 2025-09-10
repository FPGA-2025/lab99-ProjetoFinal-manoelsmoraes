// UART TX simples
// Envia 8 bits sequenciais continuamente
module uart_tx(
    input clk,
    input rst_n,
    input [7:0] uart_tx_data, // Byte a ser transmitido
    input uart_tx_en,         // Habilita transmissão
    output reg uart_txd,      // Linha TX UART
    output reg uart_tx_busy   // Indica transmissão em andamento
);

parameter BAUD_DIV = 434; // 115200bps @25MHz

reg [3:0] bit_idx;       // Índice do bit transmitido
reg [15:0] baud_cnt;     // Contador para baud rate
reg [7:0] tx_buf;        // Buffer temporário dos dados
reg [2:0] state;

localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

// FSM de transmissão
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        uart_txd <= 1'b1;
        uart_tx_busy <= 0;
        bit_idx <= 0;
        baud_cnt <= 0;
        tx_buf <= 0;
        state <= IDLE;
    end else begin
        case(state)
            IDLE: begin
                uart_txd <= 1'b1;
                uart_tx_busy <= 0;
                if (uart_tx_en) begin
                    tx_buf <= uart_tx_data;
                    uart_tx_busy <= 1;
                    baud_cnt <= 0;
                    bit_idx <= 0;
                    state <= START;
                end
            end
            START: begin
                uart_txd <= 1'b0; // Start bit
                if (baud_cnt < BAUD_DIV) baud_cnt <= baud_cnt + 1;
                else begin
                    baud_cnt <= 0;
                    state <= DATA;
                end
            end
            DATA: begin
                uart_txd <= tx_buf[0]; // Envia bit LSB
                if (baud_cnt < BAUD_DIV) baud_cnt <= baud_cnt + 1;
                else begin
                    baud_cnt <= 0;
                    tx_buf <= {1'b0, tx_buf[7:1]};
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == 7) state <= STOP;
                end
            end
            STOP: begin
                uart_txd <= 1'b1; // Stop bit
                if (baud_cnt < BAUD_DIV) baud_cnt <= baud_cnt + 1;
                else begin
                    baud_cnt <= 0;
                    state <= IDLE;
                end
            end
        endcase
    end
end

endmodule
