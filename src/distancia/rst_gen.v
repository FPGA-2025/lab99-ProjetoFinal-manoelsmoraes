// Gera reset síncrono a partir do reset ativo baixo externo
module rst_gen(
    input clk,
    input rst_n,
    output rst
);

reg [7:0] rst_sync;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        rst_sync <= 8'hFF;
    else
        rst_sync <= {rst_sync[6:0],1'b0};
end

assign rst = rst_sync[7];

endmodule
