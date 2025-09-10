module i2c_master #(
    parameter CLK_FREQ_HZ = 25000000,
    parameter I2C_FREQ_HZ = 100000
) (
    input clk,
    input rst_n,
    input [6:0] addr,
    input [7:0] data_in,
    input enable,
    input rw, // 0: write, 1: read

    output reg [7:0] data_out,
    output ready,

    inout i2c_sda,
    inout i2c_scl
);
    localparam IDLE         = 0,
               START        = 1,
               ADDRESS      = 2,
               READ_ACK     = 3,
               WRITE_DATA   = 4,
               WRITE_ACK    = 5,
               READ_DATA    = 6,
               READ_ACK2    = 7,
               STOP         = 8;

    localparam DIVIDE_BY = CLK_FREQ_HZ / I2C_FREQ_HZ;

    reg [3:0] state;
    reg [7:0] saved_addr;
    reg [7:0] saved_data;
    reg [7:0] bit_counter;
    reg [15:0] clk_counter;
    reg write_enable;
    reg sda_out;
    reg i2c_scl_enable;
    reg i2c_clk;
    wire i2c_clk_od, i2c_sda_od;

    assign ready = (state == IDLE) && rst_n;
    assign i2c_clk_od = i2c_clk ? 1'bz : 1'b0;
    assign i2c_scl = (i2c_scl_enable) ? i2c_clk_od : 1'bz;
    assign i2c_sda_od = sda_out ? 1'bz : 1'b0;
    assign i2c_sda = (write_enable) ? i2c_sda_od : 1'bz;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_counter <= 0;
            i2c_clk <= 0;
        end else if (clk_counter == (DIVIDE_BY/2 - 1)) begin
            i2c_clk <= ~i2c_clk;
            clk_counter <= 0;
        end else begin
            clk_counter <= clk_counter + 1;
        end
    end

    always @(negedge i2c_clk or negedge rst_n) begin
        if (!rst_n)
            i2c_scl_enable <= 0;
        else
            i2c_scl_enable <= ~((state == IDLE) || (state == START) || (state == STOP));
    end

    always @(posedge i2c_clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            saved_addr <= 0;
            saved_data <= 0;
            bit_counter <= 0;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: if (enable) begin
                    saved_addr <= {addr, rw};
                    saved_data <= data_in;
                    state <= START;
                end

                START: begin
                    bit_counter <= 7;
                    state <= ADDRESS;
                end

                ADDRESS: if (bit_counter == 0) state <= READ_ACK;
                         else bit_counter <= bit_counter - 1;

                READ_ACK: if (i2c_sda == 0) begin
                    bit_counter <= 7;
                    state <= saved_addr[0] ? READ_DATA : WRITE_DATA;
                end else state <= STOP;

                WRITE_DATA: if (bit_counter == 0) state <= READ_ACK2;
                            else bit_counter <= bit_counter - 1;

                READ_ACK2: state <= (i2c_sda == 0 && enable) ? IDLE : STOP;

                READ_DATA: begin
                    data_out[bit_counter] <= i2c_sda;
                    if (bit_counter == 0) state <= WRITE_ACK;
                    else bit_counter <= bit_counter - 1;
                end

                WRITE_ACK: state <= STOP;

                STOP: state <= IDLE;

                default: state <= IDLE;
            endcase
        end
    end

    always @(negedge i2c_clk or negedge rst_n) begin
        if (!rst_n) begin
            write_enable <= 0;
            sda_out <= 1;
        end else begin
            case (state)
                IDLE:        {write_enable, sda_out} <= 2'b01;
                START:       {write_enable, sda_out} <= 2'b10;
                ADDRESS:     begin write_enable <= 1; sda_out <= saved_addr[bit_counter]; end
                READ_ACK:    {write_enable, sda_out} <= 2'b00;
                WRITE_DATA:  begin write_enable <= 1; sda_out <= saved_data[bit_counter]; end
                WRITE_ACK:   {write_enable, sda_out} <= 2'b10;
                READ_ACK2:   {write_enable, sda_out} <= 2'b00;
                READ_DATA:   {write_enable, sda_out} <= 2'b00;
                STOP:        {write_enable, sda_out} <= 2'b10;
            endcase
        end
    end

endmodule
