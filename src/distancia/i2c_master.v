`timescale 1ns/1ps

module i2c_master(
    input clk,
    input rst,
    input start,
    input [6:0] addr,
    input rd_two_bytes,
    output reg [7:0] data,
    output reg busy,
    output reg ack_error,
    output reg data_ready,
    inout sda,
    inout scl
);

// Para teste, envia valores fictícios 0x12, 0x34
reg [1:0] counter;
always @(posedge clk or posedge rst) begin
    if(rst) begin
        data <= 0;
        data_ready <= 0;
        counter <= 0;
        busy <= 0;
        ack_error <= 0;
    end else if(start) begin
        busy <= 1;
        counter <= counter + 1;
        case(counter)
            0: data <= 8'h12;
            1: data <= 8'h34;
        endcase
        data_ready <= 1;
        busy <= 0;
    end else data_ready <= 0;
end

endmodule
