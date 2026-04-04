`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/04/2026 03:21:32 PM
// Design Name: 
// Module Name: top_module_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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
