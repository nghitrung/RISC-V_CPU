`timescale 1ns / 1ps
// PC unit
module Program_counter(
    input logic clk,
    input logic rst,
    input logic [31:0] PC_in,
    output logic [31:0] PC_out
);
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) PC_out <= 32'b0;
        else PC_out <= PC_in;
    end
endmodule

// Instruction unit
module Instruction_mem(
    input logic clk,
    input logic rst,
    input logic [31:0] read_addr,
    output logic[31:0] instr_out
);  
    integer i;
    logic [31:0] instr_mem [63:0]; // 64 instructions
    
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 64; i = i + 1) instr_mem[i] <= 32'b0;
        end
    end 
    
    assign instr_out = instr_mem[read_addr];
endmodule

// Register unit 
module Register ( 
    input logic clk,
    input logic rst,
    input logic reg_write, 
    input logic [4:0] read_reg1, 
    input logic [4:0] read_reg2,
    input logic [4:0] write_reg,
    input logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] register [31:0];
    integer i;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                register[i] <= 32'b0;
            end
        end else if (reg_write) begin
            register[write_reg] <= write_data;
        end
    end
    
    assign read_data1 = register[read_reg1];
    assign read_data2 = register[read_reg2];

endmodule

// Immediate Generator
/*
lw = 0000011 I-Type
sw = 0101011 S-Type
beq = 1100011 B-Type
*/
module Immediate_gen(
    input logic [6:0] opcode,
    input logic [31:0] instr,
    output logic [31:0] imm_ext
);

    always_comb begin
        imm_ext = 32'b0;
        case (opcode)
            7'b0000011: imm_ext = {{20{instr[31]}}, instr[31:20]};
            7'b0010011: imm_ext = {{20{instr[31]}}, instr[31:20]}; 
            7'b0100011: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
            7'b1100011: imm_ext = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; 
        endcase
    end
endmodule

// Control Unit
module Control (
    input logic [6:0] instr,
    output logic branch,
    output logic mem_read,
    output logic mem_to_reg,
    output logic mem_write,
    output logic ALU_src,
    output logic reg_write,
    output logic [1:0] ALUOp
);

    always_comb begin
        case (instr) 
            7'b0110011: {ALU_src, mem_to_reg, reg_write, mem_read, mem_write, branch, ALUOp} = 8'b001000_10;
            7'b0010011: {ALU_src, mem_to_reg, reg_write, mem_read, mem_write, branch, ALUOp} = 8'b101000_10;
            7'b0000011: {ALU_src, mem_to_reg, reg_write, mem_read, mem_write, branch, ALUOp} = 8'b111100_00;
            7'b0100011: {ALU_src, mem_to_reg, reg_write, mem_read, mem_write, branch, ALUOp} = 8'b100010_00;
            7'b1100011: {ALU_src, mem_to_reg, reg_write, mem_read, mem_write, branch, ALUOp} = 8'b000001_01;
            default: {ALU_src, mem_to_reg, reg_write, mem_read, mem_write, branch, ALUOp} = 8'b0;
        endcase
    end
endmodule

// ALU unit
module ALU (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] control_in,
    output logic zero,
    output logic [31:0] ALU_result
);

    always_comb begin
        zero = 1'b0; 
        ALU_result = 32'b0; 
        case (control_in)
            // and
            4'b0000: begin 
                zero = 0;
                ALU_result = a & b;
            end
            // or
            4'b0001: begin
                zero = 0;
                ALU_result = a | b;
            end
            // add
            4'b0010: begin
                zero = 0;
                ALU_result = a + b;
            end
            // subtract
            4'b0110: begin
                ALU_result = a - b;
                zero = (ALU_result == 32'b0);
            end
        endcase
    end
endmodule

// ALU control 
module ALU_control (
    input logic [1:0] ALU_op,
    input logic funct7,
    input logic [2:0] funct3,
    output logic [3:0] operation
);

    always_comb begin
        operation = 4'b0010;
        case (ALU_op)
            2'b00: operation = 4'b0010; 
            2'b01: operation = 4'b0110; 
            2'b10: begin
                case (funct3)
                    3'b000: operation = (funct7) ? 4'b0110 : 4'b0010;
                    3'b111: operation = 4'b0000; 
                    3'b110: operation = 4'b0001; 
                    default: operation = 4'b0010;
                endcase
            end
            default: operation = 4'b0010;
        endcase
    end
endmodule

// Data memory 
module Data_mem (
    input logic clk,
    input logic rst,
    input logic control_write,
    input logic control_read,
    input logic [31:0] addr,
    input logic [31:0] write_data,
    output logic [31:0] read_data
);
    integer i;
    logic [31:0] data_mem [63:0];

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 64; i = i + 1) begin 
                data_mem[i] <= 32'b0;
            end
        end else if (control_write) begin
            data_mem[addr[31:2]] <= write_data; 
        end
    end
    
    assign read_data = (control_read) ? data_mem[addr[31:2]] : 32'b0; 
endmodule 

// Multiplexers
module Mux1 (
    input logic sel1,
    input logic [31:0] a1, b1,
    output logic [31:0] mux1_out
);
    assign mux1_out = (sel1 == 1'b0) ? a1 : b1;
endmodule

module Mux2 (
    input logic sel2,
    input logic [31:0] a2, b2,
    output logic [31:0] mux2_out
);
    assign mux2_out = (sel2 == 1'b0) ? a2 : b2;
endmodule

module Mux3 (
    input logic sel3,
    input logic [31:0] a3, b3,
    output logic [31:0] mux3_out
);
    assign mux3_out = (sel3 == 1'b0) ? a3 : b3;
endmodule

module And1 (
    input logic branch_in,
    input logic zero_in,
    output logic and_out
);
    assign and_out = zero_in & branch_in;   
endmodule

module Add1 (
    input logic [31:0] PC_from,
    output logic [31:0] PC_next
);
    assign PC_next = 4 + PC_from; 
endmodule

module Add2 (
    input logic [31:0] in1,
    input logic [31:0] in2,
    output logic [31:0] add_out
);
    assign add_out = in1 + in2;
endmodule
