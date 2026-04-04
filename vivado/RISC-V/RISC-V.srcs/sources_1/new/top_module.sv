`timescale 1ns / 1ps
module top_module(
    input logic clk,
    input logic rst
);
    logic [31:0] pc;
    logic [31:0] instr;
    logic reg_write, ALU_src, branch, zero, mem_to_reg, mem_write, mem_read;
    logic [1:0] ALUOp;
    logic [31:0] read_data1;
    logic [31:0] read_data2;
    logic [31:0] read_data;
    logic [31:0] address;
    logic [31:0] imm_ext;
    logic [31:0] mux1_out;
    logic [31:0] sel;
    logic [3:0] op;
    logic [31:0] write_back;
    logic [31:0] next_pc;
    logic [31:0] pc_out;
    logic [31:0] sum;

    // PC
    Program_counter Program_counter(
        .clk(clk),
        .rst(rst),
        .PC_in(pc_out),
        .PC_out(pc)
    );

    // PC adder
    add1 add1(
        .PC_from(pc),
        .PC_next(next_pc)
    );

    // Instruction memory 
    Instruction Instruction (
        .clk(clk),
        .rst(rst),
        .read_addr(pc),
        .instr_out()
    );

    // Register unit
    Register Register (
        .clk(clk),
        .rst(rst),
        .reg_write(reg_write),
        .read_reg1(instr[19:15]),
        .read_reg2(instr[24:20]),
        .write_reg(instr[11:7]),
        .write_data(write_back),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Immediate generator
    Immediate_gen Immediate_gen (
        .opcode(instr[6:0]),
        .instr(instr[31:0]),
        .imm_ext(imm_ext)
    );

    // Control unit
    Control Control (
        .instr(instr[6:0]),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .ALU_src(ALU_src),
        .reg_write(reg_write),
        .ALUOp(ALUOp)
    );

    // ALU unit
    ALU_control ALU_control (
        .ALU_op(ALUOp),
        .funct7(instr[30]),
        .funct3(instr[14:12]),
        .operation(op)
    );

    // ALU unit
    ALU ALU (
        .a(read_data1),
        .b(mux1_out),
        .control_in(op),
        .zero(zero),
        .ALU_result(address)
    );

    // Mux in ALU part
    Mux1 mux1 (
        .sel1(ALU_src),
        .a1(read_data2),
        .b1(imm_ext),
        .mux1_out(mux1_out)
    );

    And And (
        .branch_in(branch),
        .zero_in(zero),
        .and_out(sel)
    );

    add2 add2 (
        .in1(pc),
        .in2(imm_ext),
        .add_out(sum2)
    );

    Mux2 mux2 (
        .sel2(sel),
        .a2(next_pc),
        .b2(sum),
        .mux2_out(pc_out)
    );

    Data_mem Data_mem (
        .clk(clk),
        .rst(rst),
        .control_write(mem_write),
        .control_read(mem_read),
        .addr(address),
        .write_data(read_data2),
        .read_data(read_data)
    );

    Mux3 Mux3 (
        .sel3(mem_to_reg),
        .a3(address),
        .b3(read_data),
        .mux3_out(write_back)
    );
endmodule