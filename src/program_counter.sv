// Instruction fetch level
module PC(
    input logic clk,
    input logic rst,
    input logic [31:0] PC_from,
    input logic PC_sel,
    output logic [31:0] PC_to
);
    logic [31:0] next_PC;
    always_comb begin
        if (PC_sel) next_PC = PC_from;
        else next_PC = PC_to + 4;
    end

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) PC_to <= 32'b0;
        else PC_to <= next_PC;
    end
endmodule

// Instruction decode level
module Instruction_Mem(
    input logic clk,
    input logic rst,
    input logic [31:0] read_addr,
    output logic[31:0] instr_out
);  
    integer i;
    logic [31:0] instr_mem [63:0]; // 64 instructions
    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 64; i = i + 1) begin
                instr_mem[k] <= 32'b0;
            end
        end 
    end

    assign instr_out <= instr_mem[read_addr];
endmodule

// Instruction execution 
module Register_File ( 
    input logic clk,
    input logic rst,
    input logic reg_write, // Signal from Control Block
    input logic [4:0] read_reg1, 
    input logic [4:0] read_reg2,
    input logic [4:0] write_reg,
    output logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] register [31:0];
    integer i;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                register[k] <= 32'b0;
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
module Immediate_func(
    input format_t [6:0] opcode,
    input logic [31:0] instr,
    output logic [31:0] imm_ext
);

    always_comb begin
        case (opcode)
            7'b0000011: imm_ext = {{20{instr[31]}}, instr[31:20]}; // take the 31th value and extend 20 times
            7'b0101011: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; 
            7'b1100011: imm_ext = {{19,{instr[31]}}, instr[31], instr[30:25], instr[11:8], 1'b0};
        endcase
    end

endmodule