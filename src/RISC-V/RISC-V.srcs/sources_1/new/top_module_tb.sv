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

`timescale 1ns / 1ps
module top_module_tb;
    logic clk, rst;
    logic [31:0] pc, instr, alu_out, a, b, result;

    task automatic check_reg(input int reg_idx, input logic [31:0] expected, input string name);
        begin
            if (uut.Register.register[reg_idx] !== expected) begin
                $display("FAIL %s: reg[%0d] = %0d (0x%08h), expected %0d (0x%08h)",
                         name, reg_idx, uut.Register.register[reg_idx], uut.Register.register[reg_idx], expected, expected);
            end else begin
                $display("PASS %s: reg[%0d] = %0d (0x%08h)",
                         name, reg_idx, uut.Register.register[reg_idx], uut.Register.register[reg_idx]);
            end
        end
    endtask

    task automatic check_mem(input int word_idx, input logic [31:0] expected, input string name);
        begin
            if (uut.Data_mem.data_mem[word_idx] !== expected) begin
                $display("FAIL %s: mem[%0d] = %0d (0x%08h), expected %0d (0x%08h)",
                         name, word_idx, uut.Data_mem.data_mem[word_idx], uut.Data_mem.data_mem[word_idx], expected, expected);
            end else begin
                $display("PASS %s: mem[%0d] = %0d (0x%08h)",
                         name, word_idx, uut.Data_mem.data_mem[word_idx], uut.Data_mem.data_mem[word_idx]);
            end
        end
    endtask

    top_module uut (
        .clk(clk), 
        .rst(rst),
        .pc_debug(pc), 
        .instr_debug(instr),
        .alu_debug(alu_out), 
        .reg_x1_debug(a), 
        .reg_x2_debug(b),
        .output_debug(result)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin    
        rst = 0; 
        #10 rst = 1; 
            // R-type
        uut.Instruction_mem.instr_mem[0]  = 32'b0000000_00000_00000_000_00000_0000000;
        uut.Instruction_mem.instr_mem[4]  = 32'b0000000_11001_10000_000_01101_0110011; // add x13, x16, x25
        uut.Instruction_mem.instr_mem[8]  = 32'b0100000_00011_01000_000_00101_0110011; // sub x5, x8, x3
        uut.Instruction_mem.instr_mem[12] = 32'b0000000_00100_00010_111_00001_0110011; // and x1, x2, x3
        uut.Instruction_mem.instr_mem[16] = 32'b0000000_00101_00011_110_00100_0110011; // or x4, x3, x5

        // I-type
        uut.Instruction_mem.instr_mem[20] = 32'b000000000011_10101_000_10110_0010011; // addi x22, x21, 3
        uut.Instruction_mem.instr_mem[24] = 32'b000000000001_01000_110_01001_0010011; //
        uut.Instruction_mem.instr_mem[28] = 32'b000000001111_00101_010_01000_0000011; // 

        // S-type
        uut.Instruction_mem.instr_mem[32] = 32'b0000000_01111_00101_010_01100_0100011; // 

        // SB-type
        uut.Instruction_mem.instr_mem[36] = 32'h00948663; //

        uut.Register.register[0] = 1;
        uut.Register.register[1] = 2;
        uut.Register.register[2] = 4;
        uut.Register.register[3] = 5;
        uut.Register.register[4] = 7;
        uut.Register.register[5] = 21;
        uut.Register.register[6] = 31;
        uut.Register.register[7] = 52;
        uut.Register.register[8] = 8;
        uut.Register.register[9] = 83;
        uut.Register.register[10] = 43;
        uut.Register.register[11] = 77;
        uut.Register.register[12] = 3;
        uut.Register.register[13] = 3;
        uut.Register.register[14] = 4;
        uut.Register.register[15] = 5;
        uut.Register.register[16] = 79;
        uut.Register.register[17] = 32;
        uut.Register.register[18] = 64;
        uut.Register.register[19] = 34;
        uut.Register.register[20] = 63;
        uut.Register.register[21] = 23;
        uut.Register.register[22] = 87;
        uut.Register.register[23] = 34;
        uut.Register.register[24] = 65;
        uut.Register.register[25] = 33;
        uut.Register.register[26] = 4;
        uut.Register.register[27] = 36;
        uut.Register.register[28] = 1;
        uut.Register.register[29] = 2;
        uut.Register.register[30] = 5;
        uut.Register.register[31] = 7;
        
        #80;
        check_reg(13, 32'd112, "ADD x13 = x16 + x25");
        check_reg(5, 32'd3, "SUB x5 = x8 - x3");
        check_reg(1, 32'd4, "AND x1 = x2 & x3");
        check_reg(4, 32'd7, "OR x4 = x3 | x5");
        check_reg(22, 32'd26, "ADDI x22 = x21 + 3");
        check_mem(3, 32'd5, "SW store x15 to memory");

        #20; 
        $finish;;
    end

    always @(posedge clk) begin
        #1; 
        $display("T=%0t pc=%0d instr=%h alu_out=%0d x1=%0d x2=%0d  output=%0d", $time, pc, instr, alu_out, a, b, result); 
    end
endmodule
