module top_module_tb;

logic clk, rst;

top_module uut(
    .clk(clk),
    .rst(rst)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst = 0;
    #5 rst = 1;
    #20;
end

endmodule