`timescale 1ns/1ps

module vl53l0x_reader(
    input clk,
    input rst,
    input [7:0] i2c_data,
    input data_ready_i,
    output reg [7:0] distance,
    output reg data_ready
);

always @(posedge clk or posedge rst) begin
    if(rst) begin
        distance <= 0;
        data_ready <= 0;
    end else begin
        if(data_ready_i) begin
            distance <= i2c_data;
            data_ready <= 1;
        end else begin
            data_ready <= 0;
        end
    end
end

endmodule
