`timescale 1ns/1ps

module uart_rx(
    input clk,
    input rst,
    input rx,
    output reg [7:0] rx_data,
    output reg valid
);

parameter BAUD_DIV = 434;

reg [3:0] bit_cnt;
reg [15:0] baud_cnt;
reg [7:0] shift_reg;
reg receiving;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        bit_cnt <= 0; baud_cnt <= 0; receiving <= 0;
        rx_data <= 0; valid <= 0;
    end else begin
        valid <= 0;
        if(!receiving && !rx) begin
            receiving <= 1; bit_cnt <= 0; baud_cnt <= BAUD_DIV/2;
        end else if(receiving) begin
            if(baud_cnt == BAUD_DIV) begin
                baud_cnt <= 0;
                shift_reg <= {rx, shift_reg[7:1]};
                if(bit_cnt == 7) begin
                    rx_data <= {rx, shift_reg[7:1]}; valid <= 1; receiving <= 0;
                end
                bit_cnt <= bit_cnt + 1;
            end else baud_cnt <= baud_cnt + 1;
        end
    end
end

endmodule
