`timescale 1ns / 1ps
module top_module(
    input logic clk,
    input logic rst,
    output logic [31:0] pc_debug,
    output logic [31:0] instr_debug,
    output logic [31:0] alu_debug,
    output logic [31:0] reg_x1_debug,
    output logic [31:0] reg_x2_debug,
    output logic [31:0] output_debug
);
    logic [31:0] pc, instr, read_data1, read_data2, read_data, address, imm_ext, mux1_out, write_back, next_pc, pc_in_val, sum, pc_out;
    logic reg_write, ALU_src, branch, zero, mem_to_reg, mem_write, mem_read, sel;
    logic [1:0] ALUOp;
    logic [3:0] op;

    assign pc_debug = pc;
    assign instr_debug = instr;
    assign alu_debug = op;
    assign reg_x1_debug = read_data1;
    assign reg_x2_debug = read_data2;
    assign output_debug = write_back;
    
    // PC
    Program_counter Program_counter(
        .clk(clk),
        .rst(rst),
        .PC_in(pc_out),
        .PC_out(pc)
    );

    // PC adder
    Add1 Add1(
        .PC_from(pc),
        .PC_next(next_pc)
    );

    // Instruction memory 
    Instruction_mem Instruction_mem (
        .clk(clk),
        .rst(rst),
        .read_addr(pc),
        .instr_out(instr)
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
    Mux1 Mux1 (
        .sel1(ALU_src),
        .a1(read_data2),
        .b1(imm_ext),
        .mux1_out(mux1_out)
    );

    And1 And1 (
        .branch_in(branch),
        .zero_in(zero),
        .and_out(sel)
    );

    Add2 Add2 (
        .in1(pc),
        .in2(imm_ext),
        .add_out(sum)
    );

    Mux2 Mux2 (
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
